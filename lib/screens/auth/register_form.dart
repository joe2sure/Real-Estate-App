import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
// import '../../widgets/custom_toast.dart';
import '../../widgets/custom_toaster.dart';
import 'auth_screen.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agreeToTerms = false;
  String _selectedRole = 'user';
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
      );

      if (success) {
        CustomToast.show(context, 'Registration successful', isSuccess: true);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthScreen(initialTab: 'login')),
        );
      } else {
        CustomToast.show(context, authProvider.errorMessage ?? 'Registration failed', isSuccess: false);
      }
    } else if (!_agreeToTerms) {
      CustomToast.show(context, 'Please agree to the Terms of Service', isSuccess: false);
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
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'First Name',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          hintText: 'First Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.grey200),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Last Name',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          hintText: 'Last Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.grey200),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
            const Text(
              'Password',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Create a password',
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
            const Text(
              'Role',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              items: const [
                DropdownMenuItem(value: 'user', child: Text('User')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRole = value ?? 'user';
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.grey200),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _agreeToTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreeToTerms = value ?? false;
                    });
                  },
                ),
                Flexible(
                  child: Text(
                    'I agree to the Terms of Service and Privacy Policy',
                    style: TextStyle(color: AppColors.grey600, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Create Account',
              onPressed: authProvider.state == AuthState.loading ? null : _handleRegister,
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
                    'or sign up with',
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
                  'Already have an account?',
                  style: TextStyle(color: AppColors.grey600, fontSize: 14),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const AuthScreen(initialTab: 'login')),
                    );
                  },
                  child: Text(
                    'Sign In',
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
// import 'auth_screen.dart';

// class RegisterForm extends StatefulWidget {
//   const RegisterForm({super.key});

//   @override
//   _RegisterFormState createState() => _RegisterFormState();
// }

// class _RegisterFormState extends State<RegisterForm> {
//   final _formKey = GlobalKey<FormState>();
//   final _firstNameController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _agreeToTerms = false;
//   String _selectedRole = 'user';
//   bool _isPasswordVisible = false;

//   @override
//   void dispose() {
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _handleRegister() async {
//     if (_formKey.currentState!.validate() && _agreeToTerms) {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final success = await authProvider.register(
//         firstName: _firstNameController.text.trim(),
//         lastName: _lastNameController.text.trim(),
//         email: _emailController.text.trim(),
//         password: _passwordController.text,
//         role: _selectedRole,
//       );

//       if (success) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => const AuthScreen()),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(authProvider.errorMessage ?? 'Registration failed')),
//         );
//       }
//     } else if (!_agreeToTerms) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please agree to the Terms of Service')),
//       );
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
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'First Name',
//                         style: TextStyle(fontWeight: FontWeight.w500),
//                       ),
//                       const SizedBox(height: 8),
//                       TextFormField(
//                         controller: _firstNameController,
//                         decoration: InputDecoration(
//                           hintText: 'First Name',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: BorderSide(color: AppColors.grey200),
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your first name';
//                           }
//                           return null;
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Last Name',
//                         style: TextStyle(fontWeight: FontWeight.w500),
//                       ),
//                       const SizedBox(height: 8),
//                       TextFormField(
//                         controller: _lastNameController,
//                         decoration: InputDecoration(
//                           hintText: 'Last Name',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: BorderSide(color: AppColors.grey200),
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your last name';
//                           }
//                           return null;
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
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
//             const Text(
//               'Password',
//               style: TextStyle(fontWeight: FontWeight.w500),
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               controller: _passwordController,
//               obscureText: !_isPasswordVisible,
//               decoration: InputDecoration(
//                 hintText: 'Create a password',
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
//             const Text(
//               'Role',
//               style: TextStyle(fontWeight: FontWeight.w500),
//             ),
//             const SizedBox(height: 8),
//             DropdownButtonFormField<String>(
//               value: _selectedRole,
//               items: const [
//                 DropdownMenuItem(value: 'user', child: Text('User')),
//                 DropdownMenuItem(value: 'admin', child: Text('Admin')),
//               ],
//               onChanged: (value) {
//                 setState(() {
//                   _selectedRole = value ?? 'user';
//                 });
//               },
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide(color: AppColors.grey200),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Checkbox(
//                   value: _agreeToTerms,
//                   onChanged: (value) {
//                     setState(() {
//                       _agreeToTerms = value ?? false;
//                     });
//                   },
//                 ),
//                 Flexible(
//                   child: Text(
//                     'I agree to the Terms of Service and Privacy Policy',
//                     style: TextStyle(color: AppColors.grey600, fontSize: 14),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             CustomButton(
//               text: 'Create Account',
//               onPressed: authProvider.state == AuthState.loading
//                   ? null
//                   : _handleRegister,
//               isGradient: true,
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(child: Divider(color: AppColors.grey300)),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Text('or sign up with', style: TextStyle(color: AppColors.grey500, fontSize: 12)),
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