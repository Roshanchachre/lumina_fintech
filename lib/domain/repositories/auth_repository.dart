import '../../models/account_models.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
  });

  Future<UserProfile> verifyOtp({
    required String email,
    required String otp,
    String type,
  });

  Future<Map<String, dynamic>> resendOtp({
    required String email,
    String type,
  });

  Future<UserProfile> login({
    required String email,
    required String password,
  });

  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  });

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });

  Future<UserProfile> getProfile();

  Future<UserProfile> updateProfile({
    required String fullName,
    required String avatarUrl,
    String? phoneNumber,
    String? bio,
  });

  Future<List<AvatarItem>> getAvatars();

  Future<void> logout();

  Future<String?> getSavedToken();

  Future<bool> isAuthenticated();
}
