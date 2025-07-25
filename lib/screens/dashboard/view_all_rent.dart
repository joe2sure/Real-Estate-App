import 'package:Peeman/models/due_rent_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/due_rent_provider.dart';
import '../../widgets/custom_avatar.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/custom_card.dart';
import '../../constants/colors.dart';
import '../tenants/tenant_detail_screen.dart';

class ViewAllDueRentScreen extends StatefulWidget {
  final List<DueRentModel> duerents;

  const ViewAllDueRentScreen({super.key,required this.duerents});

  @override
  State<ViewAllDueRentScreen> createState() => _ViewAllDueRentScreenState();
}

class _ViewAllDueRentScreenState extends State<ViewAllDueRentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {

    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Due Rent'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.duerents.length,
        itemBuilder: (context, index) {
          final tenant = widget.duerents[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TenantDetailScreen(tenantId: tenant.id),
                  ),
                );
              },
              child: CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CustomAvatar(
                        imageUrl:
                        '${tenant.firstName[0]}${tenant.lastName[0]}',
                        size: 48,
                        fallbackText:
                        '${tenant.firstName[0]}${tenant.lastName[0]}',
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${tenant.firstName} ${tenant.lastName}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                CustomBadge(
                                  text: tenant.status,
                                  backgroundColor:
                                  tenant.status == 'paid'
                                      ? AppColors.green100
                                      : tenant.status ==
                                      'overdue'
                                      ? AppColors.red100
                                      : AppColors.amber100,
                                  textColor: tenant.status == 'paid'
                                      ? AppColors.green500
                                      : tenant.status == 'overdue'
                                      ? AppColors.red500
                                      : AppColors.amber500,
                                ),
                              ],
                            ),
                            Text(
                              '${tenant.unit}, ${tenant.property.name}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.grey500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  size: 14,
                                  color: AppColors.grey500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  tenant.phone,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.grey500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
