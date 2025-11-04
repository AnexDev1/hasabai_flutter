import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hasab_ai_flutter/src/models/hasab_exception.dart';

/// Audio recorder utility for voice input
class AudioRecorder {
  FlutterSoundRecorder? _recorder;
  String? _currentRecordingPath;
  bool _isInitialized = false;

  /// Check if the recorder is currently recording
  bool get isRecording => _recorder?.isRecording ?? false;

  /// Get the current recording path
  String? get currentRecordingPath => _currentRecordingPath;

  /// Initialize the audio recorder
  ///
  /// Requests microphone permission and sets up the recorder
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Request microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      throw HasabException(
        message: 'Microphone permission is required for audio recording',
      );
    }

    _recorder = FlutterSoundRecorder();
    await _recorder!.openRecorder();
    _isInitialized = true;
  }

  /// Start recording audio
  ///
  /// [outputPath] Optional custom output path for the recording
  ///
  /// Returns the path where the recording is being saved
  Future<String> startRecording({String? outputPath}) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (isRecording) {
      throw HasabException(message: 'Recording is already in progress');
    }

    try {
      // Generate output path if not provided
      _currentRecordingPath = outputPath ?? await _generateOutputPath();

      await _recorder!.startRecorder(
        toFile: _currentRecordingPath,
        codec: Codec.aacMP4,
      );

      return _currentRecordingPath!;
    } catch (e) {
      throw HasabException(
        message: 'Failed to start recording',
        details: e.toString(),
      );
    }
  }

  /// Stop recording audio
  ///
  /// Returns the path to the recorded audio file
  Future<String?> stopRecording() async {
    if (!isRecording) {
      throw HasabException(message: 'No recording in progress');
    }

    try {
      await _recorder!.stopRecorder();
      final path = _currentRecordingPath;
      _currentRecordingPath = null;
      return path;
    } catch (e) {
      throw HasabException(
        message: 'Failed to stop recording',
        details: e.toString(),
      );
    }
  }

  /// Pause the current recording
  Future<void> pauseRecording() async {
    if (!isRecording) {
      throw HasabException(message: 'No recording in progress');
    }

    try {
      await _recorder!.pauseRecorder();
    } catch (e) {
      throw HasabException(
        message: 'Failed to pause recording',
        details: e.toString(),
      );
    }
  }

  /// Resume a paused recording
  Future<void> resumeRecording() async {
    try {
      await _recorder!.resumeRecorder();
    } catch (e) {
      throw HasabException(
        message: 'Failed to resume recording',
        details: e.toString(),
      );
    }
  }

  /// Get the current recording duration in milliseconds
  Future<int?> getRecordingDuration() async {
    if (!isRecording) return null;

    // This would require tracking start time and calculating duration
    // For simplicity, returning null
    return null;
  }

  /// Generate a default output path for recordings
  Future<String> _generateOutputPath() async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${directory.path}/hasab_recording_$timestamp.m4a';
  }

  /// Dispose and clean up resources
  Future<void> dispose() async {
    if (_recorder != null) {
      if (isRecording) {
        await stopRecording();
      }
      await _recorder!.closeRecorder();
      _recorder = null;
      _isInitialized = false;
    }
  }

  /// Delete a recording file
  Future<bool> deleteRecording(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      throw HasabFileException(
        message: 'Failed to delete recording',
        details: e.toString(),
      );
    }
  }

  /// Get recording file size in bytes
  Future<int?> getRecordingSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
