import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
// import '../../widgets/custom_toast.dart';
import '../../widgets/custom_toaster.dart';
import '../dashboard/dashboard_screen.dart';
import 'auth_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success) {
        CustomToast.show(context, 'Login successful', isSuccess: true);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        CustomToast.show(context, authProvider.errorMessage ?? 'Login failed', isSuccess: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Email',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.grey200),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
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
                  onPressed: () {
                    // Implement forgot password logic
                  },
                  child: Text(
                    'Forgot?',
                    style: TextStyle(color: AppColors.primaryBlue),
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.grey200),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                ),
                Text(
                  'Remember me',
                  style: TextStyle(color: AppColors.grey600, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Login',
              onPressed: authProvider.state == AuthState.loading ? null : _handleLogin,
              isGradient: true,
              isLoading: authProvider.state == AuthState.loading,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Divider(color: AppColors.grey300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'or continue with',
                    style: TextStyle(color: AppColors.grey500, fontSize: 12),
                  ),
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: TextStyle(color: AppColors.grey600, fontSize: 14),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const AuthScreen(initialTab: 'register')),
                    );
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(color: AppColors.primaryBlue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../constants/colors.dart';
// import '../../providers/auth_provider.dart';
// import '../../widgets/custom_button.dart';
// import '../dashboard/dashboard_screen.dart';

// class LoginForm extends StatefulWidget {
//   const LoginForm({super.key});

//   @override
//   _LoginFormState createState() => _LoginFormState();
// }

// class _LoginFormState extends State<LoginForm> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _rememberMe = false;
//   bool _isPasswordVisible = false;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _handleLogin() async {
//     if (_formKey.currentState!.validate()) {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final success = await authProvider.login(
//         _emailController.text.trim(),
//         _passwordController.text,
//       );

//       if (success) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => const DashboardScreen()),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(authProvider.errorMessage ?? 'Login failed')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);

//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Email',
//               style: TextStyle(fontWeight: FontWeight.w500),
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               controller: _emailController,
//               decoration: InputDecoration(
//                 hintText: 'Enter your email',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide(color: AppColors.grey200),
//                 ),
//               ),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter your email';
//                 }
//                 if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
//                   return 'Please enter a valid email';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Password',
//                   style: TextStyle(fontWeight: FontWeight.w500),
//                 ),
//                 TextButton(
//                   onPressed: () {},
//                   child: Text(
//                     'Forgot?',
//                     style: TextStyle(color: AppColors.primaryBlue),
//                   ),
//                 ),
//               ],
//             ),
//             TextFormField(
//               controller: _passwordController,
//               obscureText: !_isPasswordVisible,
//               decoration: InputDecoration(
//                 hintText: 'Enter your password',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide(color: AppColors.grey200),
//                 ),
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       _isPasswordVisible = !_isPasswordVisible;
//                     });
//                   },
//                 ),
//               ),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter your password';
//                 }
//                 if (value.length < 6) {
//                   return 'Password must be at least 6 characters';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Checkbox(
//                   value: _rememberMe,
//                   onChanged: (value) {
//                     setState(() {
//                       _rememberMe = value ?? false;
//                     });
//                   },
//                 ),
//                 Text(
//                   'Remember me',
//                   style: TextStyle(color: AppColors.grey600, fontSize: 14),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             CustomButton(
//               text: 'Login',
//               onPressed: authProvider.state == AuthState.loading
//                   ? null
//                   : _handleLogin,
//               isGradient: true,
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(child: Divider(color: AppColors.grey300)),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Text('or continue with', style: TextStyle(color: AppColors.grey500, fontSize: 12)),
//                 ),
//                 Expanded(child: Divider(color: AppColors.grey300)),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: CustomButton(
//                     text: 'Google',
//                     onPressed: () {},
//                     isOutline: true,
//                     icon: Icons.g_mobiledata,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: CustomButton(
//                     text: 'Apple',
//                     onPressed: () {},
//                     isOutline: true,
//                     icon: Icons.apple,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }