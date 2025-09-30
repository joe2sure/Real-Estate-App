import 'package:Peeman/screens/properties/add_property.dart';
import 'package:Peeman/screens/properties/rooms/add_room_form.dart';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
// import 'add_property.dart';
// import 'add_room_form.dart';

class FloatingActionButtonWidget extends StatefulWidget {
  const FloatingActionButtonWidget({super.key});

  @override
  State<FloatingActionButtonWidget> createState() => _FloatingActionButtonWidgetState();
}

class _FloatingActionButtonWidgetState extends State<FloatingActionButtonWidget> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _showAddPropertyForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddPropertyForm(),
    );
  }

  void _showAddRoomForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddRoomForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isExpanded) ...[
          FloatingActionButton(
            heroTag: 'add_room',
            backgroundColor: AppColors.primaryBlue,
            onPressed: () => _showAddRoomForm(context),
            child: const Icon(Icons.meeting_room),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'add_property',
            backgroundColor: AppColors.primaryBlue,
            onPressed: () => _showAddPropertyForm(context),
            child: const Icon(Icons.add_home),
          ),
          const SizedBox(height: 10),
        ],
        FloatingActionButton(
          heroTag: 'main_fab',
          backgroundColor: AppColors.primaryBlue,
          onPressed: _toggleExpanded,
          child: Icon(_isExpanded ? Icons.close : Icons.add),
        ),
      ],
    );
  }
}




// import 'package:flutter/material.dart';

// import '../constants/colors.dart';

// class FloatingActionButtonWidget extends StatelessWidget {
//   final VoidCallback onPressed;

//   const FloatingActionButtonWidget({
//     super.key,
//     required this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black26,
//             blurRadius: 8,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: FloatingActionButton(
//         onPressed: onPressed,
//         backgroundColor: Colors.transparent,
//         elevation: 6,
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [AppColors.primaryBlue, AppColors.secondaryTeal],
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//             ),
//             shape: BoxShape.circle,
//           ),
//           child: const Center(
//             child: Icon(Icons.add, color: AppColors.white, size: 24),
//           ),
//         ),
//       ),
//     );
//   }
// }