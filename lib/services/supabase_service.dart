import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // TODO: Replace these placeholders with your actual Supabase URL and Anon Key.
  // Obtain these from your Supabase Dashboard: Project Settings -> API
  static const String _supabaseUrl = 'YOUR_SUPABASE_URL_HERE';
  static const String _supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';

  /// True when running with placeholder credentials (no real DB connected)
  static bool get isPlaceholder => _supabaseUrl == 'YOUR_SUPABASE_URL_HERE';

  static Future<void> initialize() async {
    try {
      if (!isPlaceholder) {
        await Supabase.initialize(
          url: _supabaseUrl,
          anonKey: _supabaseAnonKey,
        );
      } else {
        print("WARNING: Supabase is using placeholder credentials. Database calls will fail.");
      }
    } catch (e) {
      print("Supabase Init Error: $e");
    }
  }

  static SupabaseClient get client => Supabase.instance.client;

  // Helpers pointing to the requested SQL tables
  static SupabaseQueryBuilder get users => client.from('users');
  static SupabaseQueryBuilder get gpsReports => client.from('gps_reports');
  static SupabaseQueryBuilder get incidentReports => client.from('incident_reports');
  static SupabaseQueryBuilder get roadStatuses => client.from('road_statuses');
  static SupabaseQueryBuilder get alerts => client.from('alerts');
}
