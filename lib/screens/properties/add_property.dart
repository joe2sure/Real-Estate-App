import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/property_model.dart';
import '../../providers/property_provider.dart';
import 'dart:io';

class AddPropertyForm extends StatefulWidget {
  const AddPropertyForm({super.key});

  @override
  State<AddPropertyForm> createState() => _AddPropertyFormState();
}

class _AddPropertyFormState extends State<AddPropertyForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _unitsOccupiedController =
      TextEditingController();
  final TextEditingController _totalUnitsController = TextEditingController();
  final TextEditingController _monthlyIncomeController =
      TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _amenityController = TextEditingController();
  String _status = 'active';
  List<String> _amenities = [];
  List<String> _imageUrls = [];
  List<String> _imagePaths = [];
  bool _useLocalImages = false;

  void _addAmenity(String amenity) {
    setState(() {
      if (amenity.isNotEmpty && !_amenities.contains(amenity)) {
        _amenities.add(amenity);
        _amenityController.clear();
      }
    });
    debugPrint('AddPropertyForm: Added amenity: $amenity');
  }

  void _removeAmenity(String amenity) {
    setState(() {
      _amenities.remove(amenity);
    });
    debugPrint('AddPropertyForm: Removed amenity: $amenity');
  }

  // Future<void> _pickImages() async {
  //   final picker = ImagePicker();
  //   final pickedFiles = await picker.pickMultiImage();
  //   setState(() {
  //     _imagePaths = pickedFiles.map((file) => file.path).toList();
  //     _imageUrls.clear();
  //   });
  //   debugPrint('AddPropertyForm: Picked images: $_imagePaths');
  // }

  Future<void> _pickImages() async {
    final cameraStatus = await Permission.camera.request();
    final storageStatus = await Permission.storage.request();

    if (cameraStatus.isGranted && storageStatus.isGranted) {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage();
      setState(() {
        _imagePaths = pickedFiles.map((file) => file.path).toList();
        _imageUrls.clear();
      });
      debugPrint('AddPropertyForm: Picked images: $_imagePaths');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Camera and storage permissions are required.')),
      );
    }
  }

  void _addImageUrl(String url) {
    setState(() {
      if (url.isNotEmpty && !_imageUrls.contains(url)) {
        _imageUrls.add(url);
        _imageUrlController.clear();
      }
      _imagePaths.clear();
    });
    debugPrint('AddPropertyForm: Added image URL: $url');
  }

  void _removeImageUrl(String url) {
    setState(() {
      _imageUrls.remove(url);
    });
    debugPrint('AddPropertyForm: Removed image URL: $url');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _unitsOccupiedController.dispose();
    _totalUnitsController.dispose();
    _monthlyIncomeController.dispose();
    _imageUrlController.dispose();
    _amenityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = Provider.of<PropertyProvider>(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Add New Property',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Property Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter property name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: ['active', 'maintenance']
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _status = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _unitsOccupiedController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Units Occupied',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter number';
                            }
                            final num = int.tryParse(value);
                            if (num == null || num < 0) {
                              return 'Enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _totalUnitsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Total Units',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter number';
                            }
                            final num = int.tryParse(value);
                            if (num == null || num < 1) {
                              return 'Enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _monthlyIncomeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Monthly Income (\$)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      final num = double.tryParse(value);
                      if (num == null || num < 0) {
                        return 'Enter a valid amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Amenities',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey600,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: _amenities
                        .map((amenity) => Chip(
                              label: Text(amenity),
                              onDeleted: () => _removeAmenity(amenity),
                            ))
                        .toList(),
                  ),
                  TextFormField(
                    controller: _amenityController,
                    decoration: const InputDecoration(
                      labelText: 'Add Amenity',
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (value) {
                      _addAmenity(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Images',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey600,
                    ),
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _useLocalImages,
                        onChanged: (value) {
                          setState(() {
                            _useLocalImages = value!;
                            if (_useLocalImages) {
                              _imageUrls.clear();
                            } else {
                              _imagePaths.clear();
                            }
                          });
                        },
                      ),
                      const Text('Use local images'),
                    ],
                  ),
                  if (_useLocalImages) ...[
                    ElevatedButton(
                      onPressed: _pickImages,
                      child: const Text('Pick Images'),
                    ),
                    Wrap(
                      spacing: 8,
                      children: _imagePaths
                          .map((path) => Chip(
                                label: Text(path.split('/').last),
                                onDeleted: () {
                                  setState(() {
                                    _imagePaths.remove(path);
                                  });
                                },
                              ))
                          .toList(),
                    ),
                  ] else ...[
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL',
                        border: OutlineInputBorder(),
                      ),
                      onFieldSubmitted: (value) {
                        _addImageUrl(value);
                      },
                    ),
                    Wrap(
                      spacing: 8,
                      children: _imageUrls
                          .map((url) => Chip(
                                label: Text(url.split('/').last),
                                onDeleted: () => _removeImageUrl(url),
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryBlue,
                          AppColors.secondaryTeal
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: propertyProvider.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                final totalUnits =
                                    int.parse(_totalUnitsController.text);
                                final occupiedUnits =
                                    int.parse(_unitsOccupiedController.text);
                                if (occupiedUnits > totalUnits) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Occupied units cannot exceed total units')),
                                  );
                                  return;
                                }
                                debugPrint(
                                    'AddPropertyForm: Submitting property: ${_nameController.text}');
                                await propertyProvider.createProperty(
                                  context: context,
                                  name: _nameController.text,
                                  address: _addressController.text,
                                  description: _descriptionController.text,
                                  totalUnits: totalUnits,
                                  occupiedUnits: occupiedUnits,
                                  monthlyIncome: double.parse(
                                      _monthlyIncomeController.text),
                                  status: _status,
                                  amenities: _amenities,
                                  imageUrls:
                                      _useLocalImages ? null : _imageUrls,
                                  imagePaths:
                                      _useLocalImages ? _imagePaths : null,
                                );
                                if (propertyProvider.errorMessage == null) {
                                  debugPrint(
                                      'AddPropertyForm: Property added successfully');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Property added successfully')),
                                  );
                                  Navigator.pop(context);
                                } else {
                                  debugPrint(
                                      'AddPropertyForm: Error: ${propertyProvider.errorMessage}');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            propertyProvider.errorMessage!)),
                                  );
                                }
                              }
                            },
                      child: propertyProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Add Property',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import '../../constants/colors.dart';
// import '../../models/property_model.dart';
// import '../../providers/property_provider.dart';
// import 'dart:io';

// class AddPropertyForm extends StatefulWidget {
//   const AddPropertyForm({super.key});

//   @override
//   State<AddPropertyForm> createState() => _AddPropertyFormState();
// }

// class _AddPropertyFormState extends State<AddPropertyForm> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _unitsOccupiedController = TextEditingController();
//   final TextEditingController _totalUnitsController = TextEditingController();
//   final TextEditingController _monthlyIncomeController = TextEditingController();
//   final TextEditingController _imageUrlController = TextEditingController();
//   final TextEditingController _amenityController = TextEditingController();
//   String _status = 'active';
//   List<String> _amenities = [];
//   List<String> _imageUrls = [];
//   List<String> _imagePaths = [];
//   bool _useLocalImages = false;

//   void _addAmenity(String amenity) {
//     setState(() {
//       if (amenity.isNotEmpty && !_amenities.contains(amenity)) {
//         _amenities.add(amenity);
//         _amenityController.clear();
//       }
//     });
//   }

//   void _removeAmenity(String amenity) {
//     setState(() {
//       _amenities.remove(amenity);
//     });
//   }

//   Future<void> _pickImages() async {
//     final picker = ImagePicker();
//     final pickedFiles = await picker.pickMultiImage();
//     setState(() {
//       _imagePaths = pickedFiles.map((file) => file.path).toList();
//       _imageUrls.clear();
//     });
//     debugPrint('AddPropertyForm: Picked images: $_imagePaths');
//   }

//   void _addImageUrl(String url) {
//     setState(() {
//       if (url.isNotEmpty && !_imageUrls.contains(url)) {
//         _imageUrls.add(url);
//         _imageUrlController.clear();
//       }
//       _imagePaths.clear();
//     });
//     debugPrint('AddPropertyForm: Added image URL: $url');
//   }

//   void _removeImageUrl(String url) {
//     setState(() {
//       _imageUrls.remove(url);
//     });
//     debugPrint('AddPropertyForm: Removed image URL: $url');
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _addressController.dispose();
//     _descriptionController.dispose();
//     _unitsOccupiedController.dispose();
//     _totalUnitsController.dispose();
//     _monthlyIncomeController.dispose();
//     _imageUrlController.dispose();
//     _amenityController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final propertyProvider = Provider.of<PropertyProvider>(context);

//     return DraggableScrollableSheet(
//       initialChildSize: 0.9,
//       minChildSize: 0.5,
//       maxChildSize: 1.0,
//       builder: (context, scrollController) {
//         return Container(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom + 16,
//             left: 16,
//             right: 16,
//             top: 16,
//           ),
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//           ),
//           child: SingleChildScrollView(
//             controller: scrollController,
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   const Text(
//                     'Add New Property',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _nameController,
//                     decoration: const InputDecoration(
//                       labelText: 'Property Name',
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter property name';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: _addressController,
//                     decoration: const InputDecoration(
//                       labelText: 'Address',
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter address';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: _descriptionController,
//                     decoration: const InputDecoration(
//                       labelText: 'Description',
//                       border: OutlineInputBorder(),
//                     ),
//                     maxLines: 3,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter description';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   DropdownButtonFormField<String>(
//                     value: _status,
//                     decoration: const InputDecoration(
//                       labelText: 'Status',
//                       border: OutlineInputBorder(),
//                     ),
//                     items: ['active', 'maintenance']
//                         .map((status) => DropdownMenuItem(
//                               value: status,
//                               child: Text(status),
//                             ))
//                         .toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         _status = value!;
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextFormField(
//                           controller: _unitsOccupiedController,
//                           keyboardType: TextInputType.number,
//                           decoration: const InputDecoration(
//                             labelText: 'Units Occupied',
//                             border: OutlineInputBorder(),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Enter number';
//                             }
//                             final num = int.tryParse(value);
//                             if (num == null || num < 0) {
//                               return 'Enter a valid number';
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: TextFormField(
//                           controller: _totalUnitsController,
//                           keyboardType: TextInputType.number,
//                           decoration: const InputDecoration(
//                             labelText: 'Total Units',
//                             border: OutlineInputBorder(),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Enter number';
//                             }
//                             final num = int.tryParse(value);
//                             if (num == null || num < 1) {
//                               return 'Enter a valid number';
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: _monthlyIncomeController,
//                     keyboardType: TextInputType.number,
//                     decoration: const InputDecoration(
//                       labelText: 'Monthly Income (\$)',
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter amount';
//                       }
//                       final num = double.tryParse(value);
//                       if (num == null || num < 0) {
//                         return 'Enter a valid amount';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     'Amenities',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.grey600,
//                     ),
//                   ),
//                   Wrap(
//                     spacing: 8,
//                     children: _amenities
//                         .map((amenity) => Chip(
//                               label: Text(amenity),
//                               onDeleted: () => _removeAmenity(amenity),
//                             ))
//                         .toList(),
//                   ),
//                   TextFormField(
//                     controller: _amenityController,
//                     decoration: const InputDecoration(
//                       labelText: 'Add Amenity',
//                       border: OutlineInputBorder(),
//                     ),
//                     onFieldSubmitted: (value) {
//                       _addAmenity(value);
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     'Images',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.grey600,
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       Checkbox(
//                         value: _useLocalImages,
//                         onChanged: (value) {
//                           setState(() {
//                             _useLocalImages = value!;
//                             if (_useLocalImages) {
//                               _imageUrls.clear();
//                             } else {
//                               _imagePaths.clear();
//                             }
//                           });
//                         },
//                       ),
//                       const Text('Use local images'),
//                     ],
//                   ),
//                   if (_useLocalImages) ...[
//                     ElevatedButton(
//                       onPressed: _pickImages,
//                       child: const Text('Pick Images'),
//                     ),
//                     Wrap(
//                       spacing: 8,
//                       children: _imagePaths
//                           .map((path) => Chip(
//                                 label: Text(path.split('/').last),
//                                 onDeleted: () {
//                                   setState(() {
//                                     _imagePaths.remove(path);
//                                   });
//                                 },
//                               ))
//                           .toList(),
//                     ),
//                   ] else ...[
//                     TextFormField(
//                       controller: _imageUrlController,
//                       decoration: const InputDecoration(
//                         labelText: 'Image URL',
//                         border: OutlineInputBorder(),
//                       ),
//                       onFieldSubmitted: (value) {
//                         _addImageUrl(value);
//                       },
//                     ),
//                     Wrap(
//                       spacing: 8,
//                       children: _imageUrls
//                           .map((url) => Chip(
//                                 label: Text(url.split('/').last),
//                                 onDeleted: () => _removeImageUrl(url),
//                               ))
//                           .toList(),
//                     ),
//                   ],
//                   const SizedBox(height: 20),
//                   Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [AppColors.primaryBlue, AppColors.secondaryTeal],
//                       ),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.transparent,
//                         shadowColor: Colors.transparent,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       onPressed: propertyProvider.isLoading
//                           ? null
//                           : () async {
//                               if (_formKey.currentState!.validate()) {
//                                 final totalUnits = int.parse(_totalUnitsController.text);
//                                 final occupiedUnits = int.parse(_unitsOccupiedController.text);
//                                 if (occupiedUnits > totalUnits) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(content: Text('Occupied units cannot exceed total units')),
//                                   );
//                                   return;
//                                 }
//                                 debugPrint('AddPropertyForm: Submitting property: ${_nameController.text}');
//                                 await propertyProvider.createProperty(
//                                   context: context,
//                                   name: _nameController.text,
//                                   address: _addressController.text,
//                                   description: _descriptionController.text,
//                                   totalUnits: totalUnits,
//                                   occupiedUnits: occupiedUnits,
//                                   monthlyIncome: double.parse(_monthlyIncomeController.text),
//                                   status: _status,
//                                   amenities: _amenities,
//                                   imageUrls: _useLocalImages ? null : _imageUrls,
//                                   imagePaths: _useLocalImages ? _imagePaths : null,
//                                 );
//                                 if (propertyProvider.errorMessage == null) {
//                                   debugPrint('AddPropertyForm: Property added successfully');
//                                   Navigator.pop(context);
//                                 } else {
//                                   debugPrint('AddPropertyForm: Error: ${propertyProvider.errorMessage}');
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(content: Text(propertyProvider.errorMessage!)),
//                                   );
//                                 }
//                               }
//                             },
//                       child: propertyProvider.isLoading
//                           ? const CircularProgressIndicator(color: Colors.white)
//                           : const Text(
//                               'Add Property',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }