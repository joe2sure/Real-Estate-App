import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../constants/assets.dart';
import '../constants/colors.dart';
import '../models/onboarding_data.dart';
import '../providers/app_state.dart';
import '../widgets/custom_button.dart';

class OnboardingScreen extends StatelessWidget {
   OnboardingScreen({super.key});

  final List<OnboardingData> onboardingData = [
    OnboardingData(
      title: 'Track Your Properties',
      description:
          'Easily manage all your properties in one place. Monitor performance, occupancy, and maintenance needs at a glance.',
      image: Assets.onboarding1,
    ),
    OnboardingData(
      title: 'Monitor Tenants & Payments',
      description:
          'Keep track of tenant information, lease agreements, and payment history. Get notified of upcoming and overdue payments.',
      image: Assets.onboarding2,
    ),
    OnboardingData(
      title: 'Collaborate With Your Team',
      description:
          'Invite team members, assign roles, and streamline communication. Work together efficiently to manage your properties.',
      image: Assets.onboarding3,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentStep = appState.onboardingStep;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: double.infinity,
                    initialPage: currentStep,
                    enableInfiniteScroll: false,
                    viewportFraction: 1.0,
                    onPageChanged: (index, _) {
                      appState.setOnboardingStep(index);
                    },
                  ),
                  items: onboardingData.map((data) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          data.image,
                          width: 256,
                          height: 256,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          data.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.grey800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            data.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.grey600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboardingData.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentStep == index ? AppColors.primaryBlue : AppColors.grey300,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 16,
            right: 16,
            child: CustomButton(
              text: 'Skip',
              onPressed: () => appState.setOnboardingStep(-1),
              isOutline: true,
            ),
          ),
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentStep > 0)
                  CustomButton(
                    text: 'Back',
                    onPressed: () => appState.setOnboardingStep(currentStep - 1),
                    isOutline: true,
                  )
                else
                  const SizedBox(),
                CustomButton(
                  text: currentStep < onboardingData.length - 1 ? 'Next' : 'Get Started',
                  onPressed: () {
                    if (currentStep < onboardingData.length - 1) {
                      appState.setOnboardingStep(currentStep + 1);
                    } else {
                      appState.setOnboardingStep(-1);
                    }
                  },
                  isGradient: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}