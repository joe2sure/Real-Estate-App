import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final double elevation;
  final BorderRadius borderRadius;

  const CustomCard({
    super.key,
    required this.child,
    this.elevation = 2,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      color: white,
      child: child,
    );
  }
}