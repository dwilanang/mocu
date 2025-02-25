import 'package:audioplayers/audioplayers.dart';

class AudioUtils {
  final Map<String, AudioPlayer> _soundPlayers = {};

  void play(String name, {Function? onComplete, bool loop = false}) async {
    if (_soundPlayers.containsKey(name)) {
      await _soundPlayers[name]!.stop();
    } else {
      _soundPlayers[name] = AudioPlayer();
    }

    _soundPlayers[name]!.onPlayerComplete.listen((event) {
      if (onComplete != null) {
        onComplete();
      }
    });

    if (loop) {
      _soundPlayers[name]!.setReleaseMode(ReleaseMode.loop);
    } else {
      _soundPlayers[name]!.setReleaseMode(ReleaseMode.stop);
    }

    await _soundPlayers[name]!.setSource(AssetSource('audios/$name.wav'));
    await _soundPlayers[name]!.resume();
  }

  void stop(String name) async {
    if (_soundPlayers.containsKey(name)) {
      await _soundPlayers[name]!.stop();
    }
  }

  void stopAll() async {
    for (var player in _soundPlayers.values) {
      await player.stop();
    }
  }
}