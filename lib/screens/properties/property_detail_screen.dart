import 'package:Peeman/screens/properties/rooms/room_card.dart';
import 'package:Peeman/screens/properties/rooms/add_room_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/property_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/room_provider.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;
  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _roomsLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && !_roomsLoaded && !_isLoading) {
        _fetchRooms();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchRooms() async {
    if (_isLoading) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<RoomProvider>(context, listen: false)
          .fetchRoomsByProperty(authProvider.token!, widget.property.id);

      final roomProvider = Provider.of<RoomProvider>(context, listen: false);
      debugPrint(
          'PropertyDetailScreen: Fetched ${roomProvider.rooms.length} rooms for property ${widget.property.id}');

      setState(() {
        _isLoading = false;
        _roomsLoaded = true;
      });
    } catch (e) {
      debugPrint('PropertyDetailScreen: Error fetching rooms: $e');
      setState(() {
        _isLoading = false;
        _roomsLoaded = false;
      });
    }
  }

  void _showAddRoomForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddRoomForm(),
    ).then((_) {
      if (_tabController.index == 1) {
        setState(() {
          _roomsLoaded = false;
        });
        _fetchRooms();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.currentUser?.role == 'admin';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.property.images.isNotEmpty)
                    PageView.builder(
                      itemCount: widget.property.images.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          widget.property.images[index],
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  else
                    Container(
                      color: AppColors.grey300,
                      child: const Icon(Icons.image_not_supported, size: 80, color: AppColors.grey500),
                    ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Property Name Overlay
                  Positioned(
                    bottom: 60,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.property.status == 'active'
                                ? AppColors.green500
                                : AppColors.amber500,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.property.status.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.property.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black38,
                                offset: Offset(0, 2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: AppColors.white, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.property.address,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.white.withOpacity(0.9),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primaryBlue,
                unselectedLabelColor: AppColors.grey500,
                indicatorColor: AppColors.primaryBlue,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(text: 'Details'),
                  Tab(text: 'Rooms'),
                ],
              ),
            ),
          ),
          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(),
                _buildRoomsTab(roomProvider),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin && _tabController.index == 1
          ? FloatingActionButton.extended(
              heroTag: 'add_room_fab',
              backgroundColor: AppColors.primaryBlue,
              onPressed: _showAddRoomForm,
              icon: const Icon(Icons.add),
              label: const Text('Add Room'),
            )
          : null,
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.meeting_room,
                  label: 'Total Units',
                  value: '${widget.property.totalUnits}',
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle,
                  label: 'Occupied',
                  value: '${widget.property.unitsOccupied}',
                  color: AppColors.green500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people,
                  label: 'Occupancy',
                  value: '${widget.property.occupancy.toStringAsFixed(1)}%',
                  color: AppColors.secondaryTeal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.attach_money,
                  label: 'Monthly Income',
                  value: '\${widget.property.monthlyIncome.toStringAsFixed(0)}',
                  color: AppColors.purple600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Description Card
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
                        Icons.description,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.property.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey600,
                    height: 1.6,
                  ),
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.property.amenities.map((amenity) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryBlue.withOpacity(0.1),
                            AppColors.gradientBlue.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primaryBlue.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        amenity,
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
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
        ],
      ),
    );
  }

  Widget _buildRoomsTab(RoomProvider roomProvider) {
    if (!_roomsLoaded && !_isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchRooms();
      });
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (roomProvider.state == RoomState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.grey400),
            const SizedBox(height: 16),
            Text(
              roomProvider.errorMessage ?? 'Failed to load rooms',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey600, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _roomsLoaded = false;
                });
                _fetchRooms();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (roomProvider.rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.meeting_room_outlined, size: 64, color: AppColors.grey400),
            const SizedBox(height: 16),
            Text(
              'No rooms found for this property',
              style: TextStyle(color: AppColors.grey600, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _roomsLoaded = false;
                });
                _fetchRooms();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${roomProvider.rooms.length} Room${roomProvider.rooms.length != 1 ? 's' : ''}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.grey800,
            ),
          ),
          const SizedBox(height: 16),
          RoomCard(rooms: roomProvider.rooms),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.grey500,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.grey800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}






// import 'package:Peeman/screens/properties/rooms/room_card.dart';
// import 'package:Peeman/screens/properties/rooms/add_room_form.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../constants/colors.dart';
// import '../../models/property_model.dart';
// import '../../providers/auth_provider.dart';
// // import '../../providers/property_provider.dart';
// import '../../providers/room_provider.dart';

// class PropertyDetailScreen extends StatefulWidget {
//   final Property property;
//   const PropertyDetailScreen({super.key, required this.property});

//   @override
//   State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
// }

// class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
//   String _activeTab = 'Details';
//   bool _isLoading = false;
//   bool _roomsLoaded = false;

//   @override
//   void initState() {
//     super.initState();
//   }

//   Future<void> _fetchRooms() async {
//     if (_isLoading) return; // Prevent multiple simultaneous fetches

//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await Provider.of<RoomProvider>(context, listen: false)
//           .fetchRoomsByProperty(authProvider.token!, widget.property.id);

