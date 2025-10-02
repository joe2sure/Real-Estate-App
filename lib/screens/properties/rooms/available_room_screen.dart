import 'package:Peeman/providers/auth_provider.dart';
import 'package:Peeman/providers/room_provider.dart';
import 'package:Peeman/screens/properties/rooms/room_card.dart';
import 'package:Peeman/constants/colors.dart';
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
      Provider.of<RoomProvider>(context, listen: false)
          .fetchAvailableRooms(authProvider.token!);
    });
  }

  Future<void> _refreshRooms() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await Provider.of<RoomProvider>(context, listen: false)
        .fetchAvailableRooms(authProvider.token!);
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.secondaryTeal,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.secondaryTeal,
                      AppColors.secondaryTeal.withOpacity(0.8),
                      AppColors.primaryBlue.withOpacity(0.6),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.meeting_room,
                              size: 48,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Available Rooms',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Find your perfect space',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.white.withOpacity(0.9),
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
          // Content
          SliverToBoxAdapter(
            child: roomProvider.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(100),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : roomProvider.rooms.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppColors.grey100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.meeting_room_outlined,
                                  size: 64,
                                  color: AppColors.grey400,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'No Available Rooms',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.grey800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Check back later for new listings',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.grey500,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _refreshRooms,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Refresh'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondaryTeal,
                                  foregroundColor: AppColors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          const SizedBox(height: 20),
                          // Stats Card
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryBlue,
                                    AppColors.gradientBlue,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryBlue.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    icon: Icons.meeting_room,
                                    label: 'Total Available',
                                    value: '${roomProvider.rooms.length}',
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: AppColors.white.withOpacity(0.3),
                                  ),
                                  _buildStatItem(
                                    icon: Icons.location_city,
                                    label: 'Properties',
                                    value: '${_getUniqueProperties(roomProvider.rooms)}',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Rooms List Header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Available Rooms',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.grey800,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  color: AppColors.primaryBlue,
                                  onPressed: _refreshRooms,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Rooms List
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: RoomCard(rooms: roomProvider.rooms),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  int _getUniqueProperties(List rooms) {
    final propertyIds = rooms.map((room) => room.property.id).toSet();
    return propertyIds.length;
  }
}





// import 'package:Peeman/providers/auth_provider.dart';
// import 'package:Peeman/providers/room_provider.dart';
// import 'package:Peeman/screens/properties/rooms/room_card.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';


// class AvailableRoomsScreen extends StatefulWidget {
//   const AvailableRoomsScreen({super.key});

//   @override
//   State<AvailableRoomsScreen> createState() => _AvailableRoomsScreenState();
// }

// class _AvailableRoomsScreenState extends State<AvailableRoomsScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       Provider.of<RoomProvider>(context, listen: false).fetchAvailableRooms(authProvider.token!);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final roomProvider = Provider.of<RoomProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Available Rooms'),
//       ),
//       body: roomProvider.isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : roomProvider.rooms.isEmpty
//               ? const Center(child: Text('No available rooms found'))
//               : Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: RoomCard(rooms: roomProvider.rooms),
//                 ),
//     );
//   }
// }