import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/tenant.dart';
import '../../widgets/custom_avatar.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/custom_card.dart';
import 'tenant_detail_screen.dart';
// import 'tenant_detail_screen.dart';

class TenantCard extends StatelessWidget {
  final List<Tenant> tenants;

  const TenantCard({super.key, required this.tenants});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: tenants
          .map(
            (tenant) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TenantDetailScreen(tenantId: tenant.id),
                    ),
                  );
                },
                child: CustomCard(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CustomAvatar(
                          imageUrl: '${tenant.firstName[0]}${tenant.lastName[0]}',
                          size: 48,
                          fallbackText: '${tenant.firstName[0]}${tenant.lastName[0]}',
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    backgroundColor: tenant.status == 'paid'
                                        ? AppColors.green100
                                        : tenant.status == 'overdue'
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
            ),
          )
          .toList(),
    );
  }
}




// import 'package:flutter/material.dart';
// import '../../constants/colors.dart';
// import '../../models/tenant.dart';
// import '../../widgets/custom_avatar.dart';
// import '../../widgets/custom_badge.dart';
// import '../../widgets/custom_card.dart';

// class TenantCard extends StatelessWidget {
//   final List<tenant> tenants;

//   const TenantCard({super.key, required this.tenants});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: tenants
//           .map(
//             (tenant) => Padding(
//               padding: const EdgeInsets.only(bottom: 12),
//               child: CustomCard(
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Row(
//                     children: [
//                         CustomAvatar(
//                         imageUrl: '${tenant.firstName[0]}${tenant.lastName[0]}',
//                         size: 48,
//                         fallbackText: '${tenant.firstName[0]}${tenant.lastName[0]}', // Provide the required fallbackText argument
//                         ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   '${tenant.firstName} ${tenant.lastName}',
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 CustomBadge(
//                                   text: tenant.status,
//                                   backgroundColor: tenant.status == 'paid'
//                                       ? AppColors.green100
//                                       : tenant.status == 'overdue'
//                                           ? AppColors.red100
//                                           : AppColors.amber100,
//                                   textColor: tenant.status == 'paid'
//                                       ? AppColors.green500
//                                       : tenant.status == 'overdue'
//                                           ? AppColors.red500
//                                           : AppColors.amber500,
//                                 ),
//                               ],
//                             ),
//                             Text(
//                               '${tenant.unit}, ${tenant.property.name}',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: AppColors.grey500,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.phone,
//                                   size: 14,
//                                   color: AppColors.grey500,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   tenant.phone,
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: AppColors.grey500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           )
//           .toList(),
//     );
//   }
// }