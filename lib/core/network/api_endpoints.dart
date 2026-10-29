class ApiEndpoints {
  static const String _defaultLocalhost = 'http://127.0.0.1:4040/api/v1';
  static const String _defaultLanIp = 'http://192.168.1.4:4040/api/v1';
  static const String _defaultAndroidEmulator = 'http://10.0.2.2:4040/api/v1';

  // Configurable base URL: defaults to localhost:4040, or can be set via --dart-define=API_URL=...
  static String baseUrl = const String.fromEnvironment('API_URL').isNotEmpty
      ? const String.fromEnvironment('API_URL')
      : _defaultLocalhost;

  /// Candidate URLs tried in order if primary connection fails (e.g. on real device or emulator)
  static List<String> get candidateBaseUrls => [
        if (const String.fromEnvironment('API_URL').isNotEmpty)
          const String.fromEnvironment('API_URL'),
        _defaultLocalhost,
        _defaultLanIp,
        _defaultAndroidEmulator,
      ];

  // Authentication & Security
  static const String authRegister = '/auth/register';
  static const String authVerifyOtp = '/auth/verify-otp';
  static const String authResendOtp = '/auth/resend-otp';
  static const String authLogin = '/auth/login';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authResetPassword = '/auth/reset-password';
  static const String authDevMail = '/auth/dev-mail';

  // User Profile & Predefined Avatars
  static const String userProfile = '/user/profile';
  static const String userAvatars = '/user/avatars';

  // Accounts & Portfolio
  static const String accountSummary = '/accounts/me';
  static const String portfolioHistory = '/portfolio/history';
  static const String assetAllocations = '/portfolio/allocations';

  // Cards
  static const String cardsList = '/cards';
  static String cardFreeze(String cardId) => '/cards/$cardId/freeze';
  static String cardPermissions(String cardId) => '/cards/$cardId/permissions';

  // Money Movement
  static const String transfers = '/transfers';
  static const String transactions = '/transactions';
}
