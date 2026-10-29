import 'package:flutter_test/flutter_test.dart';
import 'package:lumina_fintech/bloc/auth_bloc.dart';
import '../helpers/mock_auth_repository.dart';

void main() {
  group('AuthBloc State Machine Tests', () {
    late MockAuthRepository mockRepo;
    late AuthBloc authBloc;

    setUp(() {
      mockRepo = MockAuthRepository();
      authBloc = AuthBloc(authRepository: mockRepo);
    });

    tearDown(() {
      authBloc.close();
    });

    test('Initial state is AuthStatus.initial', () {
      expect(authBloc.state.status, AuthStatus.initial);
      expect(authBloc.state.selectedAvatarUrl, 'assets/avatars/boy_1.png');
    });

    test('CheckAuthStatus emits unauthenticated when no token is present', () async {
      authBloc.add(CheckAuthStatus());
      await expectLater(
        authBloc.stream,
        emits(predicate<AuthState>((s) => s.status == AuthStatus.unauthenticated)),
      );
    });

    test('RegisterRequested emits loading then otpSent with email and countdown', () async {
      authBloc.add(
        RegisterRequested(
          email: 'newuser@luminawealth.com',
          password: 'password123',
          fullName: 'New User',
        ),
      );

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          predicate<AuthState>((s) => s.status == AuthStatus.loading),
          predicate<AuthState>((s) =>
              s.status == AuthStatus.otpSent &&
              s.pendingEmail == 'newuser@luminawealth.com' &&
              s.resendCountdown == 60),
        ]),
      );
    });

    test('VerifyOtpRequested emits profileIncomplete when user has not setup profile', () async {
      mockRepo.currentUser = mockRepo.currentUser.copyWith(isProfileCompleted: false);

      authBloc.add(
        VerifyOtpRequested(
          email: 'newuser@luminawealth.com',
          otp: '123456',
          type: 'register',
        ),
      );

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          predicate<AuthState>((s) => s.status == AuthStatus.loading),
          predicate<AuthState>((s) =>
              s.status == AuthStatus.profileIncomplete &&
              s.user?.isProfileCompleted == false),
        ]),
      );
    });

    test('LoginRequested emits unverifiedEmail when backend rejects unverified user', () async {
      mockRepo.isUnverified = true;

      authBloc.add(
        LoginRequested(
          email: 'unverified@luminawealth.com',
          password: 'password123',
        ),
      );

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          predicate<AuthState>((s) => s.status == AuthStatus.loading),
          predicate<AuthState>((s) =>
              s.status == AuthStatus.unverifiedEmail &&
              s.pendingEmail == 'unverified@luminawealth.com'),
        ]),
      );
    });

    test('UpdateProfileRequested updates user and emits authenticated', () async {
      authBloc.add(
        UpdateProfileRequested(
          fullName: 'Roshan Sovereign',
          avatarUrl: 'assets/avatars/boy_3.png',
          phoneNumber: '+1 800-LUMINA',
          bio: 'Decentralized Vault Architect',
        ),
      );

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          predicate<AuthState>((s) => s.status == AuthStatus.loading),
          predicate<AuthState>((s) =>
              s.status == AuthStatus.authenticated &&
              s.user?.name == 'Roshan Sovereign' &&
              s.selectedAvatarUrl == 'assets/avatars/boy_3.png'),
        ]),
      );
    });

    test('SelectAvatar updates active avatar selection in state', () {
      authBloc.add(SelectAvatar('assets/avatars/girl_3.png'));
      expect(
        authBloc.stream,
        emits(predicate<AuthState>((s) => s.selectedAvatarUrl == 'assets/avatars/girl_3.png')),
      );
    });

    test('LogoutRequested emits unauthenticated and clears session', () async {
      authBloc.add(LogoutRequested());
      await expectLater(
        authBloc.stream,
        emits(predicate<AuthState>((s) => s.status == AuthStatus.unauthenticated)),
      );
    });
  });
}
