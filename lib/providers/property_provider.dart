import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/property_model.dart';
import '../services/property_service.dart';
import '../providers/auth_provider.dart';

enum PropertyState { idle, loading, error }

class PropertyProvider with ChangeNotifier {
  final PropertyService _propertyService = PropertyService();
  List<Property> _properties = [];
  PropertyState _state = PropertyState.idle;
  String? _errorMessage;

  List<Property> get properties => _properties;
  PropertyState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == PropertyState.loading;

  // Original method that requires BuildContext (keeping for backward compatibility)
  Future<void> fetchProperties({required BuildContext context}) async {
    _state = PropertyState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        _state = PropertyState.error;
        _errorMessage = 'No authentication token found. Please log in.';
        debugPrint('PropertyProvider: Token is null');
        notifyListeners();
        return;
      }
      debugPrint('PropertyProvider: Fetching properties with token: $token');
      _properties = await _propertyService.fetchProperties(token);
      _state = PropertyState.idle;
      notifyListeners();
    } catch (e) {
      _state = PropertyState.error;
      _errorMessage = 'Failed to fetch properties: $e';
      debugPrint('PropertyProvider: Error fetching properties: $e');
      notifyListeners();
    }
  }

  // New method that accepts token directly (for payment forms)
  Future<void> fetchPropertiesWithToken(String token) async {
    _state = PropertyState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('PropertyProvider: Fetching properties with token: $token');
      _properties = await _propertyService.fetchProperties(token);
      _state = PropertyState.idle;
      notifyListeners();
    } catch (e) {
      _state = PropertyState.error;
      _errorMessage = 'Failed to fetch properties: $e';
      debugPrint('PropertyProvider: Error fetching properties: $e');
      notifyListeners();
    }
  }

  Future<void> createProperty({
    required BuildContext context,
    required String name,
    required String address,
    required String description,
    required int totalUnits,
    required int occupiedUnits,
    required double monthlyIncome,
    required String status,
    required List<String> amenities,
    List<String>? imageUrls,
    List<String>? imagePaths,
  }) async {
    _state = PropertyState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        _state = PropertyState.error;
        _errorMessage = 'No authentication token found. Please log in.';
        debugPrint('PropertyProvider: Token is null for createProperty');
        notifyListeners();
        return;
      }
      debugPrint('PropertyProvider: Creating property with token: $token');
      final newProperty = await _propertyService.createProperty(
        token: token,
        name: name,
        address: address,
        description: description,
        totalUnits: totalUnits,
        occupiedUnits: occupiedUnits,
        monthlyIncome: monthlyIncome,
        status: status,
        amenities: amenities,
        imageUrls: imageUrls,
        imagePaths: imagePaths,
      );
      _properties.insert(0, newProperty); // Add new property at the top
      _state = PropertyState.idle;
      notifyListeners();
      debugPrint('PropertyProvider: Property created successfully: ${newProperty.name}');
    } catch (e) {
      _state = PropertyState.error;
      _errorMessage = 'Failed to create property: $e';
      debugPrint('PropertyProvider: Error creating property: $e');
      notifyListeners();
    }
  }

  // Token-based version for creating property
  Future<Property?> createPropertyWithToken({
    required String token,
    required String name,
    required String address,
    required String description,
    required int totalUnits,
    required int occupiedUnits,
    required double monthlyIncome,
    required String status,
    required List<String> amenities,
    List<String>? imageUrls,
    List<String>? imagePaths,
  }) async {
    _state = PropertyState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('PropertyProvider: Creating property with token: $token');
      final newProperty = await _propertyService.createProperty(
        token: token,
        name: name,
        address: address,
        description: description,
        totalUnits: totalUnits,
        occupiedUnits: occupiedUnits,
        monthlyIncome: monthlyIncome,
        status: status,
        amenities: amenities,
        imageUrls: imageUrls,
        imagePaths: imagePaths,
      );
      _properties.insert(0, newProperty); // Add new property at the top
      _state = PropertyState.idle;
      notifyListeners();
      debugPrint('PropertyProvider: Property created successfully: ${newProperty.name}');
      return newProperty;
    } catch (e) {
      _state = PropertyState.error;
      _errorMessage = 'Failed to create property: $e';
      notifyListeners();
      return null;
    }
  }

  // Update property method
  Future<void> updateProperty({
    required BuildContext context,
    required String propertyId,
    required String name,
    required String address,
    required String description,
    required int totalUnits,
    required int occupiedUnits,
    required double monthlyIncome,
    required String status,
    required List<String> amenities,
    List<String>? imageUrls,
    List<String>? imagePaths,
  }) async {
    _state = PropertyState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        _state = PropertyState.error;
        _errorMessage = 'No authentication token found. Please log in.';
        notifyListeners();
        return;
      }

      // Note: You'll need to implement updateProperty in PropertyService
      // For now, this is a placeholder structure
      final updatedProperty = await _propertyService.updateProperty(
        token: token,
        propertyId: propertyId,
        name: name,
        address: address,
        description: description,
        totalUnits: totalUnits,
        occupiedUnits: occupiedUnits,
        monthlyIncome: monthlyIncome,
        status: status,
        amenities: amenities,
        imageUrls: imageUrls,
        imagePaths: imagePaths,
      );

      final index = _properties.indexWhere((p) => p.id == propertyId);
      if (index != -1) {
        _properties[index] = updatedProperty;
      }
      _state = PropertyState.idle;
      notifyListeners();
    } catch (e) {
      _state = PropertyState.error;
      _errorMessage = 'Failed to update property: $e';
      notifyListeners();
    }
  }

  // Delete property method
  Future<void> deleteProperty(BuildContext context, String propertyId) async {
    _state = PropertyState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        _state = PropertyState.error;
        _errorMessage = 'No authentication token found. Please log in.';
        notifyListeners();
        return;
      }

      // Note: You'll need to implement deleteProperty in PropertyService
      await _propertyService.deleteProperty(token, propertyId);
      _properties.removeWhere((p) => p.id == propertyId);
      _state = PropertyState.idle;
      notifyListeners();
    } catch (e) {
      _state = PropertyState.error;
      _errorMessage = 'Failed to delete property: $e';
      notifyListeners();
    }
  }

  // Get property by ID
  Future<Property?> getPropertyById(BuildContext context, String propertyId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        throw Exception('No authentication token found. Please log in.');
      }

      // Note: You'll need to implement getPropertyById in PropertyService
      return await _propertyService.getPropertyById(token, propertyId);
    } catch (e) {
      _errorMessage = 'Failed to fetch property: $e';
      return null;
    }
  }

  // Token-based version
  Future<Property?> getPropertyByIdWithToken(String token, String propertyId) async {
    try {
      return await _propertyService.getPropertyById(token, propertyId);
    } catch (e) {
      _errorMessage = 'Failed to fetch property: $e';
      return null;
    }
  }

  // Utility methods
  void clearProperties() {
    _properties.clear();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_state == PropertyState.error) {
      _state = PropertyState.idle;
    }
    notifyListeners();
  }

  // Get property by ID from current list
  Property? getPropertyFromList(String propertyId) {
    try {
      return _properties.firstWhere((property) => property.id == propertyId);
    } catch (e) {
      return null;
    }
  }

  // Filter properties by status from current list
  List<Property> getPropertiesByStatus(String status) {
    return _properties.where((property) => property.status.toLowerCase() == status.toLowerCase()).toList();
  }

  // Search properties by name or address
  List<Property> searchProperties(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _properties.where((property) =>
        property.name.toLowerCase().contains(lowercaseQuery) ||
        property.address.toLowerCase().contains(lowercaseQuery)).toList();
  }

  // Get total properties count
  int get totalProperties => _properties.length;

  // Get occupied units count - fix return type
  // int get totalOccupiedUnits => _properties.fold(0, (int sum, property) => sum + property.occupiedUnits);
    // Get occupied units count - FIXED: use unitsOccupied instead of occupiedUnits
  int get totalOccupiedUnits => _properties.fold(0, (int sum, property) => sum + property.unitsOccupied);

  // Get total units count - fix return type  
  int get totalUnits => _properties.fold(0, (int sum, property) => sum + property.totalUnits);

  // Get total monthly income - fix return type
  double get totalMonthlyIncome => _properties.fold(0.0, (double sum, property) => sum + property.monthlyIncome);
}





