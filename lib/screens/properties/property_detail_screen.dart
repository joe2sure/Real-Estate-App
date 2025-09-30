import 'package:Peeman/screens/properties/rooms/room_card.dart';
import 'package:Peeman/screens/properties/rooms/add_room_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/property_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../providers/room_provider.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;
  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  String _activeTab = 'Details';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (_activeTab == 'Rooms') {
      _fetchRooms();
    }
  }

  Future<void> _fetchRooms() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<RoomProvider>(context, listen: false)
        .fetchRoomsByProperty(context, widget.property.id);
    setState(() {
      _isLoading = false;
    });
  }

  void _showAddRoomForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddRoomForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.currentUser?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.property.name),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: AppColors.grey100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTab('Details'),
                    _buildTab('Rooms'),
                  ],
                ),
              ),
              Expanded(
                child: _activeTab == 'Details'
                    ? _buildDetailsTab()
                    : _buildRoomsTab(roomProvider),
              ),
            ],
          ),
          // Show FAB only when in Rooms tab and user is admin
          if (isAdmin && _activeTab == 'Rooms')
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'add_room_fab',
                backgroundColor: AppColors.primaryBlue,
                onPressed: _showAddRoomForm,
                child: const Icon(Icons.add),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTab(String tab) {
    final isActive = _activeTab == tab;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = tab;
          if (tab == 'Rooms') {
            _fetchRooms();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          tab,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.grey600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            child: PageView.builder(
              itemCount: widget.property.images.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.property.images[index]),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.property.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(widget.property.address, style: const TextStyle(color: Colors.black87)),
          const SizedBox(height: 12),
          Text(
            widget.property.description,
            style: const TextStyle(color: Colors.black54),
          ),
          const Divider(height: 30, color: Colors.black),
          _infoRow('Status', widget.property.status),
          _infoRow('Units Occupied', '${widget.property.unitsOccupied}/${widget.property.totalUnits}'),
          _infoRow('Occupancy', '${widget.property.occupancy.toStringAsFixed(1)}%'),
          _infoRow('Monthly Income', '\$${widget.property.monthlyIncome.toStringAsFixed(2)}'),
          const SizedBox(height: 20),
          const Text(
            'Amenities',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.property.amenities.map((amenity) {
              return Chip(
                label: Text(amenity, style: const TextStyle(color: Colors.black)),
                backgroundColor: Colors.grey[200],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomsTab(RoomProvider roomProvider) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : roomProvider.rooms.isEmpty
            ? const Center(child: Text('No rooms found for this property'))
            : Padding(
                padding: const EdgeInsets.all(16),
                child: RoomCard(rooms: roomProvider.rooms),
              );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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



// import 'package:flutter/material.dart';
// import '../../models/property_model.dart';

// class PropertyDetailScreen extends StatefulWidget {
//   final Property property;
//   const PropertyDetailScreen({super.key, required this.property});

//   @override
//   State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
// }

// class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//    // _fetchProperty();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         foregroundColor: Colors.white,
//         title: Text(widget.property.name ?? 'Property Details'),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : widget.property == null
//           ? const Center(child: Text('Property not found'))
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
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
//             ),
//             const SizedBox(height: 20),
//             Text(
//               widget.property.name,
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(widget.property.address, style: const TextStyle(color: Colors.black87)),
//             const SizedBox(height: 12),
//             Text(
//               widget.property.description,
//               style: const TextStyle(color: Colors.black54),
//             ),
//             const Divider(height: 30, color: Colors.black),
//             _infoRow('Status',widget.property.status),
//             _infoRow('Units Occupied', '${widget.property.unitsOccupied}/${widget.property.totalUnits}'),
//             _infoRow('Occupancy', '${widget.property.occupancy.toStringAsFixed(1)}%'),
//             _infoRow('Monthly Income', '\$${widget.property.monthlyIncome.toStringAsFixed(2)}'),
//             const SizedBox(height: 20),
//             const Text(
//               'Amenities',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
//             ),
//             const SizedBox(height: 10),
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: widget.property.amenities.map((amenity) {
//                 return Chip(
//                   label: Text(amenity, style: const TextStyle(color: Colors.black)),
//                   backgroundColor: Colors.grey[200],
//                 );
//               }).toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _infoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         children: [
//           Text(
//             '$label: ',
//             style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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