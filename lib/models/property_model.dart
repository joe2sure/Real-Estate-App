class Property {
  final String id;
  final String name;
  final String address;
  final String image; // Using first image from API's images array
  final String status;
  final int unitsOccupied;
  final int totalUnits;
  final double occupancy;
  final double monthlyIncome;

  Property({
    required this.id,
    required this.name,
    required this.address,
    required this.image,
    required this.status,
    required this.unitsOccupied,
    required this.totalUnits,
    required this.occupancy,
    required this.monthlyIncome,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['_id'],
      name: json['name'],
      address: json['address'],
      image: json['images'] != null && json['images'].isNotEmpty
          ? json['images'][0]
          : 'https://via.placeholder.com/150', // Fallback image
      status: json['status'],
      unitsOccupied: json['occupiedUnits'],
      totalUnits: json['totalUnits'],
      occupancy: json['occupancyRate'].toDouble(),
      monthlyIncome: json['monthlyIncome'].toDouble(),
    );
  }

  Property copyWith({
    String? id,
    String? name,
    String? address,
    String? image,
    String? status,
    int? unitsOccupied,
    int? totalUnits,
    double? occupancy,
    double? monthlyIncome,
  }) {
    return Property(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      image: image ?? this.image,
      status: status ?? this.status,
      unitsOccupied: unitsOccupied ?? this.unitsOccupied,
      totalUnits: totalUnits ?? this.totalUnits,
      occupancy: occupancy ?? this.occupancy,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
    );
  }
}