import 'package:flutter/material.dart';
import '../../models/property.dart';          // For the Property model
import '../../constants/colors.dart';        // For your AppColors
import '../../constants/assets.dart';        // For default property images (Assets.property1, etc.)

class AddPropertyForm extends StatefulWidget {
  final Function(Property) onPropertyAdded;

  const AddPropertyForm({super.key, required this.onPropertyAdded});

  @override
  State<AddPropertyForm> createState() => _AddPropertyFormState();
}

class _AddPropertyFormState extends State<AddPropertyForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _unitsOccupiedController = TextEditingController();
  final TextEditingController _totalUnitsController = TextEditingController();
  final TextEditingController _monthlyIncomeController = TextEditingController();
  String _status = 'Active';

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _unitsOccupiedController.dispose();
    _totalUnitsController.dispose();
    _monthlyIncomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
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
              DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: ['Active', 'Maintenance']
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
                  return null;
                  }),
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
                  return null;
                  }),
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
                return null;
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
                onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final newProperty = Property(
                  name: _nameController.text,
                  address: _addressController.text,
                  image: Assets.property1, // Default image
                  status: _status,
                  unitsOccupied: int.parse(_unitsOccupiedController.text),
                  totalUnits: int.parse(_totalUnitsController.text),
                  occupancy: (int.parse(_unitsOccupiedController.text) /
                    int.parse(_totalUnitsController.text) *
                    100),
                  monthlyIncome: double.parse(_monthlyIncomeController.text),
                  );
                  widget.onPropertyAdded(newProperty);
                }
                },
                child: const Text(
                'Add Property',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                ),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}