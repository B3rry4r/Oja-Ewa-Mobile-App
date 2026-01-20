import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioController extends Notifier<bool> {
  late final AudioPlayer _player;
  bool _initialized = false;

  @override
  bool build() {
    _player = AudioPlayer();
    _player.setReleaseMode(ReleaseMode.loop);
    ref.onDispose(() {
      _player.dispose();
    });
    return false;
  }

  bool get isPlaying => state;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await _player.setSource(AssetSource('ojaewa.mpeg'));
    await play();
  }

  Future<void> play() async {
    await _player.resume();
    state = true;
  }

  Future<void> pause() async {
    await _player.pause();
    state = false;
  }

  Future<void> toggle() async {
    if (state) {
      await pause();
    } else {
      await play();
    }
  }
}

final audioControllerProvider = NotifierProvider<AudioController, bool>(
  AudioController.new,
);
