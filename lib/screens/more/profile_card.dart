import 'package:flutter/material.dart';
import '../../constants/assets.dart';
import '../../constants/colors.dart';
import '../../widgets/custom_avatar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CustomAvatar(
                  imageUrl: Assets.user,
                  fallbackText: 'JD',
                  size: 64,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'James Davidson',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Property Manager',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey500,
                        ),
                      ),
                      Text(
                        'jdavidson@propertypro.com',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Edit Profile',
              onPressed: () {},
              isOutline: true,
              icon: Icons.edit,
            ),
          ],
        ),
      ),
    );
  }
}