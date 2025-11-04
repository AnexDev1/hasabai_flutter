import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hasab_ai_flutter/src/utils/audio_recorder.dart';
import 'package:hasab_ai_flutter/src/services/speech_to_text.dart';
import 'package:hasab_ai_flutter/src/models/language.dart';

/// A prebuilt voice input field widget with recording and transcription
class VoiceInputField extends StatefulWidget {
  /// The speech-to-text service
  final SpeechToTextService speechToTextService;

  /// Callback when transcription is complete
  final void Function(String text) onTranscriptionComplete;

  /// Optional language hint for transcription
  final HasabLanguage? language;

  /// Decoration for the text field
  final InputDecoration? decoration;

  /// Controller for the text field
  final TextEditingController? controller;

  /// Whether the field is enabled
  final bool enabled;

  const VoiceInputField({
    super.key,
    required this.speechToTextService,
    required this.onTranscriptionComplete,
    this.language,
    this.decoration,
    this.controller,
    this.enabled = true,
  });

  @override
  State<VoiceInputField> createState() => _VoiceInputFieldState();
}

class _VoiceInputFieldState extends State<VoiceInputField> {
  final AudioRecorder _recorder = AudioRecorder();
  late final TextEditingController _controller;
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    try {
      await _recorder.initialize();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      setState(() {
        _errorMessage = null;
        _isRecording = true;
      });

      await _recorder.startRecording();
    } catch (e) {
      setState(() {
        _isRecording = false;
        _errorMessage = 'Failed to start recording: $e';
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      final recordingPath = await _recorder.stopRecording();
      if (recordingPath != null) {
        await _transcribeAudio(recordingPath);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Failed to stop recording: $e';
      });
    }
  }

  Future<void> _transcribeAudio(String audioPath) async {
    try {
      final audioFile = File(audioPath);
      final response = await widget.speechToTextService.transcribe(
        audioFile,
        language: widget.language?.code ?? 'auto',
      );

      _controller.text = response.text;
      widget.onTranscriptionComplete(response.text);

      // Clean up the recording file
      await audioFile.delete();
    } catch (e) {
      setState(() {
        _errorMessage = 'Transcription failed: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    _recorder.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          enabled: widget.enabled && !_isProcessing,
          decoration: (widget.decoration ?? const InputDecoration()).copyWith(
            suffixIcon: _buildRecordButton(),
          ),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
        if (_isProcessing)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildRecordButton() {
    if (_isProcessing) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return IconButton(
      icon: Icon(
        _isRecording ? Icons.stop : Icons.mic,
        color: _isRecording ? Colors.red : null,
      ),
      onPressed: widget.enabled ? _toggleRecording : null,
      tooltip: _isRecording ? 'Stop recording' : 'Start recording',
    );
  }
}
