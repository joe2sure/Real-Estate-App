import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> 
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agreeToTerms = false;
  String _selectedRole = 'user';
  bool _isPasswordVisible = false;

  // This keeps the state alive when switching tabs
  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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

  Future<void> _handleRegister() async {
    if (!_agreeToTerms) {
      _showNotification('Please agree to the Terms of Service', isError: true);
      return;
    }

    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
      );

      if (!mounted) return;

      if (success) {
        // ✅ CLEAR form only on SUCCESS
        _firstNameController.clear();
        _lastNameController.clear();
        _emailController.clear();
        _passwordController.clear();
        setState(() {
          _agreeToTerms = false;
          _selectedRole = 'user';
          _isPasswordVisible = false;
        });
        
        _showNotification('✓ Account created successfully! Please login.');
        
        // Note: Navigation to login tab should be handled by parent
      } else {
        // ❌ PRESERVE form data on FAILURE
        setState(() {
          _isPasswordVisible = false; // Hide password for security
        });
        
        final errorMsg = authProvider.errorMessage ?? 'Registration failed. Please try again.';
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
            // Name Fields
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'First Name',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.grey800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _firstNameController,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: 'John',
                          hintStyle: TextStyle(color: AppColors.grey400, fontSize: 14),
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
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Last Name',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.grey800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _lastNameController,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: 'Doe',
                          hintStyle: TextStyle(color: AppColors.grey400, fontSize: 14),
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
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
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
                hintText: 'john.doe@example.com',
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
            const Text(
              'Password',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.grey800,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleRegister(),
              decoration: InputDecoration(
                hintText: 'Minimum 6 characters',
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
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            // Role Dropdown
            const Text(
              'Role',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.grey800,
              ),
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
                prefixIcon: Icon(Icons.person_outline, color: AppColors.grey400, size: 20),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Terms Checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeToTerms = value ?? false;
                      });
                    },
                    activeColor: AppColors.primaryBlue,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'I agree to the Terms of Service and Privacy Policy',
                    style: TextStyle(
                      color: AppColors.grey600,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 28),
            
            // Register Button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Create Account',
                onPressed: authProvider.state == AuthState.loading ? null : _handleRegister,
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
            
            // Social Sign Up Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Google',
                    onPressed: () => _showNotification('Google sign-up coming soon!'),
                    isOutline: true,
                    icon: Icons.g_mobiledata,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Apple',
                    onPressed: () => _showNotification('Apple sign-up coming soon!'),
                    isOutline: true,
                    icon: Icons.apple,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Sign In Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Parent auth_screen will handle navigation
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Sign In',
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
// import 'auth_screen.dart';

// class RegisterForm extends StatefulWidget {
//   const RegisterForm({super.key});

//   @override
//   _RegisterFormState createState() => _RegisterFormState();
// }

// class _RegisterFormState extends State<RegisterForm> with TickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _firstNameController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _agreeToTerms = false;
//   String _selectedRole = 'user';
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
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _handleRegister() async {
//     if (_formKey.currentState!.validate() && _agreeToTerms) {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
//       // Store the input values before attempting registration
//       final firstName = _firstNameController.text.trim();
//       final lastName = _lastNameController.text.trim();
//       final email = _emailController.text.trim();
//       final password = _passwordController.text;
//       final role = _selectedRole;
      
//       final success = await authProvider.register(
//         firstName: firstName,
//         lastName: lastName,
//         email: email,
//         password: password,
//         role: role,
//       );

//       if (success) {
//         // Only clear form data on successful registration
//         _firstNameController.clear();
//         _lastNameController.clear();
//         _emailController.clear();
//         _passwordController.clear();
//         setState(() {
//           _agreeToTerms = false;
//           _selectedRole = 'user';
//           _isPasswordVisible = false;
//         });
        
//         Fluttertoast.showToast(
//           msg: 'Registration successful',
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.TOP_RIGHT,
//           backgroundColor: AppColors.secondaryTeal,
//           textColor: AppColors.white,
//           fontSize: 14.0,
//         );
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => const AuthScreen(initialTab: 'login')),
//         );
//       } else {
//         // Preserve form data on failed registration - don't clear controllers
//         // Only reset password visibility for security
//         setState(() {
//           _isPasswordVisible = false;
//         });
        
