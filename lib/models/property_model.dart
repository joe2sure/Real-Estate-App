class Property {
  final String id;
  final String name;
  final String address;
  final String description;
  final List<String> images;
  final String status;
  final int unitsOccupied;
  final int totalUnits;
  final double occupancy;
  final double monthlyIncome;
  final List<String> amenities;

  Property({
    required this.id,
    required this.name,
    required this.address,
    required this.description,
    required this.images,
    required this.status,
    required this.unitsOccupied,
    required this.totalUnits,
    required this.occupancy,
    required this.monthlyIncome,
    required this.amenities,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    // Calculate occupancy if not provided in the response
    final double occupancy = json['occupancyRate'] != null
        ? (json['occupancyRate'] is num
            ? json['occupancyRate'].toDouble()
            : double.tryParse(json['occupancyRate'].toString()) ?? 0.0)
        : (json['totalUnits'] != null &&
                json['totalUnits'] != 0 &&
                json['occupiedUnits'] != null
            ? (json['occupiedUnits'] / json['totalUnits'] * 100)
            : 0.0);

    return Property(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      description: json['description'] ?? '',
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : ['https://via.placeholder.com/150'],
      status: json['status'] ?? 'active',
      unitsOccupied: json['occupiedUnits'] ?? 0,
      totalUnits: json['totalUnits'] ?? 0,
      occupancy: occupancy,
      monthlyIncome: json['monthlyIncome'] != null
          ? (json['monthlyIncome'] is num
              ? json['monthlyIncome'].toDouble()
              : double.tryParse(json['monthlyIncome'].toString()) ?? 0.0)
          : 0.0,
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'])
          : [],
    );
  }

  // Getter for first image to maintain compatibility with PropertyCard
  String get image => images.isNotEmpty ? images[0] : 'https://via.placeholder.com/150';

  Property copyWith({
    String? id,
    String? name,
    String? address,
    String? description,
    List<String>? images,
    String? status,
    int? unitsOccupied,
    int? totalUnits,
    double? occupancy,
    double? monthlyIncome,
    List<String>? amenities,
  }) {
    return Property(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      description: description ?? this.description,
      images: images ?? this.images,
      status: status ?? this.status,
      unitsOccupied: unitsOccupied ?? this.unitsOccupied,
      totalUnits: totalUnits ?? this.totalUnits,
      occupancy: occupancy ?? this.occupancy,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      amenities: amenities ?? this.amenities,
    );
  }
}





// class Property {
//   final String id;
//   final String name;
//   final String address;
//   final String image; // Using first image from API's images array
//   final String status;
//   final int unitsOccupied;
//   final int totalUnits;
//   final double occupancy;
//   final double monthlyIncome;

//   Property({
//     required this.id,
//     required this.name,
//     required this.address,
//     required this.image,
//     required this.status,
//     required this.unitsOccupied,
//     required this.totalUnits,
//     required this.occupancy,
//     required this.monthlyIncome,
//   });

//   factory Property.fromJson(Map<String, dynamic> json) {
//     return Property(
//       id: json['_id'],
//       name: json['name'],
//       address: json['address'],
//       image: json['images'] != null && json['images'].isNotEmpty
//           ? json['images'][0]
//           : 'https://via.placeholder.com/150', // Fallback image
//       status: json['status'],
//       unitsOccupied: json['occupiedUnits'],
//       totalUnits: json['totalUnits'],
//       occupancy: json['occupancyRate'].toDouble(),
//       monthlyIncome: json['monthlyIncome'].toDouble(),
//     );
//   }

//   Property copyWith({
//     String? id,
//     String? name,
//     String? address,
//     String? image,
//     String? status,
//     int? unitsOccupied,
//     int? totalUnits,
//     double? occupancy,
//     double? monthlyIncome,
//   }) {
//     return Property(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       address: address ?? this.address,
//       image: image ?? this.image,
//       status: status ?? this.status,
//       unitsOccupied: unitsOccupied ?? this.unitsOccupied,
//       totalUnits: totalUnits ?? this.totalUnits,
//       occupancy: occupancy ?? this.occupancy,
//       monthlyIncome: monthlyIncome ?? this.monthlyIncome,
//     );
//   }
// }