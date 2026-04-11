/// Reference utterances for QA, docs, and LLM regression (all map to the same intent family).
abstract final class VoiceCommandExamples {
  static const wifiDisableMacedonian = 'Отвори подесувања и исклучи WiFi';
  static const wifiDisableEnglish = 'Open settings and turn off WiFi';
  static const wifiDisableAlbanian = 'Hap cilësimet dhe fik WiFi';

  static const openSettingsMk = 'Отвори поставки';
  static const openSettingsEn = 'Open settings';
  static const openSettingsSq = 'Hap cilësimet';

  static const brailleMk = 'Брајова азбука';
  static const pictureBookSq = 'Mëso dhe dëgjo';

  /// Example normalized JSON shape from the LLM layer (params may be nested or flat).
  static const wifiDisableIntentJson = '''
{
  "action": "system_wifi",
  "params": { "state": "disable" },
  "detected_language": "mk-MK",
  "confidence": 0.95,
  "requires_confirmation": true
}
''';
}
