import 'package:flutter/material.dart';
import 'package:hasab_ai_flutter/hasab_ai_flutter.dart';

void main() {
  runApp(const HasabAIExampleApp());
}

class HasabAIExampleApp extends StatelessWidget {
  const HasabAIExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hasab AI SDK Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HasabAI _hasab;
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayerHelper _player = AudioPlayerHelper();
  bool _permissionsGranted = false;
  String _permissionStatus = 'Checking...';

  @override
  void initState() {
    super.initState();
    // Initialize Hasab AI SDK
    _hasab = HasabAI(apiKey: 'HASAB_KEY_we4C2GPjbWXB2RJ0B2dh5Cit1QL02I');
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      await _recorder.initialize();
      setState(() {
        _permissionsGranted = true;
        _permissionStatus = '✅ Microphone permission granted';
      });
    } catch (e) {
      setState(() {
        _permissionsGranted = false;
        _permissionStatus = '⚠️ Microphone permission required';
      });
    }
  }

  Future<void> _requestPermissions() async {
    try {
      final granted = await PermissionsHelper.requestAudioPermissions();
      setState(() {
        _permissionsGranted = granted;
        _permissionStatus = granted
            ? '✅ Microphone permission granted'
            : '❌ Permission denied';
      });
    } catch (e) {
      setState(() {
        _permissionStatus = '❌ ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _hasab.dispose();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasab AI SDK Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'SDK Updated to Hasab AI API v1',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Language codes: amh (Amharic), oro (Oromo), tir (Tigrinya), eng (English)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'TTS Speakers: 15 voices available across all languages',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: _permissionsGranted
                ? Colors.green.shade50
                : Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    _permissionsGranted ? Icons.mic : Icons.mic_off,
                    color: _permissionsGranted
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _permissionStatus,
                      style: TextStyle(
                        color: _permissionsGranted
                            ? Colors.green.shade900
                            : Colors.orange.shade900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (!_permissionsGranted)
                    TextButton(
                      onPressed: _requestPermissions,
                      child: const Text('Grant'),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Quick Start Examples'),
          const SizedBox(height: 12),
          _buildFeatureCard(
            context,
            'Speech to Text',
            'Convert voice recordings to text',
            Icons.mic,
            Colors.blue,
            () => _navigateToSpeechToText(context),
          ),
          _buildFeatureCard(
            context,
            'Text to Speech',
            'Generate audio from text',
            Icons.volume_up,
            Colors.green,
            () => _navigateToTextToSpeech(context),
          ),
          _buildFeatureCard(
            context,
            'Translation',
            'Translate between languages',
            Icons.translate,
            Colors.orange,
            () => _navigateToTranslation(context),
          ),
          _buildFeatureCard(
            context,
            'Chat',
            'Interact with Hasab AI',
            Icons.chat,
            Colors.purple,
            () => _navigateToChat(context),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Complete Demo'),
          const SizedBox(height: 12),
          _buildFeatureCard(
            context,
            'Full Workflow',
            'Record → Transcribe → Translate → TTS → Chat',
            Icons.rocket_launch,
            Colors.red,
            () => _navigateToFullDemo(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _navigateToSpeechToText(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SpeechToTextDemo(hasab: _hasab)),
    );
  }

  void _navigateToTextToSpeech(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TextToSpeechDemo(hasab: _hasab, player: _player),
      ),
    );
  }

  void _navigateToTranslation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TranslationDemo(hasab: _hasab)),
    );
  }

  void _navigateToChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatDemo(hasab: _hasab)),
    );
  }

  void _navigateToFullDemo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullWorkflowDemo(
          hasab: _hasab,
          recorder: _recorder,
          player: _player,
        ),
      ),
    );
  }
}

// Speech to Text Demo Page
class SpeechToTextDemo extends StatefulWidget {
  final HasabAI hasab;

  const SpeechToTextDemo({super.key, required this.hasab});

  @override
  State<SpeechToTextDemo> createState() => _SpeechToTextDemoState();
}

class _SpeechToTextDemoState extends State<SpeechToTextDemo> {
  String _transcription = '';
  HasabLanguage _selectedLanguage = HasabLanguage.amharic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Speech to Text')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Use the VoiceInputField widget for easy voice recording and transcription:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          VoiceInputField(
            speechToTextService: widget.hasab.speechToText,
            language: _selectedLanguage,
            onTranscriptionComplete: (text) {
              setState(() {
                _transcription = text;
              });
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Transcription: $text')));
            },
            decoration: const InputDecoration(
              labelText: 'Speak or type your message',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<HasabLanguage>(
            initialValue: _selectedLanguage,
            decoration: const InputDecoration(
              labelText: 'Language',
              border: OutlineInputBorder(),
            ),
            items: HasabLanguage.values.map((lang) {
              return DropdownMenuItem(
                value: lang,
                child: Text(lang.displayName),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedLanguage = value;
                });
              }
            },
          ),
          const SizedBox(height: 20),
          if (_transcription.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Transcription Result:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_transcription),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Text to Speech Demo Page
class TextToSpeechDemo extends StatefulWidget {
  final HasabAI hasab;
  final AudioPlayerHelper player;

