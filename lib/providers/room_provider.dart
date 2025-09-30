import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/room_model.dart';
import '../services/room_service.dart';
import '../providers/auth_provider.dart';

enum RoomState { idle, loading, error }

class RoomProvider with ChangeNotifier {
  final RoomService _roomService = RoomService();
  List<Room> _rooms = [];
  RoomState _state = RoomState.idle;
  String? _errorMessage;

  List<Room> get rooms => _rooms;
  RoomState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == RoomState.loading;

  Future<void> fetchAllRooms(BuildContext context) async {
    _state = RoomState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        throw Exception('No authentication token found. Please log in.');
      }
      _rooms = await _roomService.fetchAllRooms(token);
      _state = RoomState.idle;
      notifyListeners();
    } catch (e) {
      _state = RoomState.error;
      _errorMessage = 'Failed to fetch rooms: $e';
      notifyListeners();
    }
  }

  Future<void> fetchRoomsByProperty(BuildContext context, String propertyId) async {
    _state = RoomState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        throw Exception('No authentication token found. Please log in.');
      }
      _rooms = await _roomService.fetchRoomsByProperty(token, propertyId);
      _state = RoomState.idle;
      notifyListeners();
    } catch (e) {
      _state = RoomState.error;
      _errorMessage = 'Failed to fetch rooms: $e';
      notifyListeners();
    }
  }

  Future<void> fetchAvailableRooms(BuildContext context) async {
    _state = RoomState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        throw Exception('No authentication token found. Please log in.');
      }
      _rooms = await _roomService.fetchAvailableRooms(token);
      _state = RoomState.idle;
      notifyListeners();
    } catch (e) {
      _state = RoomState.error;
      _errorMessage = 'Failed to fetch available rooms: $e';
      notifyListeners();
    }
  }

  Future<void> createRoom(BuildContext context, Map<String, dynamic> roomData) async {
    _state = RoomState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        throw Exception('No authentication token found. Please log in.');
      }
      final newRoom = await _roomService.createRoom(token, roomData);
      _rooms.insert(0, newRoom);
      _state = RoomState.idle;
      notifyListeners();
    } catch (e) {
      _state = RoomState.error;
      _errorMessage = 'Failed to create room: $e';
      notifyListeners();
    }
  }

  Future<void> updateRoom(BuildContext context, String roomId, Map<String, dynamic> roomData) async {
    _state = RoomState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        throw Exception('No authentication token found. Please log in.');
      }
      final updatedRoom = await _roomService.updateRoom(token, roomId, roomData);
      final index = _rooms.indexWhere((r) => r.id == roomId);
      if (index != -1) {
        _rooms[index] = updatedRoom;
      }
      _state = RoomState.idle;
      notifyListeners();
    } catch (e) {
      _state = RoomState.error;
      _errorMessage = 'Failed to update room: $e';
      notifyListeners();
    }
  }

  Future<void> deleteRoom(BuildContext context, String roomId) async {
    _state = RoomState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        throw Exception('No authentication token found. Please log in.');
      }
      await _roomService.deleteRoom(token, roomId);
      _rooms.removeWhere((r) => r.id == roomId);
      _state = RoomState.idle;
      notifyListeners();
    } catch (e) {
      _state = RoomState.error;
      _errorMessage = 'Failed to delete room: $e';
      notifyListeners();
    }
  }

  Future<void> assignTenantToRoom(BuildContext context, String roomId, String tenantId) async {
    _state = RoomState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        throw Exception('No authentication token found. Please log in.');
      }
      final updatedRoom = await _roomService.assignTenantToRoom(token, roomId, tenantId);
      final index = _rooms.indexWhere((r) => r.id == roomId);
      if (index != -1) {
        _rooms[index] = updatedRoom;
      }
      _state = RoomState.idle;
      notifyListeners();
    } catch (e) {
      _state = RoomState.error;
      _errorMessage = 'Failed to assign tenant: $e';
      notifyListeners();
    }
  }

  Future<void> removeTenantFromRoom(BuildContext context, String roomId) async {
    _state = RoomState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        throw Exception('No authentication token found. Please log in.');
      }
      await _roomService.removeTenantFromRoom(token, roomId);
      final index = _rooms.indexWhere((r) => r.id == roomId);
      if (index != -1) {
        _rooms[index] = _rooms[index].copyWith(tenant: null, isAvailable: true, status: 'available');
      }
      _state = RoomState.idle;
      notifyListeners();
    } catch (e) {
      _state = RoomState.error;
      _errorMessage = 'Failed to remove tenant: $e';
      notifyListeners();
    }
  }

  Future<Room?> fetchRoomById(BuildContext context, String roomId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        throw Exception('No authentication token found. Please log in.');
      }
      return await _roomService.fetchRoomById(token, roomId);
    } catch (e) {
      _errorMessage = 'Failed to fetch room: $e';
      notifyListeners();
      return null;
    }
  }
}