/// BCP-47 tags used across STT/TTS and the LLM layer.
enum SupportedVoiceLanguage {
  macedonian('mk', 'mk-MK'),
  english('en', 'en-US'),
  albanian('sq', 'sq-AL');

  const SupportedVoiceLanguage(this.languageCode, this.bcp47);

  final String languageCode;
  final String bcp47;

  static SupportedVoiceLanguage? tryParseBcp47(String? tag) {
    if (tag == null || tag.isEmpty) return null;
    final t = tag.toLowerCase();
    if (t.startsWith('mk')) return SupportedVoiceLanguage.macedonian;
    if (t.startsWith('sq')) return SupportedVoiceLanguage.albanian;
    if (t.startsWith('en')) return SupportedVoiceLanguage.english;
    return null;
  }

  /// App UI language codes (`mk`, `en`, `sq`) from [AppStateProvider].
  static SupportedVoiceLanguage fromUiLanguageCode(String code) {
    switch (code.toLowerCase()) {
      case 'mk':
        return SupportedVoiceLanguage.macedonian;
      case 'sq':
        return SupportedVoiceLanguage.albanian;
      case 'en':
      default:
        return SupportedVoiceLanguage.english;
    }
  }

  /// Priority order for language hinting: Macedonian first (product requirement).
  static const List<SupportedVoiceLanguage> sttPriority = [
    SupportedVoiceLanguage.macedonian,
    SupportedVoiceLanguage.english,
    SupportedVoiceLanguage.albanian,
  ];
}
