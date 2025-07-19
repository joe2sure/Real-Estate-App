import 'package:hive/hive.dart';
import '../hive/type_ids.dart';

part 'payment_model.g.dart';

@HiveType(typeId: HiveTypeIds.payment)
class Payment extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final PaymentTenant tenant;
  
  @HiveField(2)
  final PaymentProperty property;
  
  @HiveField(3)
  final double amount;
  
  @HiveField(4)
  final DateTime paymentDate;
  
  @HiveField(5)
  final DateTime dueDate;
  
  @HiveField(6)
  final String method;
  
  @HiveField(7)
  final String status;
  
  @HiveField(8)
  final String? description;
  
  @HiveField(9)
  final String? notes;
  
  @HiveField(10)
  final double lateFee;
  
  @HiveField(11)
  final double discount;
  
  @HiveField(12)
  final PaymentProcessor? processedBy;
  
  @HiveField(13)
  final DateTime createdAt;
  
  @HiveField(14)
  final DateTime updatedAt;
  
  @HiveField(15)
  final double totalAmount;
  
  @HiveField(16)
  final bool isLate;

  Payment({
    required this.id,
    required this.tenant,
    required this.property,
    required this.amount,
    required this.paymentDate,
    required this.dueDate,
    required this.method,
    required this.status,
    this.description,
    this.notes,
    required this.lateFee,
    required this.discount,
    this.processedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.totalAmount,
    required this.isLate,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['_id'] as String,
      tenant: PaymentTenant.fromJson(json['tenant']),
      property: PaymentProperty.fromJson(json['property']),
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['paymentDate']),
      dueDate: DateTime.parse(json['dueDate']),
      method: json['method'] as String,
      status: json['status'] as String,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      lateFee: (json['lateFee'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      processedBy: json['processedBy'] != null 
          ? PaymentProcessor.fromJson(json['processedBy']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      isLate: json['isLate'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'tenant': tenant.toJson(),
      'property': property.toJson(),
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'method': method,
      'status': status,
      'description': description,
      'notes': notes,
      'lateFee': lateFee,
      'discount': discount,
      'processedBy': processedBy?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'totalAmount': totalAmount,
      'isLate': isLate,
    };
  }
}

@HiveType(typeId: HiveTypeIds.paymentTenant)
class PaymentTenant extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String firstName;
  
  @HiveField(2)
  final String lastName;
  
  @HiveField(3)
  final String email;
  
  @HiveField(4)
  final String? phone;
  
  @HiveField(5)
  final String? unit;

  PaymentTenant({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.unit,
  });

  factory PaymentTenant.fromJson(Map<String, dynamic> json) {
    return PaymentTenant(
      id: json['_id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      unit: json['unit'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'unit': unit,
    };
  }

  String get fullName => '$firstName $lastName';
}

@HiveType(typeId: HiveTypeIds.paymentProperty)
class PaymentProperty extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String address;

  PaymentProperty({
    required this.id,
    required this.name,
    required this.address,
  });

  factory PaymentProperty.fromJson(Map<String, dynamic> json) {
    return PaymentProperty(
      id: json['_id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'address': address,
    };
  }
}

@HiveType(typeId: HiveTypeIds.paymentProcessor)
class PaymentProcessor extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String firstName;
  
  @HiveField(2)
  final String lastName;
  
  @HiveField(3)
  final String email;

  PaymentProcessor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory PaymentProcessor.fromJson(Map<String, dynamic> json) {
    return PaymentProcessor(
      id: json['_id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };
  }

  String get fullName => '$firstName $lastName';
}

// Non-Hive models (no typeId needed)
class PaymentSummary {
  final double totalRevenue;
  final List<MonthlyRevenue> monthlyRevenue;
  final OutstandingPayments outstandingPayments;

  PaymentSummary({
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.outstandingPayments,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) {
    return PaymentSummary(
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      monthlyRevenue: (json['monthlyRevenue'] as List)
          .map((item) => MonthlyRevenue.fromJson(item))
          .toList(),
      outstandingPayments: OutstandingPayments.fromJson(json['outstandingPayments']),
    );
  }
}

class MonthlyRevenue {
  final int year;
  final int month;
  final double revenue;
  final int count;

  MonthlyRevenue({
    required this.year,
    required this.month,
    required this.revenue,
    required this.count,
  });

  factory MonthlyRevenue.fromJson(Map<String, dynamic> json) {
    return MonthlyRevenue(
      year: json['_id']['year'] as int,
      month: json['_id']['month'] as int,
      revenue: (json['revenue'] as num).toDouble(),
      count: json['count'] as int,
    );
  }
}

class OutstandingPayments {
  final List<PaymentTenant> overdue;
  final List<PaymentTenant> dueSoon;

  OutstandingPayments({
    required this.overdue,
    required this.dueSoon,
  });

  factory OutstandingPayments.fromJson(Map<String, dynamic> json) {
    return OutstandingPayments(
      overdue: (json['overdue'] as List)
          .map((item) => PaymentTenant.fromJson(item))
          .toList(),
      dueSoon: (json['dueSoon'] as List)
          .map((item) => PaymentTenant.fromJson(item))
          .toList(),
    );
  }
}

class PaymentIntent {
  final String clientSecret;
  final String paymentIntentId;

  PaymentIntent({
    required this.clientSecret,
    required this.paymentIntentId,
  });

  factory PaymentIntent.fromJson(Map<String, dynamic> json) {
    return PaymentIntent(
      clientSecret: json['clientSecret'] as String,
      paymentIntentId: json['paymentIntentId'] as String,
    );
  }
}




// import 'package:hive/hive.dart';

// part 'payment_model.g.dart';

// @HiveType(typeId: 4)
// class Payment extends HiveObject {
//   @HiveField(0)
//   final String id;
  
//   @HiveField(1)
//   final PaymentTenant tenant;
  
//   @HiveField(2)
//   final PaymentProperty property;
  
//   @HiveField(3)
//   final double amount;
  
//   @HiveField(4)
//   final DateTime paymentDate;
  
//   @HiveField(5)
//   final DateTime dueDate;
  
//   @HiveField(6)
//   final String method;
  
//   @HiveField(7)
//   final String status;
  
//   @HiveField(8)
//   final String? description;
  
//   @HiveField(9)
//   final String? notes;
  
//   @HiveField(10)
//   final double lateFee;
  
//   @HiveField(11)
//   final double discount;
  
//   @HiveField(12)
//   final PaymentProcessor? processedBy;
  
//   @HiveField(13)
//   final DateTime createdAt;
  
//   @HiveField(14)
//   final DateTime updatedAt;
  
//   @HiveField(15)
//   final double totalAmount;
  
//   @HiveField(16)
//   final bool isLate;

//   Payment({
//     required this.id,
//     required this.tenant,
//     required this.property,
//     required this.amount,
//     required this.paymentDate,
//     required this.dueDate,
//     required this.method,
//     required this.status,
//     this.description,
//     this.notes,
//     required this.lateFee,
//     required this.discount,
//     this.processedBy,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.totalAmount,
//     required this.isLate,
//   });

//   factory Payment.fromJson(Map<String, dynamic> json) {
//     return Payment(
//       id: json['_id'] as String,
//       tenant: PaymentTenant.fromJson(json['tenant']),
//       property: PaymentProperty.fromJson(json['property']),
//       amount: (json['amount'] as num).toDouble(),
//       paymentDate: DateTime.parse(json['paymentDate']),
//       dueDate: DateTime.parse(json['dueDate']),
//       method: json['method'] as String,
//       status: json['status'] as String,
//       description: json['description'] as String?,
//       notes: json['notes'] as String?,
//       lateFee: (json['lateFee'] as num?)?.toDouble() ?? 0.0,
//       discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
//       processedBy: json['processedBy'] != null 
//           ? PaymentProcessor.fromJson(json['processedBy']) 
//           : null,
//       createdAt: DateTime.parse(json['createdAt']),
//       updatedAt: DateTime.parse(json['updatedAt']),
//       totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
//       isLate: json['isLate'] as bool? ?? false,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'tenant': tenant.toJson(),
//       'property': property.toJson(),
//       'amount': amount,
//       'paymentDate': paymentDate.toIso8601String(),
//       'dueDate': dueDate.toIso8601String(),
//       'method': method,
//       'status': status,
//       'description': description,
//       'notes': notes,
//       'lateFee': lateFee,
//       'discount': discount,
//       'processedBy': processedBy?.toJson(),
//       'createdAt': createdAt.toIso8601String(),
//       'updatedAt': updatedAt.toIso8601String(),
//       'totalAmount': totalAmount,
//       'isLate': isLate,
//     };
//   }
// }

// @HiveType(typeId: 5)
// class PaymentTenant extends HiveObject {
//   @HiveField(0)
//   final String id;
  
//   @HiveField(1)
//   final String firstName;
  
//   @HiveField(2)
//   final String lastName;
  
//   @HiveField(3)
//   final String email;
  
//   @HiveField(4)
//   final String? phone;
  
//   @HiveField(5)
//   final String? unit;

//   PaymentTenant({
//     required this.id,
//     required this.firstName,
//     required this.lastName,
//     required this.email,
//     this.phone,
//     this.unit,
//   });

//   factory PaymentTenant.fromJson(Map<String, dynamic> json) {
//     return PaymentTenant(
//       id: json['_id'] as String,
//       firstName: json['firstName'] as String,
//       lastName: json['lastName'] as String,
//       email: json['email'] as String,
//       phone: json['phone'] as String?,
//       unit: json['unit'] as String?,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'firstName': firstName,
//       'lastName': lastName,
//       'email': email,
//       'phone': phone,
//       'unit': unit,
//     };
//   }

//   String get fullName => '$firstName $lastName';
// }

// @HiveType(typeId: 6)
// class PaymentProperty extends HiveObject {
//   @HiveField(0)
//   final String id;
  
//   @HiveField(1)
//   final String name;
  
//   @HiveField(2)
//   final String address;

//   PaymentProperty({
//     required this.id,
//     required this.name,
//     required this.address,
//   });

//   factory PaymentProperty.fromJson(Map<String, dynamic> json) {
//     return PaymentProperty(
//       id: json['_id'] as String,
//       name: json['name'] as String,
//       address: json['address'] as String,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'name': name,
//       'address': address,
//     };
//   }
// }

// @HiveType(typeId: 7)
// class PaymentProcessor extends HiveObject {
//   @HiveField(0)
//   final String id;
  
//   @HiveField(1)
//   final String firstName;
  
//   @HiveField(2)
//   final String lastName;
  
//   @HiveField(3)
//   final String email;

//   PaymentProcessor({
//     required this.id,
//     required this.firstName,
//     required this.lastName,
//     required this.email,
//   });

//   factory PaymentProcessor.fromJson(Map<String, dynamic> json) {
//     return PaymentProcessor(
//       id: json['_id'] as String,
//       firstName: json['firstName'] as String,
//       lastName: json['lastName'] as String,
//       email: json['email'] as String,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'firstName': firstName,
//       'lastName': lastName,
//       'email': email,
//     };
//   }

//   String get fullName => '$firstName $lastName';
// }

// class PaymentSummary {
//   final double totalRevenue;
//   final List<MonthlyRevenue> monthlyRevenue;
//   final OutstandingPayments outstandingPayments;

//   PaymentSummary({
//     required this.totalRevenue,
//     required this.monthlyRevenue,
//     required this.outstandingPayments,
//   });

//   factory PaymentSummary.fromJson(Map<String, dynamic> json) {
//     return PaymentSummary(
//       totalRevenue: (json['totalRevenue'] as num).toDouble(),
//       monthlyRevenue: (json['monthlyRevenue'] as List)
//           .map((item) => MonthlyRevenue.fromJson(item))
//           .toList(),
//       outstandingPayments: OutstandingPayments.fromJson(json['outstandingPayments']),
//     );
//   }
// }

// class MonthlyRevenue {
//   final int year;
//   final int month;
//   final double revenue;
//   final int count;

//   MonthlyRevenue({
//     required this.year,
//     required this.month,
//     required this.revenue,
//     required this.count,
//   });

//   factory MonthlyRevenue.fromJson(Map<String, dynamic> json) {
//     return MonthlyRevenue(
//       year: json['_id']['year'] as int,
//       month: json['_id']['month'] as int,
//       revenue: (json['revenue'] as num).toDouble(),
//       count: json['count'] as int,
//     );
//   }
// }

// class OutstandingPayments {
//   final List<PaymentTenant> overdue;
//   final List<PaymentTenant> dueSoon;

//   OutstandingPayments({
//     required this.overdue,
//     required this.dueSoon,
//   });

//   factory OutstandingPayments.fromJson(Map<String, dynamic> json) {
//     return OutstandingPayments(
//       overdue: (json['overdue'] as List)
//           .map((item) => PaymentTenant.fromJson(item))
//           .toList(),
//       dueSoon: (json['dueSoon'] as List)
//           .map((item) => PaymentTenant.fromJson(item))
//           .toList(),
//     );
//   }
// }

// class PaymentIntent {
//   final String clientSecret;
//   final String paymentIntentId;

//   PaymentIntent({
//     required this.clientSecret,
//     required this.paymentIntentId,
//   });

//   factory PaymentIntent.fromJson(Map<String, dynamic> json) {
//     return PaymentIntent(
//       clientSecret: json['clientSecret'] as String,
//       paymentIntentId: json['paymentIntentId'] as String,
//     );
//   }
// }