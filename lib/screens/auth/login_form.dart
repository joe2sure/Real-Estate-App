import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../dashboard/dashboard_screen.dart';
import 'auth_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isPasswordVisible = false;
  
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
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
        Fluttertoast.showToast(
          msg: 'Login successful',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_RIGHT,
          backgroundColor: AppColors.secondaryTeal,
          textColor: AppColors.white,
          fontSize: 14.0,
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        Fluttertoast.showToast(
          msg: authProvider.errorMessage ?? 'Login failed',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_RIGHT,
          backgroundColor: AppColors.red500,
          textColor: AppColors.white,
          fontSize: 14.0,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email Field
                _buildAnimatedField(
                  delay: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(color: AppColors.grey400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.grey200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.grey200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                          ),
                          filled: true,
                          fillColor: AppColors.grey50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
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
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Password Field
                _buildAnimatedField(
                  delay: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.grey800,
                            ),
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
                          hintStyle: TextStyle(color: AppColors.grey400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.grey200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.grey200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                          ),
                          filled: true,
                          fillColor: AppColors.grey50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: AppColors.grey400,
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
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Remember Me
                _buildAnimatedField(
                  delay: 200,
                  child: Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        activeColor: AppColors.primaryBlue,
                      ),
                      Text(
                        'Remember me',
                        style: TextStyle(color: AppColors.grey600, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Login Button - Full Width
                _buildAnimatedField(
                  delay: 300,
                  child: SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Login',
                      onPressed: authProvider.state == AuthState.loading ? null : _handleLogin,
                      isGradient: true,
                      isLoading: authProvider.state == AuthState.loading,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Divider
                _buildAnimatedField(
                  delay: 400,
                  child: Row(
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
                ),
                
                const SizedBox(height: 20),
                
                // Social Login Buttons
                _buildAnimatedField(
                  delay: 500,
                  child: Row(
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
                ),
                
                const SizedBox(height: 20),
                
                // Sign Up Link
                _buildAnimatedField(
                  delay: 600,
                  child: Row(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedField({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../constants/colors.dart';
// import '../../providers/auth_provider.dart';
// import '../../widgets/custom_button.dart';
// // import '../../widgets/custom_toast.dart';
// import '../../widgets/custom_toaster.dart';
// import '../dashboard/dashboard_screen.dart';
// import 'auth_screen.dart';

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
//         CustomToast.show(context, 'Login successful', isSuccess: true);
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => const DashboardScreen()),
//         );
//       } else {
//         CustomToast.show(context, authProvider.errorMessage ?? 'Login failed', isSuccess: false);
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
//                   onPressed: () {
//                     // Implement forgot password logic
//                   },
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
//               onPressed: authProvider.state == AuthState.loading ? null : _handleLogin,
//               isGradient: true,
//               isLoading: authProvider.state == AuthState.loading,
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(child: Divider(color: AppColors.grey300)),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Text(
//                     'or continue with',
//                     style: TextStyle(color: AppColors.grey500, fontSize: 12),
//                   ),
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
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   "Don't have an account?",
//                   style: TextStyle(color: AppColors.grey600, fontSize: 14),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pushReplacement(
//                       MaterialPageRoute(builder: (context) => const AuthScreen(initialTab: 'register')),
//                     );
//                   },
//                   child: Text(
//                     'Sign Up',
//                     style: TextStyle(color: AppColors.primaryBlue),
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