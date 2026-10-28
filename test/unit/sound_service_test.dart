import 'package:flutter_test/flutter_test.dart';
import 'package:lumina_fintech/core/sound/sound_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SoundService Acoustic Engine Tests', () {
    late SoundService soundService;

    setUp(() {
      soundService = SoundService(isEnabled: true);
    });

    tearDown(() {
      soundService.dispose();
    });

    test('verifies all LuminaSound asset paths are well-formed', () {
      expect(LuminaSound.values.length, equals(7));

      for (final sound in LuminaSound.values) {
        expect(sound.assetPath, startsWith('assets/sounds/'));
        expect(sound.assetPath, endsWith('.wav'));
      }
    });

    test('volume clamping operates within 0.0 to 1.0 safe range', () {
      soundService.volume = 0.5;
      expect(soundService.volume, equals(0.5));

      soundService.volume = 1.5;
      expect(soundService.volume, equals(1.0));

      soundService.volume = -0.5;
      expect(soundService.volume, equals(0.0));
    });

    test('isEnabled toggle activates and mutes sound cues', () {
      expect(soundService.isEnabled, isTrue);

      soundService.isEnabled = false;
      expect(soundService.isEnabled, isFalse);

      soundService.isEnabled = true;
      expect(soundService.isEnabled, isTrue);
    });

    test('invoking play on all sound cues executes safely without throwing', () async {
      soundService.isEnabled = false; // Muted mode executes instantly
      for (final sound in LuminaSound.values) {
        await expectLater(soundService.play(sound), completes);
      }
    });
  });
}
