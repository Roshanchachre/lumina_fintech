class ApiEndpoints {
  static const String baseUrl = 'https://api.luminawealth.com/v1';

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
