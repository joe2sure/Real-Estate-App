import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api.dart';
import '../models/room_model.dart';
import '../models/tenant_model.dart';

class RoomService {
  Future<List<Room>> fetchAllRooms(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/rooms'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return (data['data']['rooms'] as List)
              .map((json) => Room.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch rooms');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch rooms: $e');
    }
  }

  Future<List<Room>> fetchRoomsByProperty(String token, String propertyId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/properties/$propertyId/rooms'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return (data['data']['rooms'] as List)
              .map((json) => Room.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch rooms');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch rooms by property: $e');
    }
  }

  Future<List<Room>> fetchAvailableRooms(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/rooms/available'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return (data['data']['rooms'] as List)
              .map((json) => Room.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch available rooms');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch available rooms: $e');
    }
  }

  Future<Room> createRoom(String token, Map<String, dynamic> roomData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/rooms'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(roomData),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return Room.fromJson(data['data']['room']);
        } else {
          throw Exception(data['message'] ?? 'Failed to create room');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create room: $e');
    }
  }

  Future<Room> updateRoom(String token, String roomId, Map<String, dynamic> roomData) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiEndpoints.baseUrl}/rooms/$roomId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(roomData),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return Room.fromJson(data['data']['room']);
        } else {
          throw Exception(data['message'] ?? 'Failed to update room');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update room: $e');
    }
  }

  Future<void> deleteRoom(String token, String roomId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiEndpoints.baseUrl}/rooms/$roomId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!data['success']) {
          throw Exception(data['message'] ?? 'Failed to delete room');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete room: $e');
    }
  }

  Future<Room> assignTenantToRoom(String token, String roomId, String tenantId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/rooms/assign-tenant'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'roomId': roomId, 'tenantId': tenantId}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return Room.fromJson(data['data']['room']);
        } else {
          throw Exception(data['message'] ?? 'Failed to assign tenant');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to assign tenant: $e');
    }
  }

  Future<void> removeTenantFromRoom(String token, String roomId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/rooms/$roomId/remove-tenant'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!data['success']) {
          throw Exception(data['message'] ?? 'Failed to remove tenant');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to remove tenant: $e');
    }
  }

  Future<Room> fetchRoomById(String token, String roomId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/rooms/$roomId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return Room.fromJson(data['data']['room']);
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch room');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch room: $e');
    }
  }
}