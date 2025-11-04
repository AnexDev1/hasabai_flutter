/// Hasab AI Flutter SDK
///
/// A comprehensive Flutter SDK for Hasab AI - speech-to-text, text-to-speech,
/// translation, and chat capabilities for Ethiopian languages.
///
/// Supports: Amharic, Oromo, Tigrinya, and English
library;

// Main SDK class
export 'src/hasab_ai.dart';

// Services
export 'src/services/speech_to_text.dart';
export 'src/services/text_to_speech.dart';
export 'src/services/translation.dart';
export 'src/services/chat.dart';

// Models
export 'src/models/language.dart';
export 'src/models/request_models.dart';
export 'src/models/response_models.dart';
export 'src/models/hasab_exception.dart';

// Utilities
export 'src/utils/audio_recorder.dart';
export 'src/utils/audio_player.dart';
export 'src/utils/permissions_helper.dart';

// Widgets
export 'src/widgets/voice_input_field.dart';
export 'src/widgets/translate_button.dart';
export 'src/widgets/chat_widget.dart';
