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