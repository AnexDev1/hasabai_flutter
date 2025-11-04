/// Supported languages for Hasab AI services
enum HasabLanguage {
  /// Amharic language
  amharic('amh', 'Amharic'),

  /// Oromo language
  oromo('orm', 'Oromo'), // Fixed: was 'oro', should be 'orm' (ISO 639-3)

  /// Tigrinya language
  tigrinya('tir', 'Tigrinya'),

  /// English language
  english('eng', 'English');

  /// Language code (ISO 639-3)
  final String code;

  /// Language display name
  final String displayName;

  const HasabLanguage(this.code, this.displayName);

  /// Get language from code
  static HasabLanguage fromCode(String code) {
    return HasabLanguage.values.firstWhere(
      (lang) => lang.code.toLowerCase() == code.toLowerCase(),
      orElse: () => HasabLanguage.english,
    );
  }

  /// Get all supported language codes
  static List<String> get supportedCodes =>
      HasabLanguage.values.map((lang) => lang.code).toList();

  @override
  String toString() => displayName;
}
