import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/property_model.dart';
import '../../providers/property_provider.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;
  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
   // _fetchProperty();
  }
/*
  Future<void> _fetchProperty() async {
    try {
      final property = await Provider.of<PropertyProvider>(context, listen: false)
          .fetchPropertyById(context, widget.propertyId);
      setState(() {
        _property = property;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load property: $e')));
    }
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.property.name ?? 'Property Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : widget.property == null
          ? const Center(child: Text('Property not found'))
          : SingleChildScrollView(
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
            _infoRow('Status',widget.property.status),
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
      ),
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
