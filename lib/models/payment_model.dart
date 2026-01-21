import 'dart:convert';

import 'package:flutter/material.dart';
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
  
  @HiveField(17)
  final String currency;
  
  @HiveField(18)
  final String paymentType;
  
  @HiveField(19)
  final PaymentRoom? room;
  
  @HiveField(20)
  final DateTime? startDate;
  
  @HiveField(21)
  final DateTime? endDate;

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
    required this.currency,
    required this.paymentType,
    this.room,
    this.startDate,
    this.endDate,
  });


  factory Payment.fromJson(Map<String, dynamic> json) {
    try {
      return Payment(
        id: json['_id'] as String? ?? '',
        tenant: json['tenant'] != null 
            ? PaymentTenant.fromJson(json['tenant'] as Map<String, dynamic>) 
            : PaymentTenant(
                id: '', 
                firstName: 'Unknown', 
                lastName: 'Tenant', 
                email: ''
              ),
        property: json['property'] != null
            ? PaymentProperty.fromJson(json['property'] as Map<String, dynamic>)
            : PaymentProperty(
                id: '', 
                name: 'Unknown Property', 
                address: 'No address'
              ),
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        paymentDate: json['paymentDate'] != null 
            ? DateTime.parse(json['paymentDate'] as String)
            : DateTime.now(),
        dueDate: json['dueDate'] != null
            ? DateTime.parse(json['dueDate'] as String)
            : DateTime.now(),
        method: json['method'] as String? ?? 'unknown',
        status: json['status'] as String? ?? 'pending',
        description: json['description'] as String?,
        notes: json['notes'] as String?,
        lateFee: (json['lateFee'] as num?)?.toDouble() ?? 0.0,
        discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
        processedBy: json['processedBy'] != null 
            ? PaymentProcessor.fromJson(json['processedBy'] as Map<String, dynamic>) 
            : null,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime.now(),
        totalAmount: ((json['amount'] as num?)?.toDouble() ?? 0.0) + 
                    ((json['lateFee'] as num?)?.toDouble() ?? 0.0) - 
                    ((json['discount'] as num?)?.toDouble() ?? 0.0),
        isLate: json['isLate'] as bool? ?? false,
        currency: json['currency'] as String? ?? 'GBP',
        paymentType: json['paymentType'] as String? ?? 'full',
        room: json['room'] != null 
            ? PaymentRoom.fromJson(json['room'] as Map<String, dynamic>) 
            : null,
        startDate: json['startDate'] != null 
            ? DateTime.parse(json['startDate'] as String) 
            : null,
        endDate: json['endDate'] != null 
            ? DateTime.parse(json['endDate'] as String) 
            : null,
      );
    } catch (e) {
      debugPrint('❌ Error parsing Payment: $e');
      debugPrint('Payment JSON: ${jsonEncode(json)}');
      rethrow;
    }
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
      'currency': currency,
      'paymentType': paymentType,
      'room': room?.toJson(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
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
      id: json['_id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
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
      if (phone != null) 'phone': phone,
      if (unit != null) 'unit': unit,
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
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Property',
      address: json['address'] as String? ?? 'No address',
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

@HiveType(typeId: HiveTypeIds.paymentRoom)
class PaymentRoom extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String roomNumber;

  PaymentRoom({
    required this.id,
    required this.roomNumber,
  });

  factory PaymentRoom.fromJson(Map<String, dynamic> json) {
    return PaymentRoom(
      id: json['_id'] as String? ?? '',
      roomNumber: json['roomNumber'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'roomNumber': roomNumber,
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
      id: json['_id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
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

// Non-Hive models (API responses)
class PaymentSummary {
  final int totalPayments;
  final int completedPayments;
  final int pendingPayments;
  final Map<String, double> revenue;

  PaymentSummary({
    required this.totalPayments,
    required this.completedPayments,
    required this.pendingPayments,
    required this.revenue,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) {
    return PaymentSummary(
      totalPayments: json['totalPayments'] as int,
      completedPayments: json['completedPayments'] as int,
      pendingPayments: json['pendingPayments'] as int,
      revenue: {
        'USD': (json['revenue']['USD'] as num?)?.toDouble() ?? 0.0,
        'GBP': (json['revenue']['GBP'] as num?)?.toDouble() ?? 0.0,
        'NGN': (json['revenue']['NGN'] as num?)?.toDouble() ?? 0.0,
      },
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