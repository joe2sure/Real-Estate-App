class ApiEndpoints {
  static const String baseUrl = 'https://peeman-mobile-app-backend.onrender.com/api/v1';
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String logout = '$baseUrl/auth/logout';
  static const String properties = '$baseUrl/properties';
  static const String tenants = '$baseUrl/tenants';
  static const String payments = '$baseUrl/payments';
  static const String paymentsRecent = '$baseUrl/payments/recent';
  static const String paymentsSummary = '$baseUrl/payments/summary';
  static const String paymentsCreateIntent = '$baseUrl/payments/create-intent';
  static const String overdue = "$baseUrl/dashboard/due-rents";
  static const String dashboardMetrics = '$baseUrl/analytics/dashboard'; // Added
  static const String revenueAnalytics = '$baseUrl/analytics/revenue'; // Added
  static const String occupancyAnalytics = '$baseUrl/analytics/occupancy'; // Added
  static const String paymentTrends = '$baseUrl/analytics/payment-trends'; // Added
  //  static const String overdue = '$baseUrl/payments/overdue';
}




// class ApiEndpoints {
//   static const String baseUrl = 'https://peeman-mobile-app-backend.onrender.com/api/v1';
//   static const String login = '$baseUrl/auth/login';
//   static const String register = '$baseUrl/auth/register';
//   static const String logout = '$baseUrl/auth/logout';
//   static const String properties = '$baseUrl/properties';
//   static const String tenants = '$baseUrl/tenants';
//   static const String payments = '$baseUrl/payments';
//   static const String paymentsRecent = '$baseUrl/payments/recent';
//   static const String paymentsSummary = '$baseUrl/payments/summary';
//   static const String paymentsCreateIntent = '$baseUrl/payments/create-intent';
//    static const String overdue = "$baseUrl/dashboard/due-rents";
//   //  static const String overdue = '$baseUrl/payments/overdue';
// }