
import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Property {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String address;

  Property({required this.id, required this.name, required this.address});

  factory Property.fromJson(Map<String, dynamic> json) => Property(
    id: json['_id'] ?? '',
    name: json['name'] ?? '',
    address: json['address'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'address': address,
  };
}

@HiveType(typeId: 2)
class EmergencyContact {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String phone;
  @HiveField(2)
  final String relationship;

  EmergencyContact({required this.name, required this.phone, required this.relationship});

  factory EmergencyContact.fromJson(Map<String, dynamic> json) => EmergencyContact(
    name: json['name'] ?? '',
    phone: json['phone'] ?? '',
    relationship: json['relationship'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'relationship': relationship,
  };
}


class DueRentModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String phone;

  @HiveField(5)
  final String unit;

  @HiveField(6)
  final Property property;

  @HiveField(7)
  final double rentAmount;

  @HiveField(8)
  final double securityDeposit;

  @HiveField(9)
  final DateTime leaseStartDate;

  @HiveField(10)
  final DateTime leaseEndDate;

  @HiveField(11)
  final String status;

  @HiveField(12)
  final DateTime nextPaymentDue;

  @HiveField(13)
  final bool isActive;

  @HiveField(14)
  final EmergencyContact emergencyContact;

  @HiveField(15)
  final String? notes;

  DueRentModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.unit,
    required this.property,
    required this.rentAmount,
    required this.securityDeposit,
    required this.leaseStartDate,
    required this.leaseEndDate,
    required this.status,
    required this.nextPaymentDue,
    required this.isActive,
    required this.emergencyContact,
    this.notes,
  });

  factory DueRentModel.fromJson(Map<String, dynamic> json) => DueRentModel(
    id: json['_id'] ?? '',
    firstName: json['firstName'] ?? '',
    lastName: json['lastName'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    unit: json['unit'] ?? '',
    property: Property.fromJson(json['property'] ?? {}),
    rentAmount: (json['rentAmount'] as num?)?.toDouble() ?? 0.0,
    securityDeposit: (json['securityDeposit'] as num?)?.toDouble() ?? 0.0,
    leaseStartDate: DateTime.tryParse(json['leaseStartDate'] ?? '') ??
        DateTime.now(),
    leaseEndDate:
    DateTime.tryParse(json['leaseEndDate'] ?? '') ?? DateTime.now(),
    status: json['status'] ?? 'unknown',
    nextPaymentDue:
    DateTime.tryParse(json['nextPaymentDue'] ?? '') ?? DateTime.now(),
    isActive: json['isActive'] ?? false,
    emergencyContact:
    EmergencyContact.fromJson(json['emergencyContact'] ?? {}),
    notes: json['notes'],
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'unit': unit,
    'property': property.toJson(),
    'rentAmount': rentAmount,
    'securityDeposit': securityDeposit,
    'leaseStartDate': leaseStartDate.toIso8601String(),
    'leaseEndDate': leaseEndDate.toIso8601String(),
    'status': status,
    'nextPaymentDue': nextPaymentDue.toIso8601String(),
    'isActive': isActive,
    'emergencyContact': emergencyContact.toJson(),
    'notes': notes,
  };
}