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
}




// class ApiEndpoints {
//   static const String baseUrl = 'https://peeman-mobile-app-backend.onrender.com/api/v1';
//   static const String login = '$baseUrl/auth/login';
//   static const String register = '$baseUrl/auth/register';
//   static const String logout = '$baseUrl/auth/logout';
//   static const String properties = '$baseUrl/properties';
//   static const String tenants = '$baseUrl/tenants';
//   static const String overdue = "$baseUrl/dashboard/due-rents";
// }