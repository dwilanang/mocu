import 'package:just_audio/just_audio.dart';

class AudioUtils {
  final Map<String, AudioPlayer> _soundPlayers = {};

  Future<void> play(String name, {Function? onComplete, bool loop = false}) async {
    AudioPlayer player = AudioPlayer();
    _soundPlayers[name] = player;

    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (onComplete != null) {
          onComplete();
        }
        if (!loop) {
          player.stop();
        }
      }
    });

    if (loop) {
      await player.setLoopMode(LoopMode.one);
    } else {
      await player.setLoopMode(LoopMode.off);
    }

    await player.setAsset('assets/audios/$name.wav');
    await player.play();
  }

  Future<void> stop(String name) async {
    if (_soundPlayers.containsKey(name)) {
      await _soundPlayers[name]!.stop();
      _soundPlayers.remove(name);
    }
  }

  Future<void> stopAll() async {
    if (_soundPlayers.isEmpty) return;

    for (var entry in _soundPlayers.entries.toList()) {
      await entry.value.stop();
      _soundPlayers.remove(entry.key);
    }
  }

  Future<void> setVolume(String name, double volume) async {
    if (_soundPlayers.containsKey(name)) {
      await _soundPlayers[name]!.setVolume(volume);
    }
  }
}