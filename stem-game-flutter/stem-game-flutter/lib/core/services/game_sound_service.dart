import 'package:flame_audio/flame_audio.dart';

class GameSoundService {
  static bool _initialized = false;
  static bool _enabled = true;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      await FlameAudio.audioCache.loadAll([
        'sfx/tap.wav',
        'sfx/correct.wav',
        'sfx/wrong.wav',
        'sfx/complete.wav',
        'sfx/drag.wav',
        'sfx/drop.wav',
        'sfx/flip.wav',
        'sfx/match.wav',
        'sfx/star.wav',
        'sfx/hint.wav',
      ]);
      _initialized = true;
    } catch (e) {
      // Audio init failed - disable sounds gracefully
      _enabled = false;
    }
  }

  static void setEnabled(bool enabled) => _enabled = enabled;

  static void _play(String file) {
    if (!_enabled) return;
    try {
      FlameAudio.play(file);
    } catch (_) {
      // Silently ignore audio errors
    }
  }

  static void playTap() => _play('sfx/tap.wav');
  static void playCorrect() => _play('sfx/correct.wav');
  static void playWrong() => _play('sfx/wrong.wav');
  static void playComplete() => _play('sfx/complete.wav');
  static void playDrag() => _play('sfx/drag.wav');
  static void playDrop() => _play('sfx/drop.wav');
  static void playFlip() => _play('sfx/flip.wav');
  static void playMatch() => _play('sfx/match.wav');
  static void playStar() => _play('sfx/star.wav');
  static void playHint() => _play('sfx/hint.wav');
}
