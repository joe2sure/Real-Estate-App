import 'package:Peeman/constants/colors.dart';
import 'package:Peeman/models/room_model.dart';
import 'package:Peeman/providers/room_provider.dart';
import 'package:Peeman/widgets/custom_toaster.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class UpdateRoomForm extends StatefulWidget {
  final Room room;
  const UpdateRoomForm({super.key, required this.room});

  @override
  State<UpdateRoomForm> createState() => _UpdateRoomFormState();
}

class _UpdateRoomFormState extends State<UpdateRoomForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _roomNumberController = TextEditingController();
  final TextEditingController _rentAmountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amenityController = TextEditingController();
  String _currency = 'USD';
  List<String> _amenities = [];

  @override
  void initState() {
    super.initState();
    _roomNumberController.text = widget.room.roomNumber;
    _rentAmountController.text = widget.room.rentAmount.toString();
    _descriptionController.text = widget.room.description;
    _currency = widget.room.currency;
    _amenities = List.from(widget.room.amenities);
  }

  void _addAmenity(String amenity) {
    setState(() {
      if (amenity.isNotEmpty && !_amenities.contains(amenity)) {
        _amenities.add(amenity);
        _amenityController.clear();
      }
    });
  }

  void _removeAmenity(String amenity) {
    setState(() {
      _amenities.remove(amenity);
    });
  }

  @override
  void dispose() {
    _roomNumberController.dispose();
    _rentAmountController.dispose();
    _descriptionController.dispose();
    _amenityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);

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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Update Room',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _roomNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Room Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please enter room number' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _rentAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Rent Amount',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter rent amount';
                      final num = double.tryParse(value);
                      if (num == null || num <= 0) return 'Enter a valid amount';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _currency,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                    ),
                    items: ['USD', 'GBP', 'EUR']
                        .map((currency) => DropdownMenuItem(
                              value: currency,
                              child: Text(currency),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _currency = value!;
                      });
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
                    validator: (value) => value!.isEmpty ? 'Please enter description' : null,
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
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryBlue, AppColors.secondaryTeal],
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
                      onPressed: roomProvider.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                final roomData = {
                                  'roomNumber': _roomNumberController.text,
                                  'rentAmount': double.parse(_rentAmountController.text),
                                  'currency': _currency,
                                  'description': _descriptionController.text,
                                  'amenities': _amenities,
                                };
                                await roomProvider.updateRoom(context, widget.room.id, roomData);
                                if (roomProvider.errorMessage == null) {
                                  CustomToast.show(context, 'Room updated successfully');
                                  Navigator.pop(context);
                                } else {
                                  CustomToast.show(context, roomProvider.errorMessage!, isSuccess: false);
                                }
                              }
                            },
                      child: roomProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Update Room',
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