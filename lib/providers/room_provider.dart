import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../services/room_service.dart';

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

  Future<void> fetchAllRooms(String token) async {
    _state = RoomState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _rooms = await _roomService.fetchAllRooms(token);
      _state = RoomState.idle;
      notifyListeners();
    } catch (e) {
      _state = RoomState.error;
      _errorMessage = 'Failed to fetch rooms: $e';
      notifyListeners();
    }
  }

  Future<void> fetchRoomsByProperty(String token, String propertyId) async {
    _state = RoomState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _rooms = await _roomService.fetchRoomsByProperty(token, propertyId);
      _state = RoomState.idle;
      notifyListeners();
    } catch (e) {
      _state = RoomState.error;
      _errorMessage = 'Failed to fetch rooms: $e';
      notifyListeners();
    }
  }

  Future<void> fetchAvailableRooms(String token) async {
    _state = RoomState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _rooms = await _roomService.fetchAvailableRooms(token);
      _state = RoomState.idle;
      notifyListeners();
    } catch (e) {
      _state = RoomState.error;
      _errorMessage = 'Failed to fetch available rooms: $e';
      notifyListeners();
    }
  }

  Future<void> createRoom(String token, Map<String, dynamic> roomData) async {
    _state = RoomState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
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

  Future<void> updateRoom(String token, String roomId, Map<String, dynamic> roomData) async {
    _state = RoomState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
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

  Future<void> deleteRoom(String token, String roomId) async {
    _state = RoomState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
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

  Future<void> assignTenantToRoom(String token, String roomId, String tenantId) async {
    _state = RoomState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
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

  Future<void> removeTenantFromRoom(String token, String roomId) async {
    _state = RoomState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
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

  Future<Room?> fetchRoomById(String token, String roomId) async {
    try {
      return await _roomService.fetchRoomById(token, roomId);
    } catch (e) {
      _errorMessage = 'Failed to fetch room: $e';
      notifyListeners();
      return null;
    }
  }
}