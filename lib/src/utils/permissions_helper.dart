import 'package:permission_handler/permission_handler.dart';
import 'package:hasab_ai_flutter/src/models/hasab_exception.dart';

/// Helper class for handling runtime permissions
class PermissionsHelper {
  /// Request microphone permission for audio recording
  ///
  /// Returns true if permission is granted, false otherwise
  ///
  /// Throws [HasabException] if permission is permanently denied
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      throw HasabException(
        message:
            'Microphone permission is permanently denied. Please enable it in app settings.',
        details: 'Permission status: ${status.name}',
      );
    }

    // Request permission
    final result = await Permission.microphone.request();

    if (result.isGranted) {
      return true;
    }

    if (result.isPermanentlyDenied) {
      throw HasabException(
        message:
            'Microphone permission is permanently denied. Please enable it in app settings.',
        details: 'Permission status: ${result.name}',
      );
    }

    return false;
  }

  /// Request storage permission for saving/reading audio files
  ///
  /// Returns true if permission is granted, false otherwise
  static Future<bool> requestStoragePermission() async {
    // For Android 13+ (API 33+), storage permissions are handled differently
    // We request audio permission instead
    final status = await Permission.audio.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      // Not critical, just inform user
      return false;
    }

    final result = await Permission.audio.request();
    return result.isGranted;
  }

  /// Request all necessary permissions for audio recording
  ///
  /// Returns true if all required permissions are granted
  ///
  /// Throws [HasabException] if critical permissions are denied
  static Future<bool> requestAudioPermissions() async {
    final micPermission = await requestMicrophonePermission();
    await requestStoragePermission(); // Optional, just try to get it

    // Microphone is critical, storage is optional
    return micPermission;
  }

  /// Check if microphone permission is granted
  static Future<bool> hasMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Open app settings for user to manually enable permissions
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Check all audio-related permissions and return their status
  static Future<Map<String, bool>> checkAllPermissions() async {
    return {
      'microphone': await Permission.microphone.isGranted,
      'audio': await Permission.audio.isGranted,
      'storage': await Permission.storage.isGranted,
    };
  }
}
