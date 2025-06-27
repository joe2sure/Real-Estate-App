import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CustomAvatar extends StatelessWidget {
  final String? imageUrl;
  final String fallbackText;
  final double size;

  const CustomAvatar({
    super.key,
    this.imageUrl,
    required this.fallbackText,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      backgroundColor: grey100,
      child: imageUrl == null
          ? Text(
              fallbackText,
              style: TextStyle(
                color: grey600,
                fontSize: size / 2.5,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
    );
  }
}