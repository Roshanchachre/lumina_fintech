import 'package:lumina_fintech/domain/repositories/auth_repository.dart';
import 'package:lumina_fintech/models/account_models.dart';
import 'package:lumina_fintech/core/network/api_exceptions.dart';

class MockAuthRepository implements AuthRepository {
  String? savedToken;
  UserProfile currentUser;
  bool shouldFail = false;
  String failMessage = 'Simulated authentication error';
  bool isUnverified = false;

  MockAuthRepository({
    UserProfile? initialUser,
    this.savedToken,
  }) : currentUser = initialUser ??
            const UserProfile(
              id: 'usr_test_123',
              name: 'Test Sovereign',
              email: 'test@luminawealth.com',
              avatarUrl: 'assets/avatars/boy_1.png',
              isProfileCompleted: true,
            );

  @override
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (shouldFail) throw ApiException(message: failMessage);
    currentUser = currentUser.copyWith(
      email: email,
      name: fullName,
      isProfileCompleted: false,
    );
    return {
      'status': 'success',
      'message': 'Account created. Verification code sent to email.',
      'email': email,
    };
  }

  @override
  Future<UserProfile> verifyOtp({
    required String email,
    required String otp,
    String type = 'register',
  }) async {
    if (shouldFail) throw ApiException(message: failMessage);
    if (otp != '123456' && otp.length != 6) {
      throw const ApiException(message: 'Incorrect verification code.');
    }
    savedToken = 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
    return currentUser;
  }

  @override
  Future<Map<String, dynamic>> resendOtp({
    required String email,
    String type = 'register',
  }) async {
    if (shouldFail) throw ApiException(message: failMessage);
    return {
      'status': 'success',
      'message': 'New verification code dispatched to your email.',
    };
  }

  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    if (shouldFail) throw ApiException(message: failMessage);
    if (isUnverified) {
      throw EmailNotVerifiedException(
        email: email,
        fullName: currentUser.name,
      );
    }
    if (password != 'password123' && password.length < 6) {
      throw const ApiException(message: 'Invalid email or password.');
    }
    savedToken = 'mock_jwt_token_logged_in';
    return currentUser;
  }

  @override
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    if (shouldFail) throw ApiException(message: failMessage);
    return {
      'status': 'success',
      'message': 'Password reset code dispatched to your email.',
    };
  }

  @override
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    if (shouldFail) throw ApiException(message: failMessage);
    if (otp != '123456' && otp.length != 6) {
      throw const ApiException(message: 'Invalid or expired verification code.');
    }
    return {
      'status': 'success',
      'message': 'Password reset successfully.',
    };
  }

  @override
  Future<UserProfile> getProfile() async {
    if (shouldFail) throw ApiException(message: failMessage);
    return currentUser;
  }

  @override
  Future<UserProfile> updateProfile({
    required String fullName,
    required String avatarUrl,
    String? phoneNumber,
    String? bio,
  }) async {
    if (shouldFail) throw ApiException(message: failMessage);
    currentUser = currentUser.copyWith(
      name: fullName,
      avatarUrl: avatarUrl,
      phoneNumber: phoneNumber ?? '',
      bio: bio ?? '',
      isProfileCompleted: true,
    );
    return currentUser;
  }

  @override
  Future<List<AvatarItem>> getAvatars() async {
    return AvatarItem.defaults;
  }

  @override
  Future<void> logout() async {
    savedToken = null;
  }

  @override
  Future<String?> getSavedToken() async => savedToken;

  @override
  Future<bool> isAuthenticated() async => savedToken != null && savedToken!.isNotEmpty;
}
