import 'package:Peeman/models/tenant.dart';
import 'package:Peeman/models/property_model.dart' as PropertyModel;
import 'package:Peeman/models/due_rent_model.dart' hide Property;

class Room {
  final String id;
  final String roomNumber;
  final PropertyModel.Property property; 
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
    // Handle property field - it can be either a string (ID) or an object
    PropertyModel.Property property;
    
    if (json['property'] is String) {
      // If property is just an ID string, create a minimal Property object
      property = PropertyModel.Property(
        id: json['property'] as String,
        name: 'Unknown Property', // Placeholder
        address: '',
        description: '',
        images: [],
        status: 'active',
        unitsOccupied: 0,
        totalUnits: 0,
        occupancy: 0.0,
        monthlyIncome: 0.0,
        amenities: [],
      );
    } else if (json['property'] is Map<String, dynamic>) {
      // If property is an object, parse it normally
      property = PropertyModel.Property.fromJson(json['property'] as Map<String, dynamic>);
    } else {
      // Fallback for null or unexpected types
      property = PropertyModel.Property(
        id: '',
        name: 'Unknown Property',
        address: '',
        description: '',
        images: [],
        status: 'active',
        unitsOccupied: 0,
        totalUnits: 0,
        occupancy: 0.0,
        monthlyIncome: 0.0,
        amenities: [],
      );
    }

    return Room(
      id: json['_id'] ?? '',
      roomNumber: json['roomNumber'] ?? '',
      property: property,
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
          ? DateTime.tryParse(json['lastRentDate'])
          : null,
      nextRentDue: json['nextRentDue'] != null
          ? DateTime.tryParse(json['nextRentDue'])
          : null,
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

  Room copyWith({
    String? id,
    String? roomNumber,
    PropertyModel.Property? property,
    Tenant? tenant,
    double? rentAmount,
    String? currency,
    String? status,
    String? description,
    List<String>? amenities,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastRentDate,
    DateTime? nextRentDue,
  }) {
    return Room(
      id: id ?? this.id,
      roomNumber: roomNumber ?? this.roomNumber,
      property: property ?? this.property,
      tenant: tenant ?? this.tenant,
      rentAmount: rentAmount ?? this.rentAmount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      description: description ?? this.description,
      amenities: amenities ?? this.amenities,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastRentDate: lastRentDate ?? this.lastRentDate,
      nextRentDue: nextRentDue ?? this.nextRentDue,
    );
  }
}





// import 'package:Peeman/models/tenant.dart';
// import 'package:Peeman/models/property_model.dart' as PropertyModel;
// import 'package:Peeman/models/due_rent_model.dart' hide Property;

// class Room {
//   final String id;
//   final String roomNumber;
//   final PropertyModel.Property property; 
//   final Tenant? tenant;
//   final double rentAmount;
//   final String currency;
//   final String status;
//   final String description;
//   final List<String> amenities;
//   final bool isAvailable;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final DateTime? lastRentDate;
//   final DateTime? nextRentDue;

//   Room({
//     required this.id,
//     required this.roomNumber,
//     required this.property,
//     this.tenant,
//     required this.rentAmount,
//     required this.currency,
//     required this.status,
//     required this.description,
//     required this.amenities,
//     required this.isAvailable,
//     required this.createdAt,
//     required this.updatedAt,
//     this.lastRentDate,
//     this.nextRentDue,
//   });

//   factory Room.fromJson(Map<String, dynamic> json) {
//     return Room(
//       id: json['_id'] ?? '',
//       roomNumber: json['roomNumber'] ?? '',
//       property: PropertyModel.Property.fromJson(json['property'] ?? {}),  // Use the alias
//       tenant: json['tenant'] != null ? Tenant.fromJson(json['tenant']) : null,
//       rentAmount: (json['rentAmount'] as num?)?.toDouble() ?? 0.0,
//       currency: json['currency'] ?? 'USD',
//       status: json['status'] ?? 'available',
//       description: json['description'] ?? '',
//       amenities: json['amenities'] != null ? List<String>.from(json['amenities']) : [],
//       isAvailable: json['isAvailable'] ?? true,
//       createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
//       updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
//       lastRentDate: json['lastRentDate'] != null
//           ? DateTime.tryParse(json['lastRentDate'])
//           : null,
//       nextRentDue: json['nextRentDue'] != null
//           ? DateTime.tryParse(json['nextRentDue'])
//           : null,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         '_id': id,
//         'roomNumber': roomNumber,
//         'property': property.toJson(),
//         'tenant': tenant?.toJson(),
//         'rentAmount': rentAmount,
//         'currency': currency,
//         'status': status,
//         'description': description,
//         'amenities': amenities,
//         'isAvailable': isAvailable,
//         'createdAt': createdAt.toIso8601String(),
//         'updatedAt': updatedAt.toIso8601String(),
//         'lastRentDate': lastRentDate?.toIso8601String(),
//         'nextRentDue': nextRentDue?.toIso8601String(),
//       };

//   Room copyWith({
//     String? id,
//     String? roomNumber,
//     PropertyModel.Property? property,  // Use the alias
//     Tenant? tenant,
//     double? rentAmount,
//     String? currency,
//     String? status,
//     String? description,
//     List<String>? amenities,
//     bool? isAvailable,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//     DateTime? lastRentDate,
//     DateTime? nextRentDue,
//   }) {
//     return Room(
//       id: id ?? this.id,
//       roomNumber: roomNumber ?? this.roomNumber,
//       property: property ?? this.property,
//       tenant: tenant ?? this.tenant,
//       rentAmount: rentAmount ?? this.rentAmount,
//       currency: currency ?? this.currency,
//       status: status ?? this.status,
//       description: description ?? this.description,
//       amenities: amenities ?? this.amenities,
//       isAvailable: isAvailable ?? this.isAvailable,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//       lastRentDate: lastRentDate ?? this.lastRentDate,
//       nextRentDue: nextRentDue ?? this.nextRentDue,
//     );
//   }
// }