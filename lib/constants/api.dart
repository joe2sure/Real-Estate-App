class ApiEndpoints {
  static const String baseUrl = 'https://peeman-mobile-app-backend.onrender.com/api/v1';
  
  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String logout = '$baseUrl/auth/logout';
  static const String currentUser = '$baseUrl/auth/me';
  
  // User endpoints
  static const String users = '$baseUrl/users';
  static String userById(String userId) => '$baseUrl/users/$userId';
  static const String updateProfile = '$baseUrl/users/profile';
  static String updateUser(String userId) => '$baseUrl/users/$userId';
  static String deactivateUser(String userId) => '$baseUrl/users/$userId/deactivate';
  
  // Property endpoints
  static const String properties = '$baseUrl/properties';
  
  // Tenant endpoints
  static const String tenants = '$baseUrl/tenants';
  
  // Payment endpoints
  static const String payments = '$baseUrl/payments';
  static const String paymentsRecent = '$baseUrl/payments/recent';
  static const String paymentsSummary = '$baseUrl/payments/summary';
  static const String paymentsCreateIntent = '$baseUrl/payments/create-intent';
  
  // Dashboard endpoints
  static const String overdue = '$baseUrl/dashboard/due-rents';
  static const String dashboardMetrics = '$baseUrl/analytics/dashboard';
  static const String revenueAnalytics = '$baseUrl/analytics/revenue';
  static const String occupancyAnalytics = '$baseUrl/analytics/occupancy';
  static const String paymentTrends = '$baseUrl/analytics/payment-trends';
}