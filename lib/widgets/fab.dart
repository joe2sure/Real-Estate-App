import 'package:flutter/material.dart';
import '../constants/colors.dart';

class FloatingActionButtonWidget extends StatelessWidget {
  const FloatingActionButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {},
      backgroundColor: Colors.transparent,
      elevation: 6,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryBlue, secondaryTeal],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.add, color: white, size: 24),
        ),
      ),
    );
  }
}