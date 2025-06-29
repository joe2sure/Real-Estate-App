import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../providers/app_state.dart';
import '../../widgets/custom_button.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Email',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Enter your email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.grey200),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Password',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Forgot?',
                  style: TextStyle(color: AppColors.primaryBlue),
                ),
              ),
            ],
          ),
          TextFormField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Enter your password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.grey200),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(value: false, onChanged: (value) {}),
              Text(
                'Remember me',
                style: TextStyle(color: AppColors.grey600, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Login',
            onPressed: () => Provider.of<AppState>(context, listen: false).setActiveTab('dashboard', context: context),
            isGradient: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Divider(color: AppColors.grey300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('or continue with', style: TextStyle(color: AppColors.grey500, fontSize: 12)),
              ),
              Expanded(child: Divider(color: AppColors.grey300)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Google',
                  onPressed: () {},
                  isOutline: true,
                  icon: Icons.g_mobiledata,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Apple',
                  onPressed: () {},
                  isOutline: true,
                  icon: Icons.apple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import '../../constants/colors.dart';
// import '../../providers/app_state.dart';
// import '../../widgets/custom_button.dart';
// import 'package:provider/provider.dart';

// class LoginForm extends StatelessWidget {
//   const LoginForm({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Email',
//             style: TextStyle(fontWeight: FontWeight.w500),
//           ),
//           const SizedBox(height: 8),
//           TextFormField(
//             decoration: InputDecoration(
//               hintText: 'Enter your email',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(color: AppColors.grey200),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Password',
//                 style: TextStyle(fontWeight: FontWeight.w500),
//               ),
//               TextButton(
//                 onPressed: () {},
//                 child: Text(
//                   'Forgot?',
//                   style: TextStyle(color: AppColors.primaryBlue),
//                 ),
//               ),
//             ],
//           ),
//           TextFormField(
//             obscureText: true,
//             decoration: InputDecoration(
//               hintText: 'Enter your password',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(color: AppColors.grey200),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Checkbox(value: false, onChanged: (value) {}),
//               Text(
//                 'Remember me',
//                 style: TextStyle(color: AppColors.grey600, fontSize: 14),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           CustomButton(
//             text: 'Login',
//             onPressed: () => Provider.of<AppState>(context, listen: false).setActiveTab('dashboard'),
//             isGradient: true,
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(child: Divider(color: AppColors.grey300)),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Text('or continue with', style: TextStyle(color: AppColors.grey500, fontSize: 12)),
//               ),
//               Expanded(child: Divider(color: AppColors.grey300)),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: CustomButton(
//                   text: 'Google',
//                   onPressed: () {},
//                   isOutline: true,
//                   icon: Icons.g_mobiledata,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: CustomButton(
//                   text: 'Apple',
//                   onPressed: () {},
//                   isOutline: true,
//                   icon: Icons.apple,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }