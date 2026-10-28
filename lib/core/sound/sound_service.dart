import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Sound cues for Lumina financial micro-interactions
enum LuminaSound {
  transferSuccess('assets/sounds/transfer_success.wav'),
  wireSend('assets/sounds/wire_send.wav'),
  moneyReceived('assets/sounds/money_received.wav'),
  biometricUnlock('assets/sounds/biometric_unlock.wav'),
  errorAlert('assets/sounds/error_alert.wav'),
  cardClick('assets/sounds/card_click.wav'),
  vaultLock('assets/sounds/vault_lock.wav');

  final String assetPath;
  const LuminaSound(this.assetPath);
}

/// Bank-grade Low-Latency Sound Design Engine
/// Provides instantaneous audio feedback for financial transfers,
/// biometric challenges, card actions, and error handling.
class SoundService {
  static SoundService _instance = SoundService._internal();
  static SoundService get instance => _instance;

  @visibleForTesting
  static void setMockInstance(SoundService mock) {
    _instance = mock;
  }

  AudioPlayer? _player;
  bool isEnabled = true;
  double _volume = 0.85;

  SoundService._internal() {
    _initPlayer();
  }

  SoundService({AudioPlayer? player, this.isEnabled = true})
      : _player = player;

  void _initPlayer() {
    try {
      _player = AudioPlayer();
      _player?.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            options: const {
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: false,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.assistanceSonification,
            audioFocus: AndroidAudioFocus.none,
          ),
        ),
      );
    } catch (_) {
      // Graceful fallback for non-audio environments
    }
  }

  double get volume => _volume;
  set volume(double value) {
    _volume = value.clamp(0.0, 1.0);
    _player?.setVolume(_volume);
  }

  /// Plays a high-fidelity sound effect with zero UI blocking
  Future<void> play(LuminaSound sound) async {
    if (!isEnabled) return;
    try {
      if (_player == null) _initPlayer();
      // Use AssetSource for bundled assets
      // Remove 'assets/' prefix if required by AssetSource
      final cleanPath = sound.assetPath.replaceFirst('assets/', '');
      await _player?.play(
        AssetSource(cleanPath),
        volume: _volume,
        mode: PlayerMode.lowLatency,
      );
    } catch (e) {
      // In headless test environments or devices without sound cards, fail silently
      debugPrint('SoundService play error: $e');
    }
  }

  void dispose() {
    _player?.dispose();
    _player = null;
  }
}
