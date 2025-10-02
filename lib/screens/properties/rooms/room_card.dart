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
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoomDetailScreen(roomId: room.id),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Gradient accent on the side
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: room.isAvailable
                                  ? [AppColors.green500, AppColors.secondaryTeal]
                                  : [AppColors.red500, AppColors.red600],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Room Number Badge
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primaryBlue,
                                    AppColors.gradientBlue,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryBlue.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  room.roomNumber,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Room Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Room ${room.roomNumber}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.grey800,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: room.isAvailable
                                              ? AppColors.green100
                                              : AppColors.red100,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: room.isAvailable
                                                ? AppColors.green500
                                                : AppColors.red500,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          room.status.toUpperCase(),
                                          style: TextStyle(
                                            color: room.isAvailable
                                                ? AppColors.green500
                                                : AppColors.red500,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.apartment,
                                        size: 14,
                                        color: AppColors.grey400,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          room.property.name,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.grey500,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.purple100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.attach_money,
                                          size: 16,
                                          color: AppColors.purple600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${room.rentAmount} ${room.currency}/month',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.purple600,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Arrow Icon
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.grey100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppColors.grey600,
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
          )
          .toList(),
    );
  }
}





// import 'package:Peeman/constants/colors.dart';
// import 'package:Peeman/models/room_model.dart';
// import 'package:Peeman/screens/properties/rooms/room_detail_screen.dart';
// import 'package:flutter/material.dart';


// class RoomCard extends StatelessWidget {
//   final List<Room> rooms;

//   const RoomCard({super.key, required this.rooms});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: rooms
//           .map(
//             (room) => Padding(
//               padding: const EdgeInsets.only(bottom: 12),
//               child: GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => RoomDetailScreen(roomId: room.id),
//                     ),
//                   );
//                 },
//                 child: Card(
//                   elevation: 2,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 48,
//                           height: 48,
//                           decoration: BoxDecoration(
//                             color: AppColors.grey100,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Center(
//                             child: Text(
//                               room.roomNumber,
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     'Room ${room.roomNumber}',
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   Chip(
//                                     label: Text(
//                                       room.status,
//                                       style: TextStyle(
//                                         color: room.isAvailable
//                                             ? AppColors.green500
//                                             : AppColors.red500,
//                                       ),
//                                     ),
//                                     backgroundColor: room.isAvailable
//                                         ? AppColors.green100
//                                         : AppColors.red100,
//                                   ),
//                                 ],
//                               ),
//                               Text(
//                                 room.property.name,
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: AppColors.grey500,
//                                 ),
//                               ),
//                               Text(
//                                 '${room.rentAmount} ${room.currency}/month',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: AppColors.grey500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           )
//           .toList(),
//     );
//   }
// }