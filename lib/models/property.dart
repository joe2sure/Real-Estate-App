class Property {
  final String name;
  final String address;
  final String image;
  final String status;
  final int unitsOccupied;
  final int totalUnits;
  final double occupancy;
  final double monthlyIncome;

  Property({
    required this.name,
    required this.address,
    required this.image,
    required this.status,
    required this.unitsOccupied,
    required this.totalUnits,
    required this.occupancy,
    required this.monthlyIncome,
  });

  // Optional: Add copyWith method for immutability
  Property copyWith({
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