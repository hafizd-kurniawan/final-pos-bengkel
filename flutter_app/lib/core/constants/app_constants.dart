class AppConstants {
  static const String appName = 'Vehicle Sales';
  static const String baseUrl = 'http://localhost:8080/api/v1';
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String vehiclesEndpoint = '/vehicles';
  static const String usersEndpoint = '/users';
  static const String salesEndpoint = '/sales';
  static const String transactionsEndpoint = '/transactions';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  
  // Pagination
  static const int defaultPageSize = 10;
  
  // File Upload
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
}