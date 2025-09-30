// import 'package:Peeman/models/property_model.dart';
import 'package:Peeman/models/tenant.dart' ;

class Room {
  final String id;
  final String roomNumber;
  final Property property;
  final Tenant? tenant;
  final double rentAmount;
  final String currency;
  final String status;
  final String description;
  final List<String> amenities;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastRentDate;
  final DateTime? nextRentDue;

  Room({
    required this.id,
    required this.roomNumber,
    required this.property,
    this.tenant,
    required this.rentAmount,
    required this.currency,
    required this.status,
    required this.description,
    required this.amenities,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
    this.lastRentDate,
    this.nextRentDue,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['_id'] ?? '',
      roomNumber: json['roomNumber'] ?? '',
      property: Property.fromJson(json['property'] ?? {}),
      tenant: json['tenant'] != null ? Tenant.fromJson(json['tenant']) : null,
      rentAmount: (json['rentAmount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      status: json['status'] ?? 'available',
      description: json['description'] ?? '',
      amenities: json['amenities'] != null ? List<String>.from(json['amenities']) : [],
      isAvailable: json['isAvailable'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      lastRentDate: json['lastRentDate'] != null
          ? DateTime.tryParse(json['lastRentDate']) : null,
      nextRentDue: json['nextRentDue'] != null
          ? DateTime.tryParse(json['nextRentDue']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'roomNumber': roomNumber,
        'property': property.toJson(),
        'tenant': tenant?.toJson(),
        'rentAmount': rentAmount,
        'currency': currency,
        'status': status,
        'description': description,
        'amenities': amenities,
        'isAvailable': isAvailable,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'lastRentDate': lastRentDate?.toIso8601String(),
        'nextRentDue': nextRentDue?.toIso8601String(),
      };
}