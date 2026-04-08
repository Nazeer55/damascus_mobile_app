import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_service.dart';

const fetchBackground = "fetchBackgroundLocation";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // 1. Initialize DB if we need to write
      await SupabaseService.initialize();
      if (SupabaseService.isPlaceholder) {
         return Future.value(true); // Stop if placeholder
      }

      // Check user preferences
      final prefs = await SharedPreferences.getInstance();
      bool enabled = prefs.getBool('reporting_enabled') ?? true;
      if (!enabled) return Future.value(true);

      // We ideally want < 15% battery check here, but typically Android limits background processing naturally in battery saver.

      // 2. Get Location
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      
      // Speed is usually given in meters/second. Convert to km/h.
      double speedKmh = position.speed * 3.6;

      // 3. Logic: If speed < 10 km/h for 2 consecutive readings.
      // Store the last reading count in SharedPreferences.
      int slowCount = prefs.getInt('consecutive_slow') ?? 0;

      if (speedKmh < 10.0) {
         slowCount++;
      } else {
         slowCount = 0; // reset
      }
      await prefs.setInt('consecutive_slow', slowCount);

      if (slowCount >= 2) {
         // Write to SQL
         final userId = SupabaseService.client.auth.currentUser?.id;
         if (userId != null) {
            await SupabaseService.gpsReports.insert({
               'user_id': userId,
               'lat': position.latitude,
               'lng': position.longitude,
               'speed_kmh': speedKmh,
               'street_name': 'Unknown Street', // Would require reverse geocoding
               'created_at': DateTime.now().toIso8601String()
            });
         }
         // Reset count after reporting
         await prefs.setInt('consecutive_slow', 0);
      }
      
    } catch (err) {
      print("Background Task Error: $err");
    }
    return Future.value(true);
  });
}

class BackgroundLocationService {
  static Future<void> initialize() async {
    // Note: Android Workmanager minimum periodic interval is 15 minutes.
    // Real "every 30 seconds" background tracking usually requires a Foreground Service
    // with persistent notification. We use standard Workmanager here as requested.
    await Workmanager().initialize(
        callbackDispatcher, // The top level function
        isInDebugMode: true // If enabled it will post a notification whenever the task is running
    );
  }

  static Future<void> startTracking() async {
    // Request permission from user
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Workmanager().registerPeriodicTask(
          "1",
          fetchBackground,
          frequency: const Duration(minutes: 15), 
          constraints: Constraints(
            networkType: NetworkType.connected, // Only run if internet is available
          )
        );
    }
  }

  static void stopTracking() {
    Workmanager().cancelAll();
  }
}