// import 'package:flutter/material.dart';
// import '../models/property_model.dart';
// import '../services/property_service.dart';
// import '../providers/auth_provider.dart';

// enum PropertyState { idle, loading, error }

// class PropertyProvider with ChangeNotifier {
//   final PropertyService _propertyService = PropertyService();
//   List<Property> _properties = [];
//   PropertyState _state = PropertyState.idle;
//   String? _errorMessage;

//   List<Property> get properties => _properties;
//   PropertyState get state => _state;
//   String? get errorMessage => _errorMessage;
//   bool get isLoading => _state == PropertyState.loading;

//   Future<void> fetchProperties() async {
//     _state = PropertyState.loading;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       final token = AuthProvider().token;
//       if (token == null) {
//         _state = PropertyState.error;
//         _errorMessage = 'Please log in to view properties';
//         notifyListeners();
//         return;
//       }
//       _properties = await _propertyService.fetchProperties(token);
//       _state = PropertyState.idle;
//       notifyListeners();
//     } catch (e) {
//       _state = PropertyState.error;
//       _errorMessage = e.toString();
//       notifyListeners();
//     }
//   }

//   Future<void> createProperty({
//     required String name,
//     required String address,
//     required String description,
//     required int totalUnits,
//     required int occupiedUnits,
//     required double monthlyIncome,
//     required String status,
//     required List<String> amenities,
//     List<String>? imageUrls,
//     List<String>? imagePaths,
//   }) async {
//     _state = PropertyState.loading;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       final token = AuthProvider().token;
//       if (token == null) {
//         _state = PropertyState.error;
//         _errorMessage = 'Please log in to add a property';
//         notifyListeners();
//         return;
//       }
//       final newProperty = await _propertyService.createProperty(
//         token: token,
//         name: name,
//         address: address,
//         description: description,
//         totalUnits: totalUnits,
//         occupiedUnits: occupiedUnits,
//         monthlyIncome: monthlyIncome,
//         status: status,
//         amenities: amenities,
//         imageUrls: imageUrls,
//         imagePaths: imagePaths,
//       );
//       _properties.insert(0, newProperty); // Add new property at the top
//       _state = PropertyState.idle;
//       notifyListeners();
//     } catch (e) {
//       _state = PropertyState.error;
//       _errorMessage = e.toString();
//       notifyListeners();
//     }
//   }
// }