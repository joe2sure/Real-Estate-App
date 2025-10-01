import 'package:Peeman/providers/auth_provider.dart';
import 'package:Peeman/providers/room_provider.dart';
import 'package:Peeman/screens/properties/rooms/room_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class AvailableRoomsScreen extends StatefulWidget {
  const AvailableRoomsScreen({super.key});

  @override
  State<AvailableRoomsScreen> createState() => _AvailableRoomsScreenState();
}

class _AvailableRoomsScreenState extends State<AvailableRoomsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<RoomProvider>(context, listen: false).fetchAvailableRooms(authProvider.token!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Rooms'),
      ),
      body: roomProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : roomProvider.rooms.isEmpty
              ? const Center(child: Text('No available rooms found'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: RoomCard(rooms: roomProvider.rooms),
                ),
    );
  }
}