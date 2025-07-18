import 'package:Peeman/models/tenant.dart';
import 'package:Peeman/screens/dashboard/view_all_rent.dart';
import 'package:Peeman/screens/tenants/tenant_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/assets.dart';
import '../../constants/colors.dart';
import '../../providers/tenant_provider.dart';
import '../../widgets/custom_avatar.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/custom_card.dart';

class DueRentCard extends StatefulWidget {
  const DueRentCard({super.key});

  @override
  State<DueRentCard> createState() => _DueRentCardState();
}

class _DueRentCardState extends State<DueRentCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TenantProvider>(context, listen: false).loadTenants(context);
    });
  }
  @override
  Widget build(BuildContext context) {
    final tenantProvider = Provider.of<TenantProvider>(context);
    List<Tenant> tenants = tenantProvider.tenants
        .where((tenant) => tenant.status == 'overdue')
        .toList();


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Due Rent',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: ()  {
            Navigator.push(
                 context,
              MaterialPageRoute(
              builder: (context) => ViewAllRent(
              tenants: tenants
            ),
              ),
                );
    },
              child: Text(
                'View All',
                style: TextStyle(color: AppColors.primaryBlue),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: tenants.map((rent) {
              return GestureDetector(
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
                      width: 200,
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
            }).toList(),
          ),
        ),
      ],
    );
  }
  String shorten(String text, [int maxLength = 7]) {
    return text.length > maxLength ? '${text.substring(0, maxLength)}...' : text;
  }
}