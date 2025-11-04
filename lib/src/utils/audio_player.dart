import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:hasab_ai_flutter/src/models/hasab_exception.dart';

/// Audio player utility for TTS playback
class AudioPlayerHelper {
  final AudioPlayer _player;

  /// Stream of playback state changes
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// Stream of playback position updates
  Stream<Duration> get positionStream => _player.positionStream;

  /// Stream of playback duration updates
  Stream<Duration?> get durationStream => _player.durationStream;

  /// Check if audio is currently playing
  bool get isPlaying => _player.playing;

  /// Get current playback position
  Duration get position => _player.position;

  /// Get total duration of current audio
  Duration? get duration => _player.duration;

  /// Get current playback speed
  double get speed => _player.speed;

  /// Get current volume (0.0 to 1.0)
  double get volume => _player.volume;

  /// Create a new audio player helper
  AudioPlayerHelper() : _player = AudioPlayer();

  /// Play audio from a file path
  ///
  /// [filePath] Path to the audio file
  /// [autoPlay] Whether to start playing automatically
  ///
  /// Returns the duration of the audio
  Future<Duration?> playFromFile(
    String filePath, {
    bool autoPlay = true,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw HasabFileException(
          message: 'Audio file does not exist: $filePath',
        );
      }

      final duration = await _player.setFilePath(filePath);

      if (autoPlay) {
        await _player.play();
      }

      return duration;
    } catch (e) {
      if (e is HasabException) rethrow;
      throw HasabException(
        message: 'Failed to play audio file',
        details: e.toString(),
      );
    }
  }

  /// Play audio from a URL
  ///
  /// [url] URL of the audio file
  /// [autoPlay] Whether to start playing automatically
  ///
  /// Returns the duration of the audio
  Future<Duration?> playFromUrl(String url, {bool autoPlay = true}) async {
    try {
      final duration = await _player.setUrl(url);

      if (autoPlay) {
        await _player.play();
      }

      return duration;
    } catch (e) {
      throw HasabException(
        message: 'Failed to play audio from URL',
        details: e.toString(),
      );
    }
  }

  /// Play audio from bytes
  ///
  /// [bytes] Audio data as bytes
  /// [autoPlay] Whether to start playing automatically
  ///
  /// Returns the duration of the audio
  Future<Duration?> playFromBytes(
    List<int> bytes, {
    bool autoPlay = true,
  }) async {
    try {
      // Create a temporary file
      final tempDir = Directory.systemTemp;
      final tempFile = File(
        '${tempDir.path}/hasab_temp_audio_${DateTime.now().millisecondsSinceEpoch}.mp3',
      );
      await tempFile.writeAsBytes(bytes);

      final duration = await playFromFile(tempFile.path, autoPlay: autoPlay);

      // Clean up temp file after playback
      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          tempFile.delete().catchError((_) => tempFile);
        }
      });

      return duration;
    } catch (e) {
      if (e is HasabException) rethrow;
      throw HasabException(
        message: 'Failed to play audio from bytes',
        details: e.toString(),
      );
    }
  }

  /// Resume playback
  Future<void> play() async {
    try {
      await _player.play();
    } catch (e) {
      throw HasabException(
        message: 'Failed to play audio',
        details: e.toString(),
      );
    }
  }

  /// Pause playback
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      throw HasabException(
        message: 'Failed to pause audio',
        details: e.toString(),
      );
    }
  }

  /// Stop playback and reset position
  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      throw HasabException(
        message: 'Failed to stop audio',
        details: e.toString(),
      );
    }
  }

  /// Seek to a specific position
  ///
  /// [position] The position to seek to
  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      throw HasabException(
        message: 'Failed to seek audio',
        details: e.toString(),
      );
    }
  }

  /// Set playback speed
  ///
  /// [speed] Playback speed (0.5 to 2.0 typically)
  Future<void> setSpeed(double speed) async {
    try {
      await _player.setSpeed(speed);
    } catch (e) {
      throw HasabException(
        message: 'Failed to set playback speed',
        details: e.toString(),
      );
    }
  }

  /// Set volume
  ///
  /// [volume] Volume level (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      if (volume < 0.0 || volume > 1.0) {
        throw HasabValidationException(
          message: 'Volume must be between 0.0 and 1.0',
          details: 'Provided volume: $volume',
        );
      }
      await _player.setVolume(volume);
    } catch (e) {
      if (e is HasabException) rethrow;
      throw HasabException(
        message: 'Failed to set volume',
        details: e.toString(),
      );
    }
  }

  /// Set loop mode
  ///
  /// [loop] Whether to loop the audio
  Future<void> setLooping(bool loop) async {
    try {
      await _player.setLoopMode(loop ? LoopMode.one : LoopMode.off);
    } catch (e) {
      throw HasabException(
        message: 'Failed to set loop mode',
        details: e.toString(),
      );
    }
  }

  /// Dispose and clean up resources
  Future<void> dispose() async {
    await _player.dispose();
  }
}
