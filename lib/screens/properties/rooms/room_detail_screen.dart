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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final room = await Provider.of<RoomProvider>(context, listen: false)
          .fetchRoomById(authProvider.token!, widget.roomId);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Room'),
        content: const Text('Are you sure you want to delete this room? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red500,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await Provider.of<RoomProvider>(context, listen: false)
          .deleteRoom(authProvider.token!, widget.roomId);
      if (Provider.of<RoomProvider>(context, listen: false).errorMessage == null) {
        Navigator.pop(context);
        CustomToast.show(context, 'Room deleted successfully');
      } else {
        CustomToast.show(
            context, Provider.of<RoomProvider>(context, listen: false).errorMessage!,
            isSuccess: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.currentUser?.role == 'admin';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _room == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: AppColors.grey400),
                      const SizedBox(height: 16),
                      const Text('Failed to load room'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchRoom,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    // Modern App Bar
                    SliverAppBar(
                      expandedHeight: 200,
                      pinned: true,
                      backgroundColor: AppColors.primaryBlue,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primaryBlue,
                                AppColors.gradientBlue,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 60),
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _room!.roomNumber,
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Room ${_room!.roomNumber}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      actions: isAdmin
                          ? [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => UpdateRoomForm(room: _room!),
                                  ).then((_) => _fetchRoom());
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: _deleteRoom,
                              ),
                            ]
                          : null,
                    ),
                    // Content
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status Badge
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: _room!.isAvailable
                                      ? AppColors.green500
                                      : AppColors.red500,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_room!.isAvailable
                                              ? AppColors.green500
                                              : AppColors.red500)
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _room!.status.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Rent Card
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.purple600,
                                    AppColors.purple600.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.purple600.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Monthly Rent',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.white.withOpacity(0.9),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${_room!.rentAmount} ${_room!.currency}',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.attach_money,
                                      color: AppColors.white,
                                      size: 32,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Information Card
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryBlue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.info_outline,
                                          color: AppColors.primaryBlue,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Room Information',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.grey800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  _buildInfoRow('Property', _room!.property.name, Icons.apartment),
                                  _buildInfoRow('Room Number', _room!.roomNumber, Icons.meeting_room),
                                  _buildInfoRow('Description', _room!.description, Icons.description),
                                  if (_room!.tenant != null)
                                    _buildInfoRow(
                                      'Tenant',
                                      '${_room!.tenant!.firstName} ${_room!.tenant!.lastName}',
                                      Icons.person,
                                    ),
                                  if (_room!.lastRentDate != null)
                                    _buildInfoRow(
                                      'Last Rent Date',
                                      DateFormat('MMM dd, yyyy').format(_room!.lastRentDate!),
                                      Icons.calendar_today,
                                    ),
                                  if (_room!.nextRentDue != null)
                                    _buildInfoRow(
                                      'Next Rent Due',
                                      DateFormat('MMM dd, yyyy').format(_room!.nextRentDue!),
                                      Icons.event,
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Amenities Card
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondaryTeal.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.star,
                                          color: AppColors.secondaryTeal,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Amenities',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.grey800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _room!.amenities.isEmpty
                                      ? Text(
                                          'No amenities listed',
                                          style: TextStyle(color: AppColors.grey500),
                                        )
                                      : Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: _room!.amenities.map((amenity) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 10),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppColors.secondaryTeal.withOpacity(0.1),
                                                    AppColors.secondaryTeal.withOpacity(0.05),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: AppColors.secondaryTeal.withOpacity(0.3),
                                                ),
                                              ),
                                              child: Text(
                                                amenity,
                                                style: const TextStyle(
                                                  color: AppColors.secondaryTeal,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.grey800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}





// import 'package:Peeman/constants/colors.dart';
// import 'package:Peeman/models/room_model.dart';
// import 'package:Peeman/providers/auth_provider.dart';
// import 'package:Peeman/providers/room_provider.dart';
// import 'package:Peeman/widgets/custom_toaster.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'update_room_form.dart';

// class RoomDetailScreen extends StatefulWidget {
//   final String roomId;
//   const RoomDetailScreen({super.key, required this.roomId});

//   @override
//   State<RoomDetailScreen> createState() => _RoomDetailScreenState();
// }

// class _RoomDetailScreenState extends State<RoomDetailScreen> {
//   Room? _room;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchRoom();
//   }

//   Future<void> _fetchRoom() async {
//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final room = await Provider.of<RoomProvider>(context, listen: false)
//           .fetchRoomById(authProvider.token!, widget.roomId);
//       setState(() {
//         _room = room;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       CustomToast.show(context, 'Failed to load room: $e', isSuccess: false);
//     }
//   }

//   Future<void> _deleteRoom() async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Room'),
//         content: const Text('Are you sure you want to delete this room?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Delete', style: TextStyle(color: AppColors.red500)),
//           ),
//         ],
//       ),
//     );
//     if (confirm == true) {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       await Provider.of<RoomProvider>(context, listen: false).deleteRoom(authProvider.token!, widget.roomId);
//       if (Provider.of<RoomProvider>(context, listen: false).errorMessage == null) {
//         Navigator.pop(context);
//         CustomToast.show(context, 'Room deleted successfully');
//       } else {
//         CustomToast.show(context,
//             Provider.of<RoomProvider>(context, listen: false).errorMessage!, isSuccess: false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);
//     final isAdmin = authProvider.currentUser?.role == 'admin';

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_room != null ? 'Room ${_room!.roomNumber}' : 'Room Details'),
//         actions: isAdmin && _room != null
//             ? [
//                 IconButton(
//                   icon: const Icon(Icons.edit),
//                   onPressed: () {
//                     showModalBottomSheet(
//                       context: context,
//                       isScrollControlled: true,
//                       builder: (context) => UpdateRoomForm(room: _room!),
//                     ).then((_) => _fetchRoom());
//                   },
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.delete, color: AppColors.red500),
//                   onPressed: _deleteRoom,
//                 ),
//               ]
//             : null,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _room == null
//               ? const Center(child: Text('Failed to load room'))
//               : SingleChildScrollView(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Card(
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         elevation: 2,
//                         child: Padding(
//                           padding: const EdgeInsets.all(16),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               _infoRow('Room Number', _room!.roomNumber),
//                               _infoRow('Property', _room!.property.name),
//                               _infoRow('Status', _room!.status),
//                               _infoRow('Rent Amount', '${_room!.rentAmount} ${_room!.currency}'),
//                               _infoRow('Description', _room!.description),
//                               if (_room!.tenant != null)
//                                 _infoRow('Tenant',
//                                     '${_room!.tenant!.firstName} ${_room!.tenant!.lastName}'),
//                               if (_room!.lastRentDate != null)
//                                 _infoRow('Last Rent Date',
//                                     DateFormat('yyyy-MM-dd').format(_room!.lastRentDate!)),
//                               if (_room!.nextRentDue != null)
//                                 _infoRow('Next Rent Due',
//                                     DateFormat('yyyy-MM-dd').format(_room!.nextRentDue!)),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       const Text(
//                         'Amenities',
//                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 10),
//                       Wrap(
//                         spacing: 8,
//                         runSpacing: 8,
//                         children: _room!.amenities
//                             .map((amenity) => Chip(
//                                   label: Text(amenity),
//                                   backgroundColor: AppColors.grey100,
//                                 ))
//                             .toList(),
//                       ),
//                     ],
//                   ),
//                 ),
//     );
//   }

//   Widget _infoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Text(
//             '$label: ',
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(color: Colors.black87),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }