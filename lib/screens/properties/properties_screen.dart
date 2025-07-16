import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/property_model.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../widgets/fab.dart';
import 'property_card.dart';
import 'add_property.dart';

class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({super.key});

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('PropertiesScreen: Initializing fetchProperties');
      Provider.of<PropertyProvider>(context, listen: false).fetchProperties(context: context);
    });
  }

  void _showAddPropertyForm() {
    debugPrint('PropertiesScreen: Showing AddPropertyForm');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => const AddPropertyForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final isAdmin = authProvider.currentUser?.role == 'admin';

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                color: AppColors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Properties',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Search properties...',
                              prefixIcon: const Icon(Icons.search, color: AppColors.grey400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: AppColors.grey100,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.filter_list, color: AppColors.grey600),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.sort, color: AppColors.grey600),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child:  propertyProvider.errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(propertyProvider.errorMessage!),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    Provider.of<PropertyProvider>(context, listen: false)
                                        .fetchProperties(context: context);
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            child:Skeletonizer (
                              enabled: propertyProvider.isLoading,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: PropertyCard(properties: propertyProvider.properties),
                              ),
                            ),
                          ),
              ),
            ],
          ),
          if (isAdmin)
            Positioned(
              bottom: 80,
              right: 16,
              child: FloatingActionButtonWidget(
                onPressed: _showAddPropertyForm,
              ),
            ),
        ],
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../constants/colors.dart';
// import '../../models/property_model.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/property_provider.dart';
// import '../../widgets/fab.dart';
// import 'property_card.dart';
// import 'add_property.dart';

// class PropertiesScreen extends StatefulWidget {
//   const PropertiesScreen({super.key});

//   @override
//   State<PropertiesScreen> createState() => _PropertiesScreenState();
// }

// class _PropertiesScreenState extends State<PropertiesScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<PropertyProvider>(context, listen: false).fetchProperties();
//     });
//   }

//   void _showAddPropertyForm() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       isDismissible: true,
//       enableDrag: true,
//       builder: (context) => const AddPropertyForm(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);
//     final propertyProvider = Provider.of<PropertyProvider>(context);
//     final isAdmin = authProvider.currentUser?.role == 'admin';

//     return Scaffold(
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
//                 color: AppColors.white,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Properties',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: TextFormField(
//                             decoration: InputDecoration(
//                               hintText: 'Search properties...',
//                               prefixIcon: const Icon(Icons.search, color: AppColors.grey400),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 borderSide: BorderSide.none,
//                               ),
//                               filled: true,
//                               fillColor: AppColors.grey100,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         IconButton(
//                           icon: const Icon(Icons.filter_list, color: AppColors.grey600),
//                           onPressed: () {},
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.sort, color: AppColors.grey600),
//                           onPressed: () {},
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: propertyProvider.isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : propertyProvider.errorMessage != null
//                         ? Center(child: Text(propertyProvider.errorMessage!))
//                         : SingleChildScrollView(
//                             child: Padding(
//                               padding: const EdgeInsets.all(16),
//                               child: PropertyCard(properties: propertyProvider.properties),
//                             ),
//                           ),
//               ),
//             ],
//           ),
//           if (isAdmin)
//             Positioned(
//               bottom: 80,
//               right: 16,
//               child: FloatingActionButtonWidget(
//                 onPressed: _showAddPropertyForm,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }