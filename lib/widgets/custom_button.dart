import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isGradient;
  final bool isOutline;
  final IconData? icon;
  final bool isLoading;
  final double? minWidth;
  final double? maxWidth;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isGradient = false,
    this.isOutline = false,
    this.icon,
    this.isLoading = false,
    this.minWidth,
    this.maxWidth,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
    if (widget.onPressed != null && !widget.isLoading) {
      widget.onPressed!();
    }
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  // Calculate dynamic width based on text content
  double _calculateButtonWidth(BuildContext context) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Base padding + icon space + text width + extra padding
    double calculatedWidth = 32.0; 
    
    if (widget.icon != null || widget.isLoading) {
      calculatedWidth += 28.0; 
    }
    
    calculatedWidth += textPainter.width + 16.0; 

    // Apply constraints
    if (widget.minWidth != null) {
      calculatedWidth = calculatedWidth < widget.minWidth! 
          ? widget.minWidth! 
          : calculatedWidth;
    }
    
    if (widget.maxWidth != null) {
      calculatedWidth = calculatedWidth > widget.maxWidth! 
          ? widget.maxWidth! 
          : calculatedWidth;
    }

    return calculatedWidth;
  }

  @override
  Widget build(BuildContext context) {
    final buttonWidth = _calculateButtonWidth(context);
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: widget.onPressed != null && !widget.isLoading 
                ? _handleTapDown 
                : null,
            onTapUp: widget.onPressed != null && !widget.isLoading 
                ? _handleTapUp 
                : null,
            onTapCancel: widget.onPressed != null && !widget.isLoading 
                ? _handleTapCancel 
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: buttonWidth,
              height: 48,
              decoration: BoxDecoration(
                gradient: widget.isGradient
                    ? LinearGradient(
                        colors: widget.isLoading 
                            ? [
                                AppColors.primaryBlue.withOpacity(0.7),
                                AppColors.secondaryTeal.withOpacity(0.7)
                              ]
                            : [AppColors.primaryBlue, AppColors.secondaryTeal],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                color: !widget.isGradient
                    ? widget.isOutline
                        ? Colors.transparent
                        : widget.isLoading 
                            ? AppColors.primaryBlue.withOpacity(0.7)
                            : AppColors.primaryBlue
                    : null,
                borderRadius: BorderRadius.circular(12),
                border: widget.isOutline
                    ? Border.all(
                        color: AppColors.grey300,
                        width: 1.5,
                      )
                    : null,
                boxShadow: !widget.isOutline && widget.onPressed != null
                    ? [
                        BoxShadow(
                          color: widget.isGradient
                              ? AppColors.primaryBlue.withOpacity(0.3)
                              : AppColors.primaryBlue.withOpacity(0.2),
                          blurRadius: _isPressed ? 8 : 12,
                          offset: Offset(0, _isPressed ? 2 : 4),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: widget.onPressed != null && !widget.isLoading 
                      ? widget.onPressed 
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.isLoading) ...[
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.isOutline 
                                    ? AppColors.primaryBlue 
                                    : AppColors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ] else if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            size: 18,
                            color: widget.isOutline 
                                ? AppColors.grey800 
                                : AppColors.white,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            widget.text,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: widget.isOutline 
                                  ? AppColors.grey800 
                                  : AppColors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}






// import 'package:flutter/material.dart';
// import '../constants/colors.dart';

// class CustomButton extends StatelessWidget {
//   final String text;
//   final VoidCallback? onPressed;
//   final bool isGradient;
//   final bool isOutline;
//   final IconData? icon;
//   final bool isLoading;

//   const CustomButton({
//     super.key,
//     required this.text,
//     this.onPressed,
//     this.isGradient = false,
//     this.isOutline = false,
//     this.icon,
//     this.isLoading = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: isLoading ? null : onPressed,
//       style: ElevatedButton.styleFrom(
//         foregroundColor: isOutline ? AppColors.grey600 : AppColors.white,
//         backgroundColor: isGradient
//             ? null
//             : isOutline
//                 ? AppColors.white
//                 : AppColors.primaryBlue,
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//           side: isOutline ? BorderSide(color: AppColors.grey200) : BorderSide.none,
//         ),
//         elevation:  0 ,
//       ).copyWith(
//         backgroundColor: isGradient
//             ? MaterialStateProperty.all(Colors.transparent)
//             : null,
//         overlayColor: MaterialStateProperty.all(Colors.black12),
//       ),
//       child: Container(
//         height: 50,
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
//               if (isLoading) ...[
//                 const SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//               ],
//               if (icon != null && !isLoading) ...[
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