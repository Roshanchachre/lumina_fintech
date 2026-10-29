import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exceptions.dart';
import '../../models/account_models.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
  });

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
    String type = 'register',
  });

  Future<Map<String, dynamic>> resendOtp({
    required String email,
    String type = 'register',
  });

  Future<Map<String, dynamic>> login({
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
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient client;

  AuthRemoteDataSourceImpl({ApiClient? client})
      : client = client ?? ApiClient();

  @override
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await client.post<Map<String, dynamic>>(
        ApiEndpoints.authRegister,
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
          'fullName': fullName.trim(),
        },
      );
      return response.data ?? {};
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: e.message ?? 'Registration failed.');
    }
  }

  @override
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
    String type = 'register',
  }) async {
    try {
      final response = await client.post<Map<String, dynamic>>(
        ApiEndpoints.authVerifyOtp,
        data: {
          'email': email.trim().toLowerCase(),
          'otp': otp.trim(),
          'type': type,
        },
      );
      return response.data ?? {};
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: e.message ?? 'Verification failed.');
    }
  }

  @override
  Future<Map<String, dynamic>> resendOtp({
    required String email,
    String type = 'register',
  }) async {
    try {
      final response = await client.post<Map<String, dynamic>>(
        ApiEndpoints.authResendOtp,
        data: {
          'email': email.trim().toLowerCase(),
          'type': type,
        },
      );
      return response.data ?? {};
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: e.message ?? 'Failed to resend code.');
    }
  }

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.post<Map<String, dynamic>>(
        ApiEndpoints.authLogin,
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );
      return response.data ?? {};
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        final data = e.response?.data;
        if (data is Map && data['code'] == 'EMAIL_NOT_VERIFIED') {
          return {
            'status': 'unverified',
            'code': 'EMAIL_NOT_VERIFIED',
            'message': data['message'] ?? 'Email not verified.',
            'email': data['email'] ?? email,
            'fullName': data['fullName'] ?? '',
          };
        }
      }
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: e.message ?? 'Authentication failed.');
    }
  }

  @override
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await client.post<Map<String, dynamic>>(
        ApiEndpoints.authForgotPassword,
        data: {
          'email': email.trim().toLowerCase(),
        },
      );
      return response.data ?? {};
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: e.message ?? 'Failed to process forgot password.');
    }
  }

  @override
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await client.post<Map<String, dynamic>>(
        ApiEndpoints.authResetPassword,
        data: {
          'email': email.trim().toLowerCase(),
          'otp': otp.trim(),
          'newPassword': newPassword,
        },
      );
      return response.data ?? {};
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: e.message ?? 'Failed to reset password.');
    }
  }

  @override
  Future<UserProfile> getProfile() async {
    try {
      final response = await client.get<Map<String, dynamic>>(
        ApiEndpoints.userProfile,
      );
      final profileData = response.data?['profile'];
      if (profileData is Map<String, dynamic>) {
        return UserProfile.fromJson(profileData);
      }
      throw const ApiException(message: 'Invalid profile data returned by vault.');
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: e.message ?? 'Failed to fetch user profile.');
    }
  }

  @override
  Future<UserProfile> updateProfile({
    required String fullName,
    required String avatarUrl,
    String? phoneNumber,
    String? bio,
  }) async {
    try {
      final response = await client.put<Map<String, dynamic>>(
        ApiEndpoints.userProfile,
        data: {
          'fullName': fullName.trim(),
          'avatarUrl': avatarUrl,
          'phoneNumber': phoneNumber ?? '',
          'bio': bio ?? '',
        },
      );
      final profileData = response.data?['profile'];
      if (profileData is Map<String, dynamic>) {
        return UserProfile.fromJson(profileData);
      }
      throw const ApiException(message: 'Invalid profile data returned from update.');
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: e.message ?? 'Failed to update profile.');
    }
  }

  @override
  Future<List<AvatarItem>> getAvatars() async {
    try {
      final response = await client.get<Map<String, dynamic>>(
        ApiEndpoints.userAvatars,
      );
      final avatarsList = response.data?['avatars'] as List?;
      if (avatarsList != null) {
        return avatarsList
            .map((e) => AvatarItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return AvatarItem.defaults;
    } catch (_) {
      return AvatarItem.defaults;
    }
  }
}
