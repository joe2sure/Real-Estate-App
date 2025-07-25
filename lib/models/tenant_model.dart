class Property {
  final String id;
  final String name;
  final String address;

  Property({required this.id, required this.name, required this.address});

  factory Property.fromJson(Map<String, dynamic> json) => Property(
        id: json['_id'],
        name: json['name'],
        address: json['address'],
      );
}

class EmergencyContact {
  final String name;
  final String phone;
  final String relationship;

  EmergencyContact({required this.name, required this.phone, required this.relationship});

  factory EmergencyContact.fromJson(Map<String, dynamic> json) => EmergencyContact(
        name: json['name'],
        phone: json['phone'],
        relationship: json['relationship'],
      );
}

class tenant {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String unit;
  final Property property;
  final double rentAmount;
  final double securityDeposit;
  final DateTime leaseStartDate;
  final DateTime leaseEndDate;
  final String status;
  final DateTime nextPaymentDue;
  final bool isActive;
  final EmergencyContact emergencyContact;
  // Optional fields from the simple model:
  final String? image; // If you want to keep an image field for avatars, etc.

  tenant({
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
    this.image,
  });

  factory tenant.fromJson(Map<String, dynamic> json) => tenant(
        id: json['_id'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        email: json['email'],
        phone: json['phone'],
        unit: json['unit'],
        property: Property.fromJson(json['property']),
        rentAmount: (json['rentAmount'] as num).toDouble(),
        securityDeposit: (json['securityDeposit'] as num).toDouble(),
        leaseStartDate: DateTime.parse(json['leaseStartDate']),
        leaseEndDate: DateTime.parse(json['leaseEndDate']),
        status: json['status'],
        nextPaymentDue: DateTime.parse(json['nextPaymentDue']),
        isActive: json['isActive'],
        emergencyContact: EmergencyContact.fromJson(json['emergencyContact']),
        image: json['image'], // Optional, if present in your API
      );
}


// class Tenant {
//   final String name;
//   final String unit;
//   final String image;
//   final String status;
//   final String phone;

//   Tenant({
//     required this.name,
//     required this.unit,
//     required this.image,
//     required this.status,
//     required this.phone,
//   });
// }