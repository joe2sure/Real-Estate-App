import 'package:Peeman/constants/colors.dart';
import 'package:Peeman/models/room_model.dart';
import 'package:Peeman/providers/auth_provider.dart';
import 'package:Peeman/providers/room_provider.dart';
import 'package:Peeman/widgets/custom_toaster.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'update_room_form.dart';

class RoomDetailScreen extends StatefulWidget {
  final String roomId;
  const RoomDetailScreen({super.key, required this.roomId});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  Room? _room;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRoom();
  }

  Future<void> _fetchRoom() async {
    try {
      final room = await Provider.of<RoomProvider>(context, listen: false)
          .fetchRoomById(context, widget.roomId);
      setState(() {
        _room = room;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      CustomToast.show(context, 'Failed to load room: $e', isSuccess: false);
    }
  }

  Future<void> _deleteRoom() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Room'),
        content: const Text('Are you sure you want to delete this room?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.red500)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await Provider.of<RoomProvider>(context, listen: false).deleteRoom(context, widget.roomId);
      if (Provider.of<RoomProvider>(context, listen: false).errorMessage == null) {
        Navigator.pop(context);
        CustomToast.show(context, 'Room deleted successfully');
      } else {
        CustomToast.show(context,
            Provider.of<RoomProvider>(context, listen: false).errorMessage!, isSuccess: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.currentUser?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Text(_room != null ? 'Room ${_room!.roomNumber}' : 'Room Details'),
        actions: isAdmin && _room != null
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => UpdateRoomForm(room: _room!),
                    ).then((_) => _fetchRoom());
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.red500),
                  onPressed: _deleteRoom,
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _room == null
              ? const Center(child: Text('Failed to load room'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _infoRow('Room Number', _room!.roomNumber),
                              _infoRow('Property', _room!.property.name),
                              _infoRow('Status', _room!.status),
                              _infoRow('Rent Amount', '${_room!.rentAmount} ${_room!.currency}'),
                              _infoRow('Description', _room!.description),
                              if (_room!.tenant != null)
                                _infoRow('Tenant',
                                    '${_room!.tenant!.firstName} ${_room!.tenant!.lastName}'),
                              if (_room!.lastRentDate != null)
                                _infoRow('Last Rent Date',
                                    DateFormat('yyyy-MM-dd').format(_room!.lastRentDate!)),
                              if (_room!.nextRentDue != null)
                                _infoRow('Next Rent Due',
                                    DateFormat('yyyy-MM-dd').format(_room!.nextRentDue!)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Amenities',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _room!.amenities
                            .map((amenity) => Chip(
                                  label: Text(amenity),
                                  backgroundColor: AppColors.grey100,
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}