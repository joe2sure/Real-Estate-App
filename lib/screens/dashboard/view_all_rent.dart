import 'package:Peeman/models/tenant.dart';
import 'package:Peeman/screens/dashboard/due_rent_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/custom_card.dart';
import '../tenants/tenant_detail_screen.dart';

class ViewAllRent extends StatefulWidget {
  final List<Tenant> tenants;

  const ViewAllRent({super.key,  required this.tenants});

  @override
  State<ViewAllRent> createState() => _ViewAllRentState();
}

class _ViewAllRentState extends State<ViewAllRent> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: const Text('Overdue Rent'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        body: SingleChildScrollView(
                  child: Padding(
                          padding: const EdgeInsets.all(16),child: Column(children:
    widget.tenants.map((rent) {
                                      return _reusablecard(rent);
    },).toList(),)
        )
    ));
  }
  Widget _reusablecard (Tenant rent){
    return  GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TenantDetailScreen(
                tenantId: rent.id
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: CustomCard(
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue[50],
                      radius: 32,
                      child: Text("${rent.firstName[0]} ",style: TextStyle(fontSize: 36)),

                    ),

                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${rent.firstName} ${rent.lastName}" ,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "${rent.unit}, ${shorten(rent.property.address)} ",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${rent.rentAmount}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    CustomBadge(
                      text: rent.status,
                      backgroundColor: AppColors.amber100,
                      textColor: AppColors.amber500,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  String shorten(String text, [int maxLength = 20]) {
    return text.length > maxLength ? '${text.substring(0, maxLength)}...' : text;
  }
}
