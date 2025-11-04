import 'package:flutter/material.dart';
import 'package:hasab_ai_flutter/src/services/translation.dart';
import 'package:hasab_ai_flutter/src/models/language.dart';

/// A prebuilt translate button widget
class TranslateButton extends StatefulWidget {
  /// The translation service
  final TranslationService translationService;

  /// Function to get the current text to translate
  final String Function() getText;

  /// Source language
  final HasabLanguage fromLanguage;

  /// Target language
  final HasabLanguage toLanguage;

  /// Callback when translation is complete
  final void Function(String translatedText) onTranslationComplete;

  /// Callback when translation fails
  final void Function(String error)? onError;

  /// Button text
  final String? buttonText;

  /// Button icon
  final IconData? icon;

  /// Button style
  final ButtonStyle? style;

  const TranslateButton({
    super.key,
    required this.translationService,
    required this.getText,
    required this.fromLanguage,
    required this.toLanguage,
    required this.onTranslationComplete,
    this.onError,
    this.buttonText,
    this.icon,
    this.style,
  });

  @override
  State<TranslateButton> createState() => _TranslateButtonState();
}

class _TranslateButtonState extends State<TranslateButton> {
  bool _isTranslating = false;

  Future<void> _translate() async {
    if (_isTranslating) return;

    final text = widget.getText();
    if (text.trim().isEmpty) {
      widget.onError?.call('Text cannot be empty');
      return;
    }

    setState(() {
      _isTranslating = true;
    });

    try {
      final response = await widget.translationService.translate(
        text,
        widget.fromLanguage,
        widget.toLanguage,
      );

      widget.onTranslationComplete(response.translatedText);
    } catch (e) {
      widget.onError?.call(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isTranslating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isTranslating ? null : _translate,
      icon: _isTranslating
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(widget.icon ?? Icons.translate),
      label: Text(widget.buttonText ?? 'Translate'),
      style: widget.style,
    );
  }
}
