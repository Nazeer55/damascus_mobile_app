import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'supabase_service.dart';

class PushNotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static Future<void> initialize(BuildContext context) async {
    try {
      // 1. Request permissions for iOS
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // 2. Get FCM token
        String? token = await _fcm.getToken();
        if (token != null) {
          _saveTokenToDatabase(token);
        }

        // Listen for token refreshes
        _fcm.onTokenRefresh.listen((newToken) {
          _saveTokenToDatabase(newToken);
        });

        // 3. Foreground message listener
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          // You could show a local toast here using the scaffold messenger 
          // or a completely custom animated banner like the one requested in HomeScreen
          print('Got a message whilst in the foreground!');
          if (message.notification != null) {
            print('Message also contained a notification: ${message.notification}');
          }
        });

        // 4. Handle taps on background messages 
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          // E.g. push to Alerts screen
        });
      }
    } catch (e) {
       print("Failed to init Push Notifications: $e. Ensure Firebase config exists.");
    }
  }

  static Future<void> _saveTokenToDatabase(String token) async {
    try {
       // Only update if Supabase is initialized and user is signed in
       final userId = SupabaseService.client.auth.currentUser?.id;
       if (!SupabaseService.isPlaceholder && userId != null) {
          await SupabaseService.users.update({
            'fcm_token': token
          }).eq('id', userId);
       }
    } catch (e) {
       print("Error saving FCM token: $e");
    }
  }
}
