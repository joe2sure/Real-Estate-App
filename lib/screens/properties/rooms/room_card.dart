import 'package:Peeman/constants/colors.dart';
import 'package:Peeman/models/room_model.dart';
import 'package:Peeman/screens/properties/rooms/room_detail_screen.dart';
import 'package:flutter/material.dart';


class RoomCard extends StatelessWidget {
  final List<Room> rooms;

  const RoomCard({super.key, required this.rooms});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rooms
          .map(
            (room) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoomDetailScreen(roomId: room.id),
                    ),
                  );
                },
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              room.roomNumber,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Room ${room.roomNumber}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      room.status,
                                      style: TextStyle(
                                        color: room.isAvailable
                                            ? AppColors.green500
                                            : AppColors.red500,
                                      ),
                                    ),
                                    backgroundColor: room.isAvailable
                                        ? AppColors.green100
                                        : AppColors.red100,
                                  ),
                                ],
                              ),
                              Text(
                                room.property.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.grey500,
                                ),
                              ),
                              Text(
                                '${room.rentAmount} ${room.currency}/month',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.grey500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}