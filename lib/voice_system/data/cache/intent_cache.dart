import '../../domain/entities/voice_intent.dart';
import '../../voice_system_config.dart';

/// LRU-style cache for frequent voice intents (reduces LLM latency).
class IntentCache {
  IntentCache(this._config);

  final VoiceSystemConfig _config;
  final Map<String, _Entry> _map = {};

  String _key(String transcript) =>
      transcript.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

  VoiceIntent? get(String transcript) {
    final k = _key(transcript);
    final e = _map[k];
    if (e == null) return null;
    if (DateTime.now().difference(e.at) > _config.intentCacheTtl) {
      _map.remove(k);
      return null;
    }
    return e.intent;
  }

  void put(String transcript, VoiceIntent intent) {
    final k = _key(transcript);
    if (_map.length >= _config.intentCacheMaxEntries) {
      final oldestKey = _map.entries
          .reduce((a, b) => a.value.at.isBefore(b.value.at) ? a : b)
          .key;
      _map.remove(oldestKey);
    }
    _map[k] = _Entry(intent, DateTime.now());
  }

  void clear() => _map.clear();
}

class _Entry {
  _Entry(this.intent, this.at);

  final VoiceIntent intent;
  final DateTime at;
}
