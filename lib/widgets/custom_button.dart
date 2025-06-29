import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isGradient;
  final bool isOutline;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isGradient = false,
    this.isOutline = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: isOutline ? AppColors.grey600 : AppColors.white,
        backgroundColor: isGradient
            ? null
            : isOutline
                ? AppColors.white
                : AppColors.primaryBlue,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: isOutline ? BorderSide(color: AppColors.grey200) : BorderSide.none,
        ),
        elevation: isOutline ? 0 : 2,
      ).copyWith(
        backgroundColor: isGradient
            ? MaterialStateProperty.all(Colors.transparent)
            : null,
        overlayColor: MaterialStateProperty.all(Colors.black12),
      ),
      child: Container(
        decoration: isGradient
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryBlue, AppColors.secondaryTeal],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isOutline ? AppColors.grey800 : AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import '../constants/colors.dart';

// class CustomButton extends StatelessWidget {
//   final String text;
//   final VoidCallback onPressed;
//   final bool isGradient;
//   final bool isOutline;
//   final IconData? icon;

//   const CustomButton({
//     super.key,
//     required this.text,
//     required this.onPressed,
//     this.isGradient = false,
//     this.isOutline = false,
//     this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         foregroundColor: isOutline ? AppColors.grey600 : Colors.white,
//         backgroundColor: isGradient
//             ? null
//             : isOutline
//                 ? Colors.white
//                 : AppColors.primaryBlue,
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//           side: isOutline
//               ? BorderSide(color: AppColors.grey200)
//               : BorderSide.none,
//         ),
//         elevation: isOutline ? 0 : 2,
//       ).copyWith(
//         backgroundColor: isGradient
//             ? MaterialStateProperty.all(Colors.transparent)
//             : null,
//         overlayColor: MaterialStateProperty.all(Colors.black12),
//       ),
//       child: Container(
//         decoration: isGradient
//             ? BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [AppColors.primaryBlue, AppColors.secondaryTeal],
//                   begin: Alignment.centerLeft,
//                   end: Alignment.centerRight,
//                 ),
//                 borderRadius: BorderRadius.circular(8),
//               )
//             : null,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               if (icon != null) ...[
//                 Icon(icon, size: 20),
//                 const SizedBox(width: 8),
//               ],
//               Text(
//                 text,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: isOutline ? AppColors.grey800 : AppColors.white,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }