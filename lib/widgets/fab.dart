import 'package:flutter/material.dart';

import '../constants/colors.dart';

class FloatingActionButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const FloatingActionButtonWidget({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 6,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.secondaryTeal],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.add, color: AppColors.white, size: 24),
          ),
        ),
      ),
    );
  }
}