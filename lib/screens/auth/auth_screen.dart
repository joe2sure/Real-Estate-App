import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../constants/assets.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../dashboard/dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  final String initialTab;

  const AuthScreen({super.key, this.initialTab = 'login'});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  
  late AnimationController _backgroundController;
  late AnimationController _logoController;
  late AnimationController _tabController;
  
  late Animation<double> _backgroundAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoGlowAnimation;
  late Animation<Offset> _tabSlideAnimation;

  // Login Form Controllers - PERSIST ACROSS REBUILDS
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _loginRememberMe = false;
  bool _loginPasswordVisible = false;

  // Register Form Controllers - PERSIST ACROSS REBUILDS
  final _registerFormKey = GlobalKey<FormState>();
  final _registerFirstNameController = TextEditingController();
  final _registerLastNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  bool _registerAgreeToTerms = false;
  String _registerSelectedRole = 'user';
  bool _registerPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab == 'register' ? 1 : 0;
    _pageController = PageController(initialPage: _currentIndex);
    
    // Initialize animation controllers
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _tabController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Initialize animations
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));

    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoGlowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    _tabSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _tabController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimations();
    });
  }

  void _startAnimations() async {
    _backgroundController.repeat();
    await _logoController.forward();
    await _tabController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundController.dispose();
    _logoController.dispose();
    _tabController.dispose();
    
    // Dispose login controllers
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    
    // Dispose register controllers
    _registerFirstNameController.dispose();
    _registerLastNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    
    super.dispose();
  }

  void _switchTab(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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

    // Also show SnackBar
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
    if (_loginFormKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.login(
        _loginEmailController.text.trim(),
        _loginPasswordController.text,
      );

      if (!mounted) return;

      if (success) {
        // ✅ SUCCESS - Show notification first, then clear and navigate
        _showNotification('✓ Login successful! Welcome back.');
        
        // Small delay to ensure toast is visible
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Clear form only on success
        _loginEmailController.clear();
        _loginPasswordController.clear();
        setState(() {
          _loginRememberMe = false;
          _loginPasswordVisible = false;
        });
        
        if (!mounted) return;
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        // ❌ FAILURE - Keep form data, only hide password
        setState(() {
          _loginPasswordVisible = false;
        });
        
        final errorMsg = authProvider.errorMessage ?? 'Login failed. Please check your credentials.';
        _showNotification(errorMsg, isError: true);
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_registerAgreeToTerms) {
      _showNotification('Please agree to the Terms of Service', isError: true);
      return;
    }

    if (_registerFormKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.register(
        firstName: _registerFirstNameController.text.trim(),
        lastName: _registerLastNameController.text.trim(),
        email: _registerEmailController.text.trim(),
        password: _registerPasswordController.text,
        role: _registerSelectedRole,
      );

      if (!mounted) return;

      if (success) {
        // ✅ SUCCESS - Show notification first, then clear and switch tab
        _showNotification('✓ Account created successfully! Please login.');
        
        // Small delay to ensure toast is visible
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Clear form only on success
        _registerFirstNameController.clear();
        _registerLastNameController.clear();
        _registerEmailController.clear();
        _registerPasswordController.clear();
        setState(() {
          _registerAgreeToTerms = false;
          _registerSelectedRole = 'user';
          _registerPasswordVisible = false;
        });
        
        if (!mounted) return;
        
        // Switch to login tab
        _switchTab(0);
      } else {
        // ❌ FAILURE - Keep form data, only hide password
        setState(() {
          _registerPasswordVisible = false;
        });
        
        final errorMsg = authProvider.errorMessage ?? 'Registration failed. Please try again.';
        _showNotification(errorMsg, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              const Color(0xFFF8FAFF),
              AppColors.primaryBlue.withOpacity(0.05),
              Colors.white,
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background elements
            AnimatedBuilder(
              animation: _backgroundAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        0.3 + 0.4 * math.sin(_backgroundAnimation.value * 2 * math.pi),
                        0.4 + 0.3 * math.cos(_backgroundAnimation.value * 3 * math.pi),
                      ),
                      radius: 1.5,
                      colors: [
                        AppColors.primaryBlue.withOpacity(0.03),
                        AppColors.secondaryTeal.withOpacity(0.02),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Animated logo
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 32),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 100 * _logoGlowAnimation.value,
                                height: 100 * _logoGlowAnimation.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryBlue.withOpacity(0.1 * _logoGlowAnimation.value),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 80,
                                height: 80,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Colors.white, const Color(0xFFF8FAFF)],
                                  ),
                                  border: Border.all(
                                    color: AppColors.primaryBlue.withOpacity(0.1),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryBlue.withOpacity(0.1),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: SvgPicture.asset(
                                  Assets.logo,
                                  colorFilter: ColorFilter.mode(
                                    AppColors.primaryBlue,
                                    BlendMode.srcIn,
                                  ),
                                  placeholderBuilder: (context) => Icon(
                                    Icons.business,
                                    color: AppColors.primaryBlue,
                                    size: 48,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Tab buttons
                  SlideTransition(
                    position: _tabSlideAnimation,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.white,
                        border: Border.all(color: AppColors.grey200, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTabButton('Login', _currentIndex == 0, () => _switchTab(0)),
                          ),
                          Expanded(
                            child: _buildTabButton('Register', _currentIndex == 1, () => _switchTab(1)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Forms using PageView to preserve state
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        border: Border.all(color: AppColors.grey200, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildLoginForm(),
                            _buildRegisterForm(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isActive
              ? LinearGradient(colors: [AppColors.primaryBlue, AppColors.secondaryTeal])
              : null,
          color: isActive ? null : Colors.transparent,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isActive ? AppColors.white : AppColors.grey600,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.grey800)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _loginEmailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(color: AppColors.grey400, fontSize: 14),
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.grey400, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.grey200)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.grey200)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primaryBlue, width: 2)),
                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.red500)),
                    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.red500, width: 2)),
                    filled: true,
                    fillColor: AppColors.grey50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your email';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Please enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.grey800)),
                    TextButton(
                      onPressed: () => _showNotification('Forgot password feature coming soon!'),
                      child: Text('Forgot Password?', style: TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _loginPasswordController,
                  obscureText: !_loginPasswordVisible,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleLogin(),
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: TextStyle(color: AppColors.grey400, fontSize: 14),
                    prefixIcon: Icon(Icons.lock_outline, color: AppColors.grey400, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(_loginPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.grey400, size: 20),
                      onPressed: () => setState(() => _loginPasswordVisible = !_loginPasswordVisible),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.grey200)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primaryBlue, width: 2)),
                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.red500)),
                    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.red500, width: 2)),
                    filled: true,
                    fillColor: AppColors.grey50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your password';
                    if (value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: Checkbox(
                        value: _loginRememberMe,
                        onChanged: (value) => setState(() => _loginRememberMe = value ?? false),
                        activeColor: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Remember me', style: TextStyle(color: AppColors.grey600, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 28),
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
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.grey300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR', style: TextStyle(color: AppColors.grey500, fontSize: 12)),
                    ),
                    Expanded(child: Divider(color: AppColors.grey300)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: CustomButton(text: 'Google', onPressed: () => _showNotification('Google sign-in coming soon!'), isOutline: true, icon: Icons.g_mobiledata)),
                    const SizedBox(width: 12),
                    Expanded(child: CustomButton(text: 'Apple', onPressed: () => _showNotification('Apple sign-in coming soon!'), isOutline: true, icon: Icons.apple)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegisterForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _registerFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('First Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.grey800)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _registerFirstNameController,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              hintText: 'John',
                              hintStyle: TextStyle(color: AppColors.grey400, fontSize: 14),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.grey200)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primaryBlue, width: 2)),
                              filled: true,
                              fillColor: AppColors.grey50,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Last Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.grey800)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _registerLastNameController,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              hintText: 'Doe',
                              hintStyle: TextStyle(color: AppColors.grey400, fontSize: 14),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.grey200)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primaryBlue, width: 2)),
                              filled: true,
                              fillColor: AppColors.grey50,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.grey800)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _registerEmailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'john.doe@example.com',
                    hintStyle: TextStyle(color: AppColors.grey400, fontSize: 14),
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.grey400, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.grey200)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primaryBlue, width: 2)),
                    filled: true,
                    fillColor: AppColors.grey50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your email';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Please enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text('Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.grey800)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _registerPasswordController,
                  obscureText: !_registerPasswordVisible,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleRegister(),
                  decoration: InputDecoration(
                    hintText: 'Minimum 6 characters',
                    hintStyle: TextStyle(color: AppColors.grey400, fontSize: 14),
                    prefixIcon: Icon(Icons.lock_outline, color: AppColors.grey400, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(_registerPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.grey400, size: 20),
                      onPressed: () => setState(() => _registerPasswordVisible = !_registerPasswordVisible),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.grey200)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primaryBlue, width: 2)),
                    filled: true,
                    fillColor: AppColors.grey50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter a password';
                    if (value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text('Role', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.grey800)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _registerSelectedRole,
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('User')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (value) => setState(() => _registerSelectedRole = value ?? 'user'),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person_outline, color: AppColors.grey400, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.grey200)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primaryBlue, width: 2)),
                    filled: true,
                    fillColor: AppColors.grey50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: Checkbox(
                        value: _registerAgreeToTerms,
                        onChanged: (value) => setState(() => _registerAgreeToTerms = value ?? false),
                        activeColor: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'I agree to the Terms of Service and Privacy Policy',
                        style: TextStyle(color: AppColors.grey600, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
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
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.grey300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR', style: TextStyle(color: AppColors.grey500, fontSize: 12)),
                    ),
                    Expanded(child: Divider(color: AppColors.grey300)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: CustomButton(text: 'Google', onPressed: () => _showNotification('Google sign-up coming soon!'), isOutline: true, icon: Icons.g_mobiledata)),
                    const SizedBox(width: 12),
                    Expanded(child: CustomButton(text: 'Apple', onPressed: () => _showNotification('Apple sign-up coming soon!'), isOutline: true, icon: Icons.apple)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import '../../constants/assets.dart';
// import '../../constants/colors.dart';
// import 'login_form.dart';
// import 'register_form.dart';

// class AuthScreen extends StatefulWidget {
//   final String initialTab;

//   const AuthScreen({super.key, this.initialTab = 'login'});

//   @override
//   _AuthScreenState createState() => _AuthScreenState();
// }

// class _AuthScreenState extends State<AuthScreen>
//     with TickerProviderStateMixin {
//   late String _currentTab;
//   late AnimationController _backgroundController;
//   late AnimationController _logoController;
//   late AnimationController _tabController;
  
//   late Animation<double> _backgroundAnimation;
//   late Animation<double> _logoScaleAnimation;
//   late Animation<double> _logoGlowAnimation;
//   late Animation<Offset> _tabSlideAnimation;

//   // Keep form widgets alive using GlobalKey
//   final GlobalKey<State<StatefulWidget>> _loginFormKey = GlobalKey();
//   final GlobalKey<State<StatefulWidget>> _registerFormKey = GlobalKey();

//   @override
//   void initState() {
//     super.initState();
//     _currentTab = widget.initialTab;
    
//     // Initialize animation controllers
//     _backgroundController = AnimationController(
//       duration: const Duration(seconds: 8),
//       vsync: this,
//     );
    
//     _logoController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     );
    
//     _tabController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );

//     // Initialize animations
//     _backgroundAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _backgroundController,
//       curve: Curves.linear,
//     ));

//     _logoScaleAnimation = Tween<double>(
//       begin: 0.5,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _logoController,
//       curve: Curves.elasticOut,
//     ));

//     _logoGlowAnimation = Tween<double>(
//       begin: 0.3,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _logoController,
//       curve: Curves.easeInOut,
//     ));

//     _tabSlideAnimation = Tween<Offset>(
//       begin: const Offset(0, -0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _tabController,
//       curve: Curves.easeOutCubic,
//     ));

//     // Start animations
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _startAnimations();
//     });
//   }

//   void _startAnimations() async {
//     _backgroundController.repeat();
//     await _logoController.forward();
//     await _tabController.forward();
//   }

//   @override
//   void dispose() {
//     _backgroundController.dispose();
//     _logoController.dispose();
//     _tabController.dispose();
//     super.dispose();
//   }

//   void _switchTab(String tab) {
//     if (_currentTab != tab) {
//       setState(() {
//         _currentTab = tab;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.white,
//               const Color(0xFFF8FAFF),
//               AppColors.primaryBlue.withOpacity(0.05),
//               Colors.white,
//             ],
//             stops: const [0.0, 0.3, 0.7, 1.0],
//           ),
//         ),
//         child: Stack(
//           children: [
//             // Animated background elements with mixed effects
//             AnimatedBuilder(
//               animation: _backgroundAnimation,
//               builder: (context, child) {
//                 return Container(
//                   decoration: BoxDecoration(
//                     gradient: RadialGradient(
//                       center: Alignment(
//                         0.3 + 0.4 * math.sin(_backgroundAnimation.value * 2 * math.pi),
//                         0.4 + 0.3 * math.cos(_backgroundAnimation.value * 3 * math.pi),
//                       ),
//                       radius: 1.5,
//                       colors: [
//                         AppColors.primaryBlue.withOpacity(0.03),
//                         AppColors.secondaryTeal.withOpacity(0.02),
//                         Colors.transparent,
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),

//             // Additional moving gradient overlay
//             AnimatedBuilder(
//               animation: _backgroundAnimation,
//               builder: (context, child) {
//                 return Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment(
//                         -1 + 2 * _backgroundAnimation.value,
//                         -0.5 + _backgroundAnimation.value,
//                       ),
//                       end: Alignment(
//                         1 - 2 * _backgroundAnimation.value,
//                         0.5 - _backgroundAnimation.value,
//                       ),
//                       colors: [
//                         Colors.transparent,
//                         AppColors.primaryBlue.withOpacity(0.02),
//                         AppColors.secondaryTeal.withOpacity(0.02),
//                         Colors.transparent,
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),

