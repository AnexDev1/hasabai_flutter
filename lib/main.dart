import 'package:flutter/material.dart';
import 'package:hasab_ai_flutter/hasab_ai_flutter.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late HasabAI _hasab;
  String _result = '';

  @override
  void initState() {
    super.initState();
    // Initialize Hasab AI
    _hasab = HasabAI(apiKey: 'HASAB_KEY_we4C2GPjbWXB2RJ0B2dh5Cit1QL02I');
  }

  @override
  void dispose() {
    _hasab.dispose();
    super.dispose();
  }

  Future<void> _testTranslation() async {
    try {
      final response = await _hasab.translation.translate(
        'Hello World',
        HasabLanguage.english,
        HasabLanguage.amharic,
      );
      setState(() {
        _result = 'Translation: ${response.translatedText}';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hasab AI SDK Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Hasab AI Flutter SDK'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Hasab AI SDK Example',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Supported Languages:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                ...HasabLanguage.values.map(
                  (lang) => Text(
                    '• ${lang.displayName}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _testTranslation,
                  icon: const Icon(Icons.translate),
                  label: const Text('Test Translation'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_result.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _result,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                const Text(
                  'See example/main.dart for complete demos',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