  const TextToSpeechDemo({
    super.key,
    required this.hasab,
    required this.player,
  });

  @override
  State<TextToSpeechDemo> createState() => _TextToSpeechDemoState();
}

class _TextToSpeechDemoState extends State<TextToSpeechDemo> {
  final TextEditingController _textController = TextEditingController();
  HasabLanguage _selectedLanguage = HasabLanguage.amharic;
  bool _isGenerating = false;
  String? _audioPath;
  String? _selectedSpeaker;
  Map<String, List<String>> _availableSpeakers = {};

  @override
  void initState() {
    super.initState();
    _loadAvailableSpeakers();
    _textController.text = _getSampleTextForLanguage(_selectedLanguage);
  }

  String _getSampleTextForLanguage(HasabLanguage language) {
    switch (language) {
      case HasabLanguage.amharic:
        return 'ሰላም፣ እንዴት ናችሁ? ይህ የሀሳብ AI የድምጽ ማውጫ ናሙና ነው።';
      case HasabLanguage.oromo:
        return 'Akkam jirtu? Kun fakkenya sagalee Hasab AI ti.';
      case HasabLanguage.tigrinya:
        return 'ሰላም፣ ከመይ ኣለኹም? እዚ ናይ ሃሳብ AI ድምጺ ፈተና እዩ።';
      case HasabLanguage.english:
        return 'Hello, how are you? This is a Hasab AI voice synthesis sample.';
    }
  }

  Future<void> _loadAvailableSpeakers() async {
    try {
      final speakers = await widget.hasab.textToSpeech.getAvailableVoices();
      setState(() {
        _availableSpeakers = speakers;
      });
    } catch (e) {
      // Use default speakers if API call fails
      setState(() {
        _availableSpeakers = {
          'amh': ['hanna', 'selam', 'aster', 'yared', 'haile', 'bekele'],
          'oro': ['gallete', 'abdi', 'tolla'],
          'tir': ['yeha', 'selam', 'aster', 'yared', 'haile', 'bekele'],
          'eng': ['default'],
        };
      });
    }
  }

  List<String> _getSpeakersForLanguage() {
    return _availableSpeakers[_selectedLanguage.code] ?? [];
  }

  Future<void> _generateSpeech() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter some text')));
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final response = await widget.hasab.textToSpeech.synthesize(
        _textController.text,
        _selectedLanguage,
        voice: _selectedSpeaker,
      );

      setState(() {
        _audioPath = response.audioFilePath;
      });

      // Auto-play the generated audio
      await widget.player.playFromFile(response.audioFilePath);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech generated and playing!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text to Speech')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: 'Enter text to convert to speech',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<HasabLanguage>(
            initialValue: _selectedLanguage,
            decoration: const InputDecoration(
              labelText: 'Language',
              border: OutlineInputBorder(),
            ),
            items: HasabLanguage.values.map((lang) {
              return DropdownMenuItem(
                value: lang,
                child: Text(lang.displayName),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedLanguage = value;
                  _selectedSpeaker =
                      null; // Reset speaker when language changes
                  _textController.text = _getSampleTextForLanguage(value);
                });
              }
            },
          ),
          const SizedBox(height: 16),
          if (_getSpeakersForLanguage().isNotEmpty)
            DropdownButtonFormField<String>(
              value: _selectedSpeaker,
              decoration: const InputDecoration(
                labelText: 'Voice/Speaker (Optional)',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Default'),
                ),
                ..._getSpeakersForLanguage().map((speaker) {
                  return DropdownMenuItem<String>(
                    value: speaker,
                    child: Text(speaker),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedSpeaker = value;
                });
              },
            ),
          if (_getSpeakersForLanguage().isNotEmpty) const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isGenerating ? null : _generateSpeech,
            icon: _isGenerating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.volume_up),
            label: const Text('Generate Speech'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          if (_audioPath != null) ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Audio Controls',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: () => widget.player.play(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.pause),
                          onPressed: () => widget.player.pause(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.stop),
                          onPressed: () => widget.player.stop(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Translation Demo Page
class TranslationDemo extends StatefulWidget {
  final HasabAI hasab;

  const TranslationDemo({super.key, required this.hasab});

  @override
  State<TranslationDemo> createState() => _TranslationDemoState();
}

class _TranslationDemoState extends State<TranslationDemo> {
  final TextEditingController _textController = TextEditingController();
  HasabLanguage _fromLanguage = HasabLanguage.english;
  HasabLanguage _toLanguage = HasabLanguage.amharic;
  String _translatedText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Translation')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '💡 Hasab AI supports text translation! Enter text and select source/target languages.',
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: 'Enter text to translate',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<HasabLanguage>(
                  initialValue: _fromLanguage,
                  decoration: const InputDecoration(
                    labelText: 'From',
                    border: OutlineInputBorder(),
                  ),
                  items: HasabLanguage.values.map((lang) {
                    return DropdownMenuItem(
                      value: lang,
                      child: Text(lang.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _fromLanguage = value;
                      });
                    }
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward),
              ),
              Expanded(
                child: DropdownButtonFormField<HasabLanguage>(
                  initialValue: _toLanguage,
                  decoration: const InputDecoration(
                    labelText: 'To',
                    border: OutlineInputBorder(),
                  ),
                  items: HasabLanguage.values.map((lang) {
                    return DropdownMenuItem(
                      value: lang,
                      child: Text(lang.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _toLanguage = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TranslateButton(
            translationService: widget.hasab.translation,
            getText: () => _textController.text,
            fromLanguage: _fromLanguage,
            toLanguage: _toLanguage,
            onTranslationComplete: (translatedText) {
              setState(() {
                _translatedText = translatedText;
              });
            },
            onError: (error) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: $error')));
            },
          ),
          const SizedBox(height: 20),
          if (_translatedText.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Translation:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_translatedText, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Chat Demo Page
class ChatDemo extends StatelessWidget {
  final HasabAI hasab;

  const ChatDemo({super.key, required this.hasab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat with Hasab AI')),
      body: Column(
        children: [
          Container(
            color: Colors.purple.shade50,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.smart_toy, color: Colors.purple.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Models: hasab-1-lite (default) or hasab-1-main\nSupports: text, images, streaming',
                    style: TextStyle(
                      color: Colors.purple.shade900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ChatWidget(
              chatService: hasab.chat,
              showTimestamps: true,
              inputPlaceholder: 'Ask me anything...',
              onMessageSent: (message) {
                print('User sent: $message');
              },
              onResponseReceived: (response) {
                print('AI responded: ${response.message}');
              },
              onError: (error) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $error')));
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Full Workflow Demo Page
class FullWorkflowDemo extends StatefulWidget {
  final HasabAI hasab;
  final AudioRecorder recorder;
  final AudioPlayerHelper player;

  const FullWorkflowDemo({
    super.key,
    required this.hasab,
    required this.recorder,
    required this.player,
  });

  @override
  State<FullWorkflowDemo> createState() => _FullWorkflowDemoState();
}

class _FullWorkflowDemoState extends State<FullWorkflowDemo> {
  int _currentStep = 0;
  String _recordedText = '';
  String _translatedText = '';
  String _ttsAudioPath = '';
  String _chatResponse = '';
  final HasabLanguage _sourceLanguage = HasabLanguage.amharic;
  final HasabLanguage _targetLanguage = HasabLanguage.english;

  final List<String> _stepTitles = [
    'Record Voice',
    'Transcribe',
    'Translate',
    'Text-to-Speech',
    'Chat',
  ];

  Future<void> _executeStep(int step) async {
    try {
      switch (step) {
        case 0:
          // Recording is handled by VoiceInputField
          break;
        case 1:
          // Transcription is auto-handled by VoiceInputField
          break;
        case 2:
          if (_recordedText.isEmpty) {
            throw Exception('No text to translate');
          }
          final translation = await widget.hasab.translation.translate(
            _recordedText,
            _sourceLanguage,
            _targetLanguage,
          );
          setState(() {
            _translatedText = translation.translatedText;
          });
          break;
        case 3:
          if (_translatedText.isEmpty) {
            throw Exception('No translated text for TTS');
          }
          final tts = await widget.hasab.textToSpeech.synthesize(
            _translatedText,
            _targetLanguage,
          );
          setState(() {
            _ttsAudioPath = tts.audioFilePath;
          });
          await widget.player.playFromFile(tts.audioFilePath);
          break;
        case 4:
          final chat = await widget.hasab.chat.sendMessage(
            'Translate this to ${_targetLanguage.displayName}: $_recordedText',
          );
          setState(() {
            _chatResponse = chat.message;
          });
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Full Workflow Demo')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < _stepTitles.length - 1) {
            setState(() {
              _currentStep++;
            });
            _executeStep(_currentStep);
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep--;
            });
          }
        },
        steps: [
          Step(
            title: const Text('Record Voice'),
            content: VoiceInputField(
              speechToTextService: widget.hasab.speechToText,
              language: _sourceLanguage,
              onTranscriptionComplete: (text) {
                setState(() {
                  _recordedText = text;
                });
              },
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('View Transcription'),
            content: Text(
              _recordedText.isEmpty ? 'No transcription yet' : _recordedText,
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Translate'),
            content: Column(
              children: [
                Text(
                  _translatedText.isEmpty
                      ? 'Translation will appear here'
                      : _translatedText,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '${_sourceLanguage.displayName} → ${_targetLanguage.displayName}',
                    ),
                  ],
                ),
              ],
            ),
            isActive: _currentStep >= 2,
          ),
          Step(
            title: const Text('Text-to-Speech'),
            content: Text(
              _ttsAudioPath.isEmpty
                  ? 'Audio will be generated'
                  : 'Audio generated and playing!',
            ),
            isActive: _currentStep >= 3,
          ),
          Step(
            title: const Text('Chat Response'),
            content: Text(
              _chatResponse.isEmpty
                  ? 'AI response will appear here'
                  : _chatResponse,
            ),
            isActive: _currentStep >= 4,
          ),
        ],
      ),
    );
  }
}