//             // Floating geometric shapes
//             ...List.generate(12, (index) => _buildFloatingShape(index)),
            
//             // Floating particles
//             ...List.generate(20, (index) => _buildFloatingParticle(index)),

//             // Main content
//             SafeArea(
//               child: SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 child: Container(
//                   constraints: BoxConstraints(
//                     minHeight: MediaQuery.of(context).size.height - 
//                                MediaQuery.of(context).padding.top,
//                   ),
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 40),
                      
//                       // Animated logo section
//                       AnimatedBuilder(
//                         animation: _logoController,
//                         builder: (context, child) {
//                           return Transform.scale(
//                             scale: _logoScaleAnimation.value,
//                             child: Container(
//                               margin: const EdgeInsets.only(bottom: 32),
//                               child: Stack(
//                                 alignment: Alignment.center,
//                                 children: [
//                                   // Subtle glow effect
//                                   Container(
//                                     width: 100 * _logoGlowAnimation.value,
//                                     height: 100 * _logoGlowAnimation.value,
//                                     decoration: BoxDecoration(
//                                       shape: BoxShape.circle,
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: AppColors.primaryBlue.withOpacity(
//                                             0.1 * _logoGlowAnimation.value,
//                                           ),
//                                           blurRadius: 20,
//                                           spreadRadius: 5,
//                                         ),
//                                         BoxShadow(
//                                           color: AppColors.secondaryTeal.withOpacity(
//                                             0.08 * _logoGlowAnimation.value,
//                                           ),
//                                           blurRadius: 30,
//                                           spreadRadius: 10,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   // Logo
//                                   Container(
//                                     width: 80,
//                                     height: 80,
//                                     padding: const EdgeInsets.all(16),
//                                     decoration: BoxDecoration(
//                                       shape: BoxShape.circle,
//                                       gradient: LinearGradient(
//                                         colors: [
//                                           Colors.white,
//                                           const Color(0xFFF8FAFF),
//                                         ],
//                                       ),
//                                       border: Border.all(
//                                         color: AppColors.primaryBlue.withOpacity(0.1),
//                                         width: 1,
//                                       ),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: AppColors.primaryBlue.withOpacity(0.1),
//                                           blurRadius: 10,
//                                           spreadRadius: 2,
//                                         ),
//                                       ],
//                                     ),
//                                     child: SvgPicture.asset(
//                                       Assets.logo,
//                                       colorFilter: ColorFilter.mode(
//                                         AppColors.primaryBlue,
//                                         BlendMode.srcIn,
//                                       ),
//                                       placeholderBuilder: (context) => Icon(
//                                         Icons.business,
//                                         color: AppColors.primaryBlue,
//                                         size: 48,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),

//                       // Animated tab buttons
//                       SlideTransition(
//                         position: _tabSlideAnimation,
//                         child: Container(
//                           margin: const EdgeInsets.symmetric(horizontal: 24),
//                           padding: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(25),
//                             color: Colors.white,
//                             border: Border.all(
//                               color: AppColors.grey200,
//                               width: 1,
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: AppColors.primaryBlue.withOpacity(0.1),
//                                 blurRadius: 15,
//                                 spreadRadius: 0,
//                                 offset: const Offset(0, 5),
//                               ),
//                             ],
//                           ),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: _buildTabButton(
//                                   'Login',
//                                   _currentTab == 'login',
//                                   () => _switchTab('login'),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: _buildTabButton(
//                                   'Register',
//                                   _currentTab == 'register',
//                                   () => _switchTab('register'),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 32),

//                       // Form container with IndexedStack to preserve state
//                       Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 24),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(20),
//                           color: Colors.white,
//                           border: Border.all(
//                             color: AppColors.grey200,
//                             width: 1,
//                           ),
//                           boxShadow: [
//                             BoxShadow(
//                               color: AppColors.primaryBlue.withOpacity(0.08),
//                               blurRadius: 20,
//                               spreadRadius: 0,
//                               offset: const Offset(0, 10),
//                             ),
//                             BoxShadow(
//                               color: AppColors.grey300.withOpacity(0.1),
//                               blurRadius: 10,
//                               spreadRadius: 0,
//                               offset: const Offset(0, 5),
//                             ),
//                           ],
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(20),
//                           child: Container(
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 begin: Alignment.topCenter,
//                                 end: Alignment.bottomCenter,
//                                 colors: [
//                                   Colors.white,
//                                   const Color(0xFFFCFCFD),
//                                 ],
//                               ),
//                             ),
//                             child: AnimatedSwitcher(
//                               duration: const Duration(milliseconds: 300),
//                               switchInCurve: Curves.easeInOut,
//                               switchOutCurve: Curves.easeInOut,
//                               transitionBuilder: (Widget child, Animation<double> animation) {
//                                 return FadeTransition(
//                                   opacity: animation,
//                                   child: SlideTransition(
//                                     position: Tween<Offset>(
//                                       begin: const Offset(0.0, 0.1),
//                                       end: Offset.zero,
//                                     ).animate(animation),
//                                     child: child,
//                                   ),
//                                 );
//                               },
//                               child: _currentTab == 'login'
//                                   ? LoginForm(key: _loginFormKey)
//                                   : RegisterForm(key: _registerFormKey),
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 40),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTabButton(String title, bool isActive, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           gradient: isActive
//               ? LinearGradient(
//                   colors: [AppColors.primaryBlue, AppColors.secondaryTeal],
//                 )
//               : null,
//           color: isActive ? null : Colors.transparent,
//           boxShadow: isActive
//               ? [
//                   BoxShadow(
//                     color: AppColors.primaryBlue.withOpacity(0.2),
//                     blurRadius: 8,
//                     spreadRadius: 1,
//                     offset: const Offset(0, 2),
//                   ),
//                 ]
//               : null,
//         ),
//         child: Center(
//           child: Text(
//             title,
//             style: TextStyle(
//               color: isActive ? AppColors.white : AppColors.grey600,
//               fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
//               fontSize: 16,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFloatingShape(int index) {
//     final double size = 40 + (index % 4) * 15.0;
//     final double left = (index * 73.0) % MediaQuery.of(context).size.width;
//     final double animationOffset = (index * 0.2) % 1.0;
    
//     return Positioned(
//       left: left,
//       top: 80 + (index * 89.0) % 700,
//       child: TweenAnimationBuilder<double>(
//         duration: Duration(milliseconds: 4000 + (index * 400)),
//         tween: Tween(begin: 0.0, end: 1.0),
//         builder: (context, value, child) {
//           final adjustedValue = (value + animationOffset) % 1.0;
//           return Transform.rotate(
//             angle: adjustedValue * 2 * math.pi,
//             child: Transform.translate(
//               offset: Offset(
//                 15 * math.sin(adjustedValue * 4 * math.pi),
//                 20 * math.cos(adjustedValue * 3 * math.pi),
//               ),
//               child: Opacity(
//                 opacity: 0.03 + 0.02 * math.sin(adjustedValue * math.pi),
//                 child: Container(
//                   width: size,
//                   height: size,
//                   decoration: BoxDecoration(
//                     shape: index % 3 == 0 ? BoxShape.circle : BoxShape.rectangle,
//                     borderRadius: index % 3 != 0 ? BorderRadius.circular(10) : null,
//                     border: Border.all(
//                       color: index % 2 == 0 
//                           ? AppColors.primaryBlue.withOpacity(0.1)
//                           : AppColors.secondaryTeal.withOpacity(0.1),
//                       width: 1.5,
//                     ),
//                     gradient: LinearGradient(
//                       colors: [
//                         (index % 2 == 0 ? AppColors.primaryBlue : AppColors.secondaryTeal)
//                             .withOpacity(0.02),
//                         Colors.transparent,
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildFloatingParticle(int index) {
//     final double size = 1.5 + (index % 3);
//     final double left = (index * 47.0) % MediaQuery.of(context).size.width;
//     final double animationOffset = (index * 0.3) % 1.0;
    
//     return Positioned(
//       left: left,
//       top: 50 + (index * 67.0) % 600,
//       child: TweenAnimationBuilder<double>(
//         duration: Duration(milliseconds: 3000 + (index * 500)),
//         tween: Tween(begin: 0.0, end: 1.0),
//         builder: (context, value, child) {
//           final adjustedValue = (value + animationOffset) % 1.0;
//           return Transform.translate(
//             offset: Offset(
//               8 * math.sin(adjustedValue * 2 * math.pi),
//               -40 * adjustedValue,
//             ),
//             child: Opacity(
//               opacity: (1 - adjustedValue) * 0.15,
//               child: Container(
//                 width: size,
//                 height: size,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: index % 2 == 0 
//                       ? AppColors.primaryBlue.withOpacity(0.3)
//                       : AppColors.secondaryTeal.withOpacity(0.3),
//                   boxShadow: [
//                     BoxShadow(
//                       color: (index % 2 == 0 ? AppColors.primaryBlue : AppColors.secondaryTeal)
//                           .withOpacity(0.1),
//                       blurRadius: 2,
//                       spreadRadius: 0.5,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }