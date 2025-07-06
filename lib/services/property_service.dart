import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '../constants/api.dart';
import '../models/property_model.dart';

class PropertyService {
  Future<List<Property>> fetchProperties(String token) async {
    try {
      debugPrint('PropertyService: Sending GET request to ${ApiEndpoints.properties}');
      final response = await http.get(
        Uri.parse(ApiEndpoints.properties),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('PropertyService: Fetch response status: ${response.statusCode}');
      debugPrint('PropertyService: Fetch response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['data'] as List).map((json) {
            debugPrint('PropertyService: Parsing property JSON: $json');
            return Property.fromJson(json);
          }).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch properties');
        }
      } else {
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('PropertyService: Error in fetchProperties: $e');
      rethrow;
    }
  }

  Future<Property> createProperty({
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
    try {
      final uri = Uri.parse(ApiEndpoints.properties);
      if (imagePaths != null && imagePaths.isNotEmpty) {
        debugPrint('PropertyService: Sending POST form-data to $uri');
        final request = http.MultipartRequest('POST', uri);
        request.headers['Authorization'] = 'Bearer $token';
        request.fields['name'] = name;
        request.fields['address'] = address;
        request.fields['description'] = description;
        request.fields['totalUnits'] = totalUnits.toString();
        request.fields['occupiedUnits'] = occupiedUnits.toString();
        request.fields['monthlyIncome'] = monthlyIncome.toString();
        request.fields['status'] = status;
        for (int i = 0; i < amenities.length; i++) {
          request.fields['amenities[$i]'] = amenities[i];
        }
        for (String path in imagePaths) {
          debugPrint('PropertyService: Adding image file: $path');
          request.files.add(await http.MultipartFile.fromPath(
            'images',
            path,
            contentType: MediaType('image', 'jpeg'),
          ));
        }

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        debugPrint('PropertyService: Create form-data response status: ${response.statusCode}');
        debugPrint('PropertyService: Create form-data response body: ${response.body}');

        if (response.statusCode == 201 || response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success']) {
            debugPrint('PropertyService: Parsing created property JSON: ${data['data']}');
            return Property.fromJson(data['data']);
          } else {
            throw Exception(data['message'] ?? 'Failed to create property');
          }
        } else {
          throw Exception('Server error: ${response.statusCode} - ${response.body}');
        }
      } else {
        debugPrint('PropertyService: Sending POST JSON to $uri');
        final response = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'name': name,
            'address': address,
            'description': description,
            'totalUnits': totalUnits,
            'occupiedUnits': occupiedUnits,
            'monthlyIncome': monthlyIncome,
            'status': status,
            'amenities': amenities,
            'images': imageUrls ?? [],
          }),
        );

        debugPrint('PropertyService: Create JSON response status: ${response.statusCode}');
        debugPrint('PropertyService: Create JSON response body: ${response.body}');

        if (response.statusCode == 201 || response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success']) {
            debugPrint('PropertyService: Parsing created property JSON: ${data['data']}');
            return Property.fromJson(data['data']);
          } else {
            throw Exception(data['message'] ?? 'Failed to create property');
          }
        } else {
          throw Exception('Server error: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      debugPrint('PropertyService: Error in createProperty: $e');
      rethrow;
    }
  }
}






// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'dart:convert';
// import '../constants/api.dart';
// import '../models/property_model.dart';

// class PropertyService {
//   Future<List<Property>> fetchProperties(String token) async {
//     try {
//       debugPrint('PropertyService: Sending GET request to ${ApiEndpoints.properties}');
//       final response = await http.get(
//         Uri.parse(ApiEndpoints.properties),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       debugPrint('PropertyService: Fetch response status: ${response.statusCode}');
//       debugPrint('PropertyService: Fetch response body: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success']) {
//           return (data['data'] as List).map((json) => Property.fromJson(json)).toList();
//         } else {
//           throw Exception(data['message'] ?? 'Failed to fetch properties');
//         }
//       } else {
//         throw Exception('Server error: ${response.statusCode} - ${response.body}');
//       }
//     } catch (e) {
//       debugPrint('PropertyService: Error in fetchProperties: $e');
//       rethrow;
//     }
//   }

//   Future<Property> createProperty({
//     required String token,
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
//     try {
//       final uri = Uri.parse(ApiEndpoints.properties);
//       if (imagePaths != null && imagePaths.isNotEmpty) {
//         // Use form-data for local image uploads
//         debugPrint('PropertyService: Sending POST form-data to $uri');
//         final request = http.MultipartRequest('POST', uri);
//         request.headers['Authorization'] = 'Bearer $token';
//         request.fields['name'] = name;
//         request.fields['address'] = address;
//         request.fields['description'] = description;
//         request.fields['totalUnits'] = totalUnits.toString();
//         request.fields['occupiedUnits'] = occupiedUnits.toString();
//         request.fields['monthlyIncome'] = monthlyIncome.toString();
//         request.fields['status'] = status;
//         for (int i = 0; i < amenities.length; i++) {
//           request.fields['amenities[$i]'] = amenities[i];
//         }
//         for (String path in imagePaths) {
//           debugPrint('PropertyService: Adding image file: $path');
//           request.files.add(await http.MultipartFile.fromPath(
//             'images',
//             path,
//             contentType: MediaType('image', 'jpeg'),
//           ));
//         }

//         final streamedResponse = await request.send();
//         final response = await http.Response.fromStream(streamedResponse);

//         debugPrint('PropertyService: Create form-data response status: ${response.statusCode}');
//         debugPrint('PropertyService: Create form-data response body: ${response.body}');

//         if (response.statusCode == 201 || response.statusCode == 200) {
//           final data = jsonDecode(response.body);
//           if (data['success']) {
//             return Property.fromJson(data['data']);
//           } else {
//             throw Exception(data['message'] ?? 'Failed to create property');
//           }
//         } else {
//           throw Exception('Server error: ${response.statusCode} - ${response.body}');
//         }
//       } else {
//         // Use JSON for image URLs or no images
//         debugPrint('PropertyService: Sending POST JSON to $uri');
//         final response = await http.post(
//           uri,
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer $token',
//           },
//           body: jsonEncode({
//             'name': name,
//             'address': address,
//             'description': description,
//             'totalUnits': totalUnits,
//             'occupiedUnits': occupiedUnits,
//             'monthlyIncome': monthlyIncome,
//             'status': status,
//             'amenities': amenities,
//             'images': imageUrls ?? [],
//           }),
//         );

//         debugPrint('PropertyService: Create JSON response status: ${response.statusCode}');
//         debugPrint('PropertyService: Create JSON response body: ${response.body}');

//         if (response.statusCode == 201 || response.statusCode == 200) {
//           final data = jsonDecode(response.body);
//           if (data['success']) {
//             return Property.fromJson(data['data']);
//           } else {
//             throw Exception(data['message'] ?? 'Failed to create property');
//           }
//         } else {
//           throw Exception('Server error: ${response.statusCode} - ${response.body}');
//         }
//       }
//     } catch (e) {
//       debugPrint('PropertyService: Error in createProperty: $e');
//       rethrow;
//     }
//   }
// }