class Language {
  final String name;
  final String nativeName;
  final String code;
  final String flag;

  const Language({
    required this.name,
    required this.nativeName,
    required this.code,
    required this.flag,
  });

  // Predefined languages
  static const Language english = Language(
    name: 'English',
    nativeName: 'English',
    code: 'en',
    flag: '🇺🇸',
  );

  static const Language french = Language(
    name: 'French',
    nativeName: 'Français',
    code: 'fr',
    flag: '🇫🇷',
  );

  static const Language spanish = Language(
    name: 'Spanish',
    nativeName: 'Español',
    code: 'es',
    flag: '🇪🇸',
  );

  static const Language arabic = Language(
    name: 'Arabic',
    nativeName: 'العربية',
    code: 'ar',
    flag: '🇸🇦',
  );

  static const Language german = Language(
    name: 'German',
    nativeName: 'Deutsch',
    code: 'de',
    flag: '🇩🇪',
  );

  static const Language italian = Language(
    name: 'Italian',
    nativeName: 'Italiano',
    code: 'it',
    flag: '🇮🇹',
  );

  static const Language portuguese = Language(
    name: 'Portuguese',
    nativeName: 'Português',
    code: 'pt',
    flag: '🇵🇹',
  );

  static const Language chinese = Language(
    name: 'Chinese',
    nativeName: '中文',
    code: 'zh',
    flag: '🇨🇳',
  );

  static const Language japanese = Language(
    name: 'Japanese',
    nativeName: '日本語',
    code: 'ja',
    flag: '🇯🇵',
  );

  static const Language korean = Language(
    name: 'Korean',
    nativeName: '한국어',
    code: 'ko',
    flag: '🇰🇷',
  );

  static const Language russian = Language(
    name: 'Russian',
    nativeName: 'Русский',
    code: 'ru',
    flag: '🇷🇺',
  );

  static const Language hindi = Language(
    name: 'Hindi',
    nativeName: 'हिन्दी',
    code: 'hi',
    flag: '🇮🇳',
  );

  // All available languages
  static const List<Language> allLanguages = [
    english,
    french,
    spanish,
    arabic,
    german,
    italian,
    portuguese,
    chinese,
    japanese,
    korean,
    russian,
    hindi,
  ];

  @override
  String toString() => '$flag $nativeName';
}
