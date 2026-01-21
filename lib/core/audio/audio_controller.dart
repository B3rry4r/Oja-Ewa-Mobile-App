import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioController extends Notifier<bool> {
  late final AudioPlayer _player;
  bool _initialized = false;
  bool _sourceSet = false;

  @override
  bool build() {
    _player = AudioPlayer();
    _player.setReleaseMode(ReleaseMode.loop);
    
    // Listen for player state changes to keep UI in sync
    _player.onPlayerStateChanged.listen((PlayerState playerState) {
      final isPlaying = playerState == PlayerState.playing;
      if (state != isPlaying) {
        state = isPlaying;
      }
    });
    
    // Listen for errors
    _player.onLog.listen((String message) {
      debugPrint('AudioPlayer log: $message');
    });
    
    ref.onDispose(() {
      _player.dispose();
    });
    return false;
  }

  bool get isPlaying => state;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    
    try {
      // For mobile platforms, we need to set the source differently
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        // On mobile, use AssetSource with just the filename (assets/ prefix is automatic)
        await _player.setSource(AssetSource('ojaewa.mpeg'));
      } else {
        // On web, AssetSource works directly
        await _player.setSource(AssetSource('ojaewa.mpeg'));
      }
      _sourceSet = true;
      debugPrint('AudioPlayer: Source set successfully');
      await play();
    } catch (e) {
      debugPrint('AudioPlayer: Error setting source: $e');
      _sourceSet = false;
    }
  }

  Future<void> play() async {
    if (!_sourceSet) {
      debugPrint('AudioPlayer: Cannot play - source not set');
      return;
    }
    try {
      await _player.resume();
      state = true;
    } catch (e) {
      debugPrint('AudioPlayer: Error playing: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
      state = false;
    } catch (e) {
      debugPrint('AudioPlayer: Error pausing: $e');
    }
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
