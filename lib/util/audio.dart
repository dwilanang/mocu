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
      try {
        await _soundPlayers[name]!.stop();
      } catch (_) {}
      _soundPlayers.remove(name);
    }
  }

  Future<void> stopAll() async {
    if (_soundPlayers.isEmpty) return;

    // Buat salinan list agar tidak terjadi concurrent modification
    final players = List<AudioPlayer>.from(_soundPlayers.values);

    for (var player in players) {
      try {
        await player.stop();
      } catch (_) {}
    }
    _soundPlayers.clear();
  }

  Future<void> setVolume(String name, double volume) async {
    if (_soundPlayers.containsKey(name)) {
      await _soundPlayers[name]!.setVolume(volume);
    }
  }
}