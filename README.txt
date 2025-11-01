
Smart Mirror - Flutter Starter (Portrait, Touchscreen)
====================================================

This ZIP contains a Flutter app starter with:
- Bottom navigation (Home / Profile / Camera / Settings)
- Dashboard tile layout (Time, Camera toggle, Recent activity)
- Manual camera start/stop and video recording
- Portrait-optimized layout for touchscreen smart mirrors (RK3568 Android 11 compatible)

IMPORTANT: This package contains the Flutter `lib/` code and `pubspec.yaml`. If you don't have platform folders (android/ ios), run `flutter create .` in this directory to generate them before building.

Quick setup (macOS / Linux / Windows with Flutter installed):
1. Unzip the folder:
   unzip smart_mirror_full.zip -d smart_mirror_full
   cd smart_mirror_full

2. If this is NOT a full flutter project (no android/ ios folders), run:
   flutter create .

3. Get dependencies:
   flutter pub get

4. (Android) Add permissions in android/app/src/main/AndroidManifest.xml:
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.RECORD_AUDIO" />
   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

   And inside <application> add: android:requestLegacyExternalStorage="true"

5. Run on device (ensure RK3568 device is connected / visible via adb):
   flutter devices
   flutter run -d <device-id>

Notes for RK3568 and camera:
- Ensure camera HAL and drivers are available to Android (camera works in other Android apps).
- If using a CSI camera, confirm Android build exposes it as a camera device.
- If camera fails, check `adb logcat` for camera-related errors.

If you want, I can:
- Add face-recognition module next (mediapipe / tflite)
- Add saved videos gallery UI
- Adjust tile sizes / fonts for your exact mirror dimensions (resolution)
