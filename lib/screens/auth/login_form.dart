import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../dashboard/dashboard_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> 
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isPasswordVisible = false;

  // This keeps the state alive when switching tabs
  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showNotification(String message, {bool isError = false}) {
    // Show Fluttertoast
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: isError ? AppColors.red500 : AppColors.secondaryTeal,
      textColor: AppColors.white,
      fontSize: 16.0,
    );

    // Also show SnackBar as fallback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.red500 : AppColors.secondaryTeal,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        // ✅ CLEAR form only on SUCCESS
        _emailController.clear();
        _passwordController.clear();
        setState(() {
          _rememberMe = false;
          _isPasswordVisible = false;
        });
        
        _showNotification('✓ Login successful! Welcome back.');
        
        // Navigate to dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        // ❌ PRESERVE form data on FAILURE
        setState(() {
          _isPasswordVisible = false; // Hide password for security
        });
        
        final errorMsg = authProvider.errorMessage ?? 'Login failed. Please check your credentials.';
        _showNotification(errorMsg, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    final authProvider = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Email Field
            const Text(
              'Email',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.grey800,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                hintStyle: TextStyle(color: AppColors.grey400, fontSize: 14),
                prefixIcon: Icon(Icons.email_outlined, color: AppColors.grey400, size: 20),
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
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.red500),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.red500, width: 2),
                ),
                filled: true,
                fillColor: AppColors.grey50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            
            const SizedBox(height: 20),
            
            // Password Field
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Password',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.grey800,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _showNotification('Forgot password feature coming soon!');
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleLogin(),
              decoration: InputDecoration(
                hintText: 'Enter your password',
                hintStyle: TextStyle(color: AppColors.grey400, fontSize: 14),
                prefixIcon: Icon(Icons.lock_outline, color: AppColors.grey400, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.grey400,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
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
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.red500),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.red500, width: 2),
                ),
                filled: true,
                fillColor: AppColors.grey50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            
            // Remember Me Checkbox
            Row(
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    activeColor: AppColors.primaryBlue,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Remember me',
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 28),
            
            // Login Button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Login',
                onPressed: authProvider.state == AuthState.loading ? null : _handleLogin,
                isGradient: true,
                isLoading: authProvider.state == AuthState.loading,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Divider
            Row(
              children: [
                Expanded(child: Divider(color: AppColors.grey300, thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: AppColors.grey500,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: AppColors.grey300, thickness: 1)),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Social Login Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Google',
                    onPressed: () => _showNotification('Google sign-in coming soon!'),
                    isOutline: true,
                    icon: Icons.g_mobiledata,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Apple',
                    onPressed: () => _showNotification('Apple sign-in coming soon!'),
                    isOutline: true,
                    icon: Icons.apple,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Sign Up Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Just inform parent to switch tab
                    // The auth_screen handles navigation
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
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
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:provider/provider.dart';
// import '../../constants/colors.dart';
// import '../../providers/auth_provider.dart';
// import '../../widgets/custom_button.dart';
// import '../dashboard/dashboard_screen.dart';
// import 'auth_screen.dart';

// class LoginForm extends StatefulWidget {
//   const LoginForm({super.key});

//   @override
//   _LoginFormState createState() => _LoginFormState();
// }

// class _LoginFormState extends State<LoginForm> with TickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _rememberMe = false;
//   bool _isPasswordVisible = false;
  
//   late AnimationController _animationController;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
    
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
    
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOutCubic,
//     ));
    
//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeIn,
//     ));
    
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _animationController.forward();
//     });
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _handleLogin() async {
//     if (_formKey.currentState!.validate()) {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
//       // Store the input values before attempting login
//       final email = _emailController.text.trim();
//       final password = _passwordController.text;
      
//       final success = await authProvider.login(email, password);

//       if (success) {
//         // Only clear form data on successful login
//         _emailController.clear();
//         _passwordController.clear();
//         setState(() {
//           _rememberMe = false;
//           _isPasswordVisible = false;
//         });
        
//         Fluttertoast.showToast(
//           msg: 'Login successful',
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.TOP_RIGHT,
//           backgroundColor: AppColors.secondaryTeal,
//           textColor: AppColors.white,
//           fontSize: 14.0,
//         );
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => const DashboardScreen()),
//         );
//       } else {
//         // Preserve form data on failed login - don't clear controllers
//         // Only reset password visibility for security
//         setState(() {
//           _isPasswordVisible = false;
//         });
        
//         Fluttertoast.showToast(
//           msg: authProvider.errorMessage ?? 'Login failed',
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.TOP_RIGHT,
//           backgroundColor: AppColors.red500,
//           textColor: AppColors.white,
//           fontSize: 14.0,
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);

//     return SlideTransition(
//       position: _slideAnimation,
//       child: FadeTransition(
//         opacity: _fadeAnimation,
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Email Field
//                 _buildAnimatedField(
//                   delay: 0,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Email',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w500,
//                           color: AppColors.grey800,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       TextFormField(
//                         controller: _emailController,
//                         decoration: InputDecoration(
//                           hintText: 'Enter your email',
//                           hintStyle: TextStyle(color: AppColors.grey400),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppColors.grey200),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppColors.grey200),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
//                           ),
//                           filled: true,
//                           fillColor: AppColors.grey50,
//                           contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 14,
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your email';
//                           }
//                           if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
//                             return 'Please enter a valid email';
//                           }
//                           return null;
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
                
//                 const SizedBox(height: 16),
                
//                 // Password Field
//                 _buildAnimatedField(
//                   delay: 100,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             'Password',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w500,
//                               color: AppColors.grey800,
//                             ),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               // Implement forgot password logic
//                             },
//                             child: Text(
//                               'Forgot?',
//                               style: TextStyle(color: AppColors.primaryBlue),
//                             ),
//                           ),
//                         ],
//                       ),
//                       TextFormField(
//                         controller: _passwordController,
//                         obscureText: !_isPasswordVisible,
//                         decoration: InputDecoration(
//                           hintText: 'Enter your password',
//                           hintStyle: TextStyle(color: AppColors.grey400),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppColors.grey200),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppColors.grey200),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
//                           ),
//                           filled: true,
//                           fillColor: AppColors.grey50,
//                           contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 14,
//                           ),
//                           suffixIcon: IconButton(
//                             icon: Icon(
//                               _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                               color: AppColors.grey400,
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 _isPasswordVisible = !_isPasswordVisible;
//                               });
//                             },
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your password';
//                           }
//                           if (value.length < 6) {
//                             return 'Password must be at least 6 characters';
//                           }
//                           return null;
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
                
//                 const SizedBox(height: 16),
                
//                 // Remember Me
//                 _buildAnimatedField(
//                   delay: 200,
//                   child: Row(
//                     children: [
//                       Checkbox(
//                         value: _rememberMe,
//                         onChanged: (value) {
//                           setState(() {
//                             _rememberMe = value ?? false;
//                           });
//                         },
//                         activeColor: AppColors.primaryBlue,
//                       ),
//                       Text(
//                         'Remember me',
//                         style: TextStyle(color: AppColors.grey600, fontSize: 14),
//                       ),
//                     ],
//                   ),
//                 ),
                
//                 const SizedBox(height: 24),
                
//                 // Login Button - Full Width
//                 _buildAnimatedField(
//                   delay: 300,
//                   child: SizedBox(
//                     width: double.infinity,
//                     child: CustomButton(
//                       text: 'Login',
//                       onPressed: authProvider.state == AuthState.loading ? null : _handleLogin,
//                       isGradient: true,
//                       isLoading: authProvider.state == AuthState.loading,
//                     ),
//                   ),
//                 ),
                
//                 const SizedBox(height: 20),
                
//                 // Divider
//                 _buildAnimatedField(
//                   delay: 400,
//                   child: Row(
//                     children: [
//                       Expanded(child: Divider(color: AppColors.grey300)),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         child: Text(
//                           'or continue with',
//                           style: TextStyle(color: AppColors.grey500, fontSize: 12),
//                         ),
//                       ),
//                       Expanded(child: Divider(color: AppColors.grey300)),
//                     ],
//                   ),
//                 ),
                
//                 const SizedBox(height: 20),
                
//                 // Social Login Buttons
//                 _buildAnimatedField(
//                   delay: 500,
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: CustomButton(
//                           text: 'Google',
//                           onPressed: () {},
//                           isOutline: true,
//                           icon: Icons.g_mobiledata,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: CustomButton(
//                           text: 'Apple',
//                           onPressed: () {},
//                           isOutline: true,
//                           icon: Icons.apple,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
                
//                 const SizedBox(height: 20),
                
//                 // Sign Up Link
//                 _buildAnimatedField(
//                   delay: 600,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Don't have an account?",
//                         style: TextStyle(color: AppColors.grey600, fontSize: 14),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.of(context).pushReplacement(
//                             MaterialPageRoute(builder: (context) => const AuthScreen(initialTab: 'register')),
//                           );
//                         },
//                         child: Text(
//                           'Sign Up',
//                           style: TextStyle(color: AppColors.primaryBlue),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAnimatedField({required int delay, required Widget child}) {
//     return TweenAnimationBuilder<double>(
//       duration: Duration(milliseconds: 300 + delay),
//       tween: Tween(begin: 0.0, end: 1.0),
//       builder: (context, value, _) {
//         return Transform.translate(
//           offset: Offset(0, 10 * (1 - value)),
//           child: Opacity(
//             opacity: value,
//             child: child,
//           ),
//         );
//       },
//     );
//   }
// }