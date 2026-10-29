import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/network/api_exceptions.dart';
import '../domain/repositories/auth_repository.dart';
import '../models/account_models.dart';

enum AuthStatus {
  initial,
  loading,
  unauthenticated,
  otpSent,
  authenticated,
  profileIncomplete,
  passwordResetSent,
  passwordResetSuccess,
  unverifiedEmail,
  error,
}

// EVENTS
abstract class AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  RegisterRequested({
    required this.email,
    required this.password,
    required this.fullName,
  });
}

class VerifyOtpRequested extends AuthEvent {
  final String email;
  final String otp;
  final String type; // 'register' | 'reset'
  VerifyOtpRequested({
    required this.email,
    required this.otp,
    this.type = 'register',
  });
}

class ResendOtpRequested extends AuthEvent {
  final String email;
  final String type;
  ResendOtpRequested({
    required this.email,
    this.type = 'register',
  });
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested({
    required this.email,
    required this.password,
  });
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  ForgotPasswordRequested({required this.email});
}

class ResetPasswordRequested extends AuthEvent {
  final String email;
  final String otp;
  final String newPassword;
  ResetPasswordRequested({
    required this.email,
    required this.otp,
    required this.newPassword,
  });
}

class UpdateProfileRequested extends AuthEvent {
  final String fullName;
  final String avatarUrl;
  final String? phoneNumber;
  final String? bio;
  UpdateProfileRequested({
    required this.fullName,
    required this.avatarUrl,
    this.phoneNumber,
    this.bio,
  });
}

class SelectAvatar extends AuthEvent {
  final String avatarUrl;
  SelectAvatar(this.avatarUrl);
}

class ClearAuthError extends AuthEvent {}

class LogoutRequested extends AuthEvent {}

class _TickResendCountdown extends AuthEvent {
  final int remaining;
  _TickResendCountdown(this.remaining);
}

// STATE
class AuthState {
  final AuthStatus status;
  final UserProfile? user;
  final String? errorMessage;
  final String? infoMessage;
  final String? pendingEmail;
  final String? pendingOtpType;
  final List<AvatarItem> availableAvatars;
  final String selectedAvatarUrl;
  final int resendCountdown;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.infoMessage,
    this.pendingEmail,
    this.pendingOtpType,
    this.availableAvatars = AvatarItem.defaults,
    this.selectedAvatarUrl = 'assets/avatars/boy_1.png',
    this.resendCountdown = 0,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserProfile? user,
    String? errorMessage,
    String? infoMessage,
    String? pendingEmail,
    String? pendingOtpType,
    List<AvatarItem>? availableAvatars,
    String? selectedAvatarUrl,
    int? resendCountdown,
    bool clearError = false,
    bool clearInfo = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
      pendingEmail: pendingEmail ?? this.pendingEmail,
      pendingOtpType: pendingOtpType ?? this.pendingOtpType,
      availableAvatars: availableAvatars ?? this.availableAvatars,
      selectedAvatarUrl: selectedAvatarUrl ?? this.selectedAvatarUrl,
      resendCountdown: resendCountdown ?? this.resendCountdown,
    );
  }
}

