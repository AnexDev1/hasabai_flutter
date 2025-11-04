# Permissions Setup Guide

This document explains how to configure permissions for the Hasab AI Flutter SDK to work properly across all platforms.

## Required Permissions

The Hasab AI SDK requires the following permissions:

1. **Microphone Access** - For audio recording (Speech-to-Text)
2. **Internet Access** - For API communication
3. **Storage Access** - For saving/reading audio files (optional but recommended)

## Platform Configuration

### Android

The Android permissions are already configured in `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Permissions for audio recording and playback -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />

<!-- For Android 13+ (API 33+) -->
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />

<!-- Internet permission for API calls -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- Microphone feature -->
<uses-feature android:name="android.hardware.microphone" android:required="false" />
```

### iOS

The iOS permissions are already configured in `ios/Runner/Info.plist`:

```xml
<!-- Permissions for audio recording and playback -->
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to the microphone to record audio for speech-to-text transcription.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs speech recognition to convert your voice to text.</string>
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

**Note:** You can customize the permission messages to match your app's specific use case.

### macOS

The macOS permissions are configured in two places:

**1. `macos/Runner/Info.plist`:**
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to the microphone to record audio for speech-to-text transcription.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs speech recognition to convert your voice to text.</string>
```

**2. `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:**
```xml
<!-- Audio recording permissions -->
<key>com.apple.security.device.audio-input</key>
<true/>
<!-- Network client for API calls -->
<key>com.apple.security.network.client</key>
<true/>
<!-- File access for audio files -->
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
```

### Web

No additional permissions configuration needed. The browser will prompt users for microphone access when needed.

### Linux

No additional configuration needed for Linux builds.

## Runtime Permission Handling

The SDK includes a `PermissionsHelper` utility class to handle runtime permissions:

```dart
import 'package:hasab_ai_flutter/hasab_ai_flutter.dart';

// Request all audio permissions
bool granted = await PermissionsHelper.requestAudioPermissions();

if (granted) {
  // Proceed with audio recording
} else {
  // Show error message to user
}
```

### Available Permission Methods

```dart
// Request microphone permission
bool granted = await PermissionsHelper.requestMicrophonePermission();

// Request storage permission (optional)
bool granted = await PermissionsHelper.requestStoragePermission();

// Check if microphone permission is already granted
bool hasPermission = await PermissionsHelper.hasMicrophonePermission();

// Check all permissions status
Map<String, bool> status = await PermissionsHelper.checkAllPermissions();

// Open app settings for manual permission grant
await PermissionsHelper.openAppSettings();
```

## Automatic Permission Request

The `AudioRecorder` automatically requests microphone permission when initialized:

```dart
final recorder = AudioRecorder();
await recorder.initialize(); // Automatically requests permission
```

If permission is denied, it throws a `HasabException` with a clear error message.

## Example App Integration

The example app demonstrates proper permission handling:

```dart
@override
void initState() {
  super.initState();
  _hasab = HasabAI(apiKey: 'YOUR_API_KEY');
  _checkPermissions();
}

Future<void> _checkPermissions() async {
  try {
    await _recorder.initialize();
    setState(() {
      _permissionsGranted = true;
    });
  } catch (e) {
    setState(() {
      _permissionsGranted = false;
    });
    // Show UI to request permissions
  }
}

Future<void> _requestPermissions() async {
  try {
    final granted = await PermissionsHelper.requestAudioPermissions();
    if (granted) {
      // Permission granted, proceed
    } else {
      // Permission denied, show error
    }
  } catch (e) {
    // Handle error
  }
}
```

## Best Practices

1. **Request permissions at appropriate times**: Don't request all permissions at app launch. Request them when the user actually needs to use the feature.

2. **Provide context**: Before requesting permissions, explain why your app needs them.

3. **Handle denials gracefully**: If permissions are denied, disable the relevant features and show helpful messages.

4. **Check permissions before use**: Always check if permissions are granted before attempting to record audio or use other protected features.

5. **Guide users to settings**: If permissions are permanently denied, guide users to app settings to enable them manually.

## Troubleshooting

### Permission Denied Error

If you get a permission denied error:

1. Check that the permission is properly declared in the manifest/Info.plist
2. Ensure you're requesting the permission at runtime
3. On iOS, make sure the usage description is provided
4. On macOS, check that entitlements are properly configured

### Microphone Not Working

If the microphone isn't working:

1. Check physical device settings (not an emulator issue)
2. Verify the app has permission in device Settings
3. Try restarting the app after granting permission
4. Check if another app is using the microphone

### iOS/macOS Specific Issues

- Make sure you've included all required keys in Info.plist
- For macOS, verify entitlements are correct for both Debug and Release
- Background audio mode is optional but recommended for iOS

## Platform-Specific Notes

### Android 13+ (API 33+)

Android 13 changed how storage permissions work. The SDK uses `READ_MEDIA_AUDIO` for devices running Android 13 or higher.

### iOS Background Audio

If you need to record audio in the background, the `audio` background mode is already configured.

### macOS Sandboxing

macOS apps are sandboxed by default. The required entitlements are already configured for proper audio and network access.

---

For more information, see the main [README.md](README.md) file.
