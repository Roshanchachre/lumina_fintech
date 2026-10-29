import '../../core/network/api_client.dart';
import '../../core/network/api_exceptions.dart';
import '../../core/security/secure_vault.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../models/account_models.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureVault secureVault;
  final ApiClient apiClient;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureVault,
    required this.apiClient,
  });

  @override
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await remoteDataSource.register(
      email: email,
      password: password,
      fullName: fullName,
    );
  }

  @override
  Future<UserProfile> verifyOtp({
    required String email,
    required String otp,
    String type = 'register',
  }) async {
    final res = await remoteDataSource.verifyOtp(
      email: email,
      otp: otp,
      type: type,
    );

    if (type == 'register') {
      await secureVault.saveLastEmail(email);
      final token = res['token'] as String?;
      if (token != null && token.isNotEmpty) {
        await secureVault.saveAuthToken(token);
        apiClient.setAuthToken(token);
      }

      final userData = res['user'];
      if (userData is Map<String, dynamic>) {
        return UserProfile.fromJson(userData);
      }
    }

    // For password reset verification or fallback
    return UserProfile(
      name: email.split('@').first,
      email: email,
      isKycVerified: true,
      isProfileCompleted: false,
    );
  }

  @override
  Future<Map<String, dynamic>> resendOtp({
    required String email,
    String type = 'register',
  }) async {
    return await remoteDataSource.resendOtp(email: email, type: type);
  }

  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    final res = await remoteDataSource.login(
      email: email,
      password: password,
    );

    if (res['code'] == 'EMAIL_NOT_VERIFIED' || res['status'] == 'unverified') {
      throw EmailNotVerifiedException(
        email: res['email'] ?? email,
        fullName: res['fullName'] ?? '',
        message: res['message'] ?? 'Please verify your email before proceeding.',
      );
    }

    await secureVault.saveLastEmail(email);
    await secureVault.setBiometricsEnrolled(true);

    final token = res['token'] as String?;
    if (token != null && token.isNotEmpty) {
      await secureVault.saveAuthToken(token);
      apiClient.setAuthToken(token);
    }

    final userData = res['user'];
    if (userData is Map<String, dynamic>) {
      return UserProfile.fromJson(userData);
    }

    return UserProfile(
      name: email.split('@').first,
      email: email,
      isProfileCompleted: false,
    );
  }

  @override
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    return await remoteDataSource.forgotPassword(email: email);
  }

  @override
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    return await remoteDataSource.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );
  }

  @override
  Future<UserProfile> getProfile() async {
    return await remoteDataSource.getProfile();
  }

  @override
  Future<UserProfile> updateProfile({
    required String fullName,
    required String avatarUrl,
    String? phoneNumber,
    String? bio,
  }) async {
    return await remoteDataSource.updateProfile(
      fullName: fullName,
      avatarUrl: avatarUrl,
      phoneNumber: phoneNumber,
      bio: bio,
    );
  }

  @override
  Future<List<AvatarItem>> getAvatars() async {
    return await remoteDataSource.getAvatars();
  }

  @override
  Future<void> logout() async {
    await secureVault.logout();
    apiClient.clearAuthToken();
  }

  @override
  Future<String?> getSavedToken() async {
    return await secureVault.getAuthToken();
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await secureVault.getAuthToken();
    if (token != null && token.isNotEmpty) {
      apiClient.setAuthToken(token);
      return true;
    }
    return false;
  }
}
