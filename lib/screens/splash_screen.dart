import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/assets.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../providers/app_state.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Provider.of<AppState>(context, listen: false).setOnboardingStep(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryBlue, secondaryTeal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    Assets.logo,
                    width: 160,
                    height: 160,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Strings.appName,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Strings.tagline,
                    style: const TextStyle(
                      fontSize: 18,
                      color: white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(white),
                    strokeWidth: 4,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Text(
                Strings.appVersion,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: white,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}