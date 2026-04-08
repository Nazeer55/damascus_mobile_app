# Damascus Traffic Flutter Application

This is the citizen mobile app for the Damascus Smart Traffic System, built with Flutter.
It is completely migrated to use Supabase (PostgreSQL) instead of Firebase for real-time traffic map statuses, background GPS reporting, and push notifications via FCM.

## 🛠 Prerequisites for Building

1. **Flutter SDK**: Ensure you have Flutter 3.10+ installed.
2. **Developer Mode (Windows users)**: Building native plugins requires Developer Mode on Windows. If `flutter pub add` failed for you with symlink errors:
   - Go to Windows Settings -> Privacy & Security -> For Developers
   - Turn ON "Developer Mode".
3. **Google Maps API Key**:
   - Go to Google Cloud Console, enable "Maps SDK for Android" and "Maps SDK for iOS".
   - Put your API key in `android/app/src/main/AndroidManifest.xml` (inside the `<application>` tag):
     ```xml
     <meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_API_KEY"/>
     ```
   - Put your API key in `ios/Runner/AppDelegate.swift`:
     ```swift
     GMSServices.provideAPIKey("YOUR_API_KEY")
     ```

## 🗄️ Supabase Configuration (SQL Database)

The application currently uses placeholders. You must link it to a real Supabase instance.
1. Open `lib/services/supabase_service.dart`.
2. Replace `YOUR_SUPABASE_URL_HERE` and `YOUR_SUPABASE_ANON_KEY_HERE` with your actual tokens.

To mirror the Firebase collections natively in SQL, ensure your Supabase database has these tables enabled for public reading and authenticated inserting:
- `users`
- `gps_reports`
- `incident_reports`
- `road_statuses`
- `alerts`

## 🔔 Push Notifications
The app is wired using `firebase_messaging`. You still need to link a Firebase project to the Flutter app to receive FCM tokens:
- Run: `dart pub global activate flutterfire_cli`
- Run: `flutterfire configure` inside this project directory.
- This will generate the `google-services.json` and `GoogleService-Info.plist` files required for FCM to boot successfully.

## 🚀 Running the App
Once you've done the above, run:
```bash
flutter pub get
flutter run
```
