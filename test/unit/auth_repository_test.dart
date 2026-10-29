import 'package:flutter_test/flutter_test.dart';
import 'package:lumina_fintech/core/network/api_exceptions.dart';
import '../helpers/mock_auth_repository.dart';

void main() {
  group('AuthRepository Unit & Contract Tests', () {
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
    });

    test('register creates pending user and dispatches email code', () async {
      final res = await mockRepository.register(
        email: 'alex@luminawealth.com',
        password: 'password123',
        fullName: 'Alex Vance',
      );

      expect(res['status'], 'success');
      expect(res['email'], 'alex@luminawealth.com');
      expect(mockRepository.currentUser.name, 'Alex Vance');
      expect(mockRepository.currentUser.isProfileCompleted, isFalse);
    });

    test('verifyOtp saves token in vault and validates code', () async {
      final profile = await mockRepository.verifyOtp(
        email: 'alex@luminawealth.com',
        otp: '123456',
        type: 'register',
      );

      expect(profile.name, isNotEmpty);
      expect(await mockRepository.isAuthenticated(), isTrue);
      expect(await mockRepository.getSavedToken(), isNotNull);
    });

    test('verifyOtp rejects invalid code format', () async {
      expect(
        () => mockRepository.verifyOtp(
          email: 'alex@luminawealth.com',
          otp: '000',
          type: 'register',
        ),
        throwsA(isA<ApiException>()),
      );
    });

    test('login succeeds with valid credentials and sets session', () async {
      final profile = await mockRepository.login(
        email: 'alex@luminawealth.com',
        password: 'password123',
      );

      expect(profile.email, isNotEmpty);
      expect(await mockRepository.isAuthenticated(), isTrue);
    });

    test('login rejects unverified user with EmailNotVerifiedException', () async {
      mockRepository.isUnverified = true;

      expect(
        () => mockRepository.login(
          email: 'unverified@luminawealth.com',
          password: 'password123',
        ),
        throwsA(isA<EmailNotVerifiedException>()),
      );
    });

    test('forgotPassword dispatches reset code', () async {
      final res = await mockRepository.forgotPassword(email: 'alex@luminawealth.com');
      expect(res['status'], 'success');
    });

    test('resetPassword validates code and updates password', () async {
      final res = await mockRepository.resetPassword(
        email: 'alex@luminawealth.com',
        otp: '123456',
        newPassword: 'newSecretPassword99',
      );
      expect(res['status'], 'success');
    });

    test('updateProfile persists full name, avatar, bio, and marks completed', () async {
      final updated = await mockRepository.updateProfile(
        fullName: 'Roshan Chachre',
        avatarUrl: 'assets/avatars/girl_2.png',
        phoneNumber: '+1 555-0199',
        bio: 'Quantitative DeFi Sovereign',
      );

      expect(updated.name, 'Roshan Chachre');
      expect(updated.avatarUrl, 'assets/avatars/girl_2.png');
      expect(updated.bio, 'Quantitative DeFi Sovereign');
      expect(updated.isProfileCompleted, isTrue);
    });

    test('getAvatars returns all 8 distinct male and female avatars', () async {
      final avatars = await mockRepository.getAvatars();
      expect(avatars.length, 8);

      final boys = avatars.where((a) => a.gender == 'boy').toList();
      final girls = avatars.where((a) => a.gender == 'girl').toList();

      expect(boys.length, 4);
      expect(girls.length, 4);
      expect(boys.map((b) => b.id), containsAll(['boy_1', 'boy_2', 'boy_3', 'boy_4']));
      expect(girls.map((g) => g.id), containsAll(['girl_1', 'girl_2', 'girl_3', 'girl_4']));
    });

    test('logout clears tokens from storage', () async {
      await mockRepository.login(email: 'test@lumina.com', password: 'password123');
      expect(await mockRepository.isAuthenticated(), isTrue);

      await mockRepository.logout();
      expect(await mockRepository.isAuthenticated(), isFalse);
    });
  });
}