//         Fluttertoast.showToast(
//           msg: authProvider.errorMessage ?? 'Registration failed',
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.TOP_RIGHT,
//           backgroundColor: AppColors.red500,
//           textColor: AppColors.white,
//           fontSize: 14.0,
//         );
//       }
//     } else if (!_agreeToTerms) {
//       Fluttertoast.showToast(
//         msg: 'Please agree to the Terms of Service',
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.TOP_RIGHT,
//         backgroundColor: AppColors.red500,
//         textColor: AppColors.white,
//         fontSize: 14.0,
//       );
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
//                 // Name Fields Row
//                 _buildAnimatedField(
//                   delay: 0,
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'First Name',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w500,
//                                 color: AppColors.grey800,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             TextFormField(
//                               controller: _firstNameController,
//                               decoration: InputDecoration(
//                                 hintText: 'First Name',
//                                 hintStyle: TextStyle(color: AppColors.grey400),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                   borderSide: BorderSide(color: AppColors.grey200),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                   borderSide: BorderSide(color: AppColors.grey200),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                   borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
//                                 ),
//                                 filled: true,
//                                 fillColor: AppColors.grey50,
//                                 contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 16,
//                                   vertical: 14,
//                                 ),
//                               ),
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Required';
//                                 }
//                                 return null;
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Last Name',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w500,
//                                 color: AppColors.grey800,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             TextFormField(
//                               controller: _lastNameController,
//                               decoration: InputDecoration(
//                                 hintText: 'Last Name',
//                                 hintStyle: TextStyle(color: AppColors.grey400),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                   borderSide: BorderSide(color: AppColors.grey200),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                   borderSide: BorderSide(color: AppColors.grey200),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                   borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
//                                 ),
//                                 filled: true,
//                                 fillColor: AppColors.grey50,
//                                 contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 16,
//                                   vertical: 14,
//                                 ),
//                               ),
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Required';
//                                 }
//                                 return null;
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
                
//                 const SizedBox(height: 16),
                
//                 // Email Field
//                 _buildAnimatedField(
//                   delay: 100,
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
//                   delay: 200,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Password',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w500,
//                           color: AppColors.grey800,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       TextFormField(
//                         controller: _passwordController,
//                         obscureText: !_isPasswordVisible,
//                         decoration: InputDecoration(
//                           hintText: 'Create a password',
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
                
//                 // Role Field
//                 _buildAnimatedField(
//                   delay: 300,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Role',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w500,
//                           color: AppColors.grey800,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       DropdownButtonFormField<String>(
//                         value: _selectedRole,
//                         items: const [
//                           DropdownMenuItem(value: 'user', child: Text('User')),
//                           DropdownMenuItem(value: 'admin', child: Text('Admin')),
//                         ],
//                         onChanged: (value) {
//                           setState(() {
//                             _selectedRole = value ?? 'user';
//                           });
//                         },
//                         decoration: InputDecoration(
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
//                       ),
//                     ],
//                   ),
//                 ),
                
//                 const SizedBox(height: 16),
                
//                 // Terms Checkbox
//                 _buildAnimatedField(
//                   delay: 400,
//                   child: Row(
//                     children: [
//                       Checkbox(
//                         value: _agreeToTerms,
//                         onChanged: (value) {
//                           setState(() {
//                             _agreeToTerms = value ?? false;
//                           });
//                         },
//                         activeColor: AppColors.primaryBlue,
//                       ),
//                       Flexible(
//                         child: Text(
//                           'I agree to the Terms of Service and Privacy Policy',
//                           style: TextStyle(color: AppColors.grey600, fontSize: 14),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
                
//                 const SizedBox(height: 24),
                
//                 // Register Button - Full Width
//                 _buildAnimatedField(
//                   delay: 500,
//                   child: SizedBox(
//                     width: double.infinity,
//                     child: CustomButton(
//                       text: 'Create Account',
//                       onPressed: authProvider.state == AuthState.loading ? null : _handleRegister,
//                       isGradient: true,
//                       isLoading: authProvider.state == AuthState.loading,
//                     ),
//                   ),
//                 ),
                
//                 const SizedBox(height: 20),
                
//                 // Divider
//                 _buildAnimatedField(
//                   delay: 600,
//                   child: Row(
//                     children: [
//                       Expanded(child: Divider(color: AppColors.grey300)),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         child: Text(
//                           'or sign up with',
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
//                   delay: 700,
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
                
//                 // Sign In Link
//                 _buildAnimatedField(
//                   delay: 800,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Already have an account?',
//                         style: TextStyle(color: AppColors.grey600, fontSize: 14),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.of(context).pushReplacement(
//                             MaterialPageRoute(builder: (context) => const AuthScreen(initialTab: 'login')),
//                           );
//                         },
//                         child: Text(
//                           'Sign In',
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