// BLOC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  Timer? _countdownTimer;

  AuthBloc({required this.authRepository}) : super(const AuthState()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<RegisterRequested>(_onRegisterRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<ResendOtpRequested>(_onResendOtpRequested);
    on<LoginRequested>(_onLoginRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<SelectAvatar>(_onSelectAvatar);
    on<ClearAuthError>(_onClearAuthError);
    on<LogoutRequested>(_onLogoutRequested);
    on<_TickResendCountdown>((event, emit) {
      emit(state.copyWith(resendCountdown: event.remaining));
    });
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final isAuth = await authRepository.isAuthenticated();
      if (!isAuth) {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
        return;
      }

      final profile = await authRepository.getProfile();
      final avatars = await authRepository.getAvatars();

      if (!profile.isProfileCompleted) {
        emit(state.copyWith(
          status: AuthStatus.profileIncomplete,
          user: profile,
          availableAvatars: avatars,
          selectedAvatarUrl: profile.avatarUrl.isNotEmpty ? profile.avatarUrl : 'assets/avatars/boy_1.png',
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: profile,
          availableAvatars: avatars,
          selectedAvatarUrl: profile.avatarUrl,
        ));
      }
    } catch (_) {
      // In case offline, keep unauthenticated
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final res = await authRepository.register(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
      );

      emit(state.copyWith(
        status: AuthStatus.otpSent,
        pendingEmail: event.email.trim().toLowerCase(),
        pendingOtpType: 'register',
        infoMessage: res['message']?.toString() ?? 'Verification code sent to your email.',
        resendCountdown: 60,
      ));
      _startResendCooldown();
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Registration failed: ${e.toString()}',
      ));
    }
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final profile = await authRepository.verifyOtp(
        email: event.email,
        otp: event.otp,
        type: event.type,
      );

      _countdownTimer?.cancel();

      if (event.type == 'register') {
        if (!profile.isProfileCompleted) {
          emit(state.copyWith(
            status: AuthStatus.profileIncomplete,
            user: profile,
            selectedAvatarUrl: profile.avatarUrl.isNotEmpty ? profile.avatarUrl : 'assets/avatars/boy_1.png',
            infoMessage: 'Email successfully verified. Please set up your profile.',
          ));
        } else {
          emit(state.copyWith(
            status: AuthStatus.authenticated,
            user: profile,
            selectedAvatarUrl: profile.avatarUrl,
            infoMessage: 'Verification successful. Welcome to Lumina Vault.',
          ));
        }
      } else {
        // Password reset verification
        emit(state.copyWith(
          status: AuthStatus.passwordResetSent,
          infoMessage: 'Code verified. Enter your new password.',
        ));
      }
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Verification failed: ${e.toString()}',
      ));
    }
  }

  Future<void> _onResendOtpRequested(
    ResendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final res = await authRepository.resendOtp(
        email: event.email,
        type: event.type,
      );
      _startResendCooldown();
      emit(state.copyWith(
        infoMessage: res['message']?.toString() ?? 'New code sent to your email.',
        clearError: true,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      ));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final profile = await authRepository.login(
        email: event.email,
        password: event.password,
      );

      if (!profile.isProfileCompleted) {
        emit(state.copyWith(
          status: AuthStatus.profileIncomplete,
          user: profile,
          selectedAvatarUrl: profile.avatarUrl.isNotEmpty ? profile.avatarUrl : 'assets/avatars/boy_1.png',
          infoMessage: 'Welcome! Complete your profile to customize your experience.',
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: profile,
          selectedAvatarUrl: profile.avatarUrl,
        ));
      }
    } on EmailNotVerifiedException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.unverifiedEmail,
        pendingEmail: e.email,
        pendingOtpType: 'register',
        errorMessage: e.message,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Login failed: ${e.toString()}',
      ));
    }
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final res = await authRepository.forgotPassword(email: event.email);
      _startResendCooldown();
      emit(state.copyWith(
        status: AuthStatus.passwordResetSent,
        pendingEmail: event.email.trim().toLowerCase(),
        pendingOtpType: 'reset',
        infoMessage: res['message']?.toString() ?? 'Password reset code sent to your email.',
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to request password reset: ${e.toString()}',
      ));
    }
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final res = await authRepository.resetPassword(
        email: event.email,
        otp: event.otp,
        newPassword: event.newPassword,
      );
      emit(state.copyWith(
        status: AuthStatus.passwordResetSuccess,
        infoMessage: res['message']?.toString() ?? 'Password reset successfully. You can now log in.',
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to reset password: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final updatedProfile = await authRepository.updateProfile(
        fullName: event.fullName,
        avatarUrl: event.avatarUrl,
        phoneNumber: event.phoneNumber,
        bio: event.bio,
      );

      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: updatedProfile,
        selectedAvatarUrl: updatedProfile.avatarUrl,
        infoMessage: 'Profile successfully updated.',
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to update profile: ${e.toString()}',
      ));
    }
  }

  void _onSelectAvatar(
    SelectAvatar event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(selectedAvatarUrl: event.avatarUrl));
  }

  void _onClearAuthError(
    ClearAuthError event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(clearError: true, clearInfo: true));
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  void _startResendCooldown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.resendCountdown - 1;
      if (remaining <= 0) {
        timer.cancel();
        add(_TickResendCountdown(0));
      } else {
        add(_TickResendCountdown(remaining));
      }
    });
  }
}
