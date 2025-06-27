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
}