//       // Verify that rooms were actually loaded
//       final roomProvider = Provider.of<RoomProvider>(context, listen: false);
//       debugPrint(
//           'PropertyDetailScreen: Fetched ${roomProvider.rooms.length} rooms for property ${widget.property.id}');

//       setState(() {
//         _isLoading = false;
//         _roomsLoaded = true;
//       });
//     } catch (e) {
//       debugPrint('PropertyDetailScreen: Error fetching rooms: $e');
//       setState(() {
//         _isLoading = false;
//         _roomsLoaded = false; // Mark as not loaded on error so user can retry
//       });
//     }
//   }

//   void _showAddRoomForm() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) => const AddRoomForm(),
//     ).then((_) {
//       // Refresh rooms after adding a new one
//       if (_activeTab == 'Rooms') {
//         setState(() {
//           _roomsLoaded = false;
//         });
//         _fetchRooms();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final roomProvider = Provider.of<RoomProvider>(context);
//     final authProvider = Provider.of<AuthProvider>(context);
//     final isAdmin = authProvider.currentUser?.role == 'admin';

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         foregroundColor: Colors.white,
//         title: Text(widget.property.name),
//       ),
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 color: AppColors.grey100,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildTab('Details'),
//                     _buildTab('Rooms'),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: _activeTab == 'Details'
//                     ? _buildDetailsTab()
//                     : _buildRoomsTab(roomProvider),
//               ),
//             ],
//           ),
//           // Show FAB only when in Rooms tab and user is admin
//           if (isAdmin && _activeTab == 'Rooms')
//             Positioned(
//               bottom: 16,
//               right: 16,
//               child: FloatingActionButton(
//                 heroTag: 'add_room_fab',
//                 backgroundColor: AppColors.primaryBlue,
//                 onPressed: _showAddRoomForm,
//                 child: const Icon(Icons.add),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTab(String tab) {
//     final isActive = _activeTab == tab;
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _activeTab = tab;
//         });
//         // Fetch rooms when switching to Rooms tab if not already loaded
//         if (tab == 'Rooms' && !_roomsLoaded && !_isLoading) {
//           _fetchRooms();
//         }
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
//         decoration: BoxDecoration(
//           color: isActive ? AppColors.primaryBlue : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Text(
//           tab,
//           style: TextStyle(
//             color: isActive ? Colors.white : AppColors.grey600,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailsTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (widget.property.images.isNotEmpty)
//             SizedBox(
//               height: 200,
//               child: PageView.builder(
//                 itemCount: widget.property.images.length,
//                 itemBuilder: (context, index) {
//                   return Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 5),
//                     decoration: BoxDecoration(
//                       image: DecorationImage(
//                         image: NetworkImage(widget.property.images[index]),
//                         fit: BoxFit.cover,
//                       ),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   );
//                 },
//               ),
//             )
//           else
//             Container(
//               height: 200,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Center(
//                 child: Icon(Icons.image_not_supported, size: 50),
//               ),
//             ),
//           const SizedBox(height: 20),
//           Text(
//             widget.property.name,
//             style: const TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(widget.property.address,
//               style: const TextStyle(color: Colors.black87)),
//           const SizedBox(height: 12),
//           Text(
//             widget.property.description,
//             style: const TextStyle(color: Colors.black54),
//           ),
//           const Divider(height: 30, color: Colors.black),
//           _infoRow('Status', widget.property.status),
//           _infoRow('Units Occupied',
//               '${widget.property.unitsOccupied}/${widget.property.totalUnits}'),
//           _infoRow(
//               'Occupancy', '${widget.property.occupancy.toStringAsFixed(1)}%'),
//           _infoRow('Monthly Income',
//               '\$${widget.property.monthlyIncome.toStringAsFixed(2)}'),
//           const SizedBox(height: 20),
//           const Text(
//             'Amenities',
//             style: TextStyle(
//                 fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
//           ),
//           const SizedBox(height: 10),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: widget.property.amenities.map((amenity) {
//               return Chip(
//                 label:
//                     Text(amenity, style: const TextStyle(color: Colors.black)),
//                 backgroundColor: Colors.grey[200],
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRoomsTab(RoomProvider roomProvider) {
//     // Trigger fetch only once when tab is first viewed
//     if (!_roomsLoaded && !_isLoading) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _fetchRooms();
//       });
//     }

//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     // Check if there was an error
//     if (roomProvider.state == RoomState.error) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               roomProvider.errorMessage ?? 'Failed to load rooms',
//               textAlign: TextAlign.center,
//               style: const TextStyle(color: Colors.red),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _roomsLoaded = false;
//                 });
//                 _fetchRooms();
//               },
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     if (roomProvider.rooms.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text('No rooms found for this property'),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _roomsLoaded = false;
//                 });
//                 _fetchRooms();
//               },
//               child: const Text('Refresh'),
//             ),
//           ],
//         ),
//       );
//     }


//   return SingleChildScrollView(
//     padding: const EdgeInsets.all(16),
//     child: RoomCard(rooms: roomProvider.rooms),
//   );
//   }

//   Widget _infoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         children: [
//           Text(
//             '$label: ',
//             style: const TextStyle(
//                 fontWeight: FontWeight.bold, color: Colors.black),
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