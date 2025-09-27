import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../constants/assets.dart';
import '../../constants/colors.dart';
import 'login_form.dart';
import 'register_form.dart';

class AuthScreen extends StatefulWidget {
  final String initialTab;

  const AuthScreen({super.key, this.initialTab = 'login'});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with TickerProviderStateMixin {
  late String _currentTab;
  late AnimationController _backgroundController;
  late AnimationController _logoController;
  late AnimationController _tabController;
  late AnimationController _formController;
  
  late Animation<double> _backgroundAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoGlowAnimation;
  late Animation<Offset> _tabSlideAnimation;
  late Animation<double> _formFadeAnimation;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    
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
    
    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

    _formFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeIn,
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
    await _formController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _logoController.dispose();
    _tabController.dispose();
    _formController.dispose();
    super.dispose();
  }

  void _switchTab(String tab) {
    if (_currentTab != tab) {
      _formController.reverse().then((_) {
        setState(() {
          _currentTab = tab;
        });
        _formController.forward();
      });
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
            // Animated background elements with mixed effects
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

            // Additional moving gradient overlay
            AnimatedBuilder(
              animation: _backgroundAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(
                        -1 + 2 * _backgroundAnimation.value,
                        -0.5 + _backgroundAnimation.value,
                      ),
                      end: Alignment(
                        1 - 2 * _backgroundAnimation.value,
                        0.5 - _backgroundAnimation.value,
                      ),
                      colors: [
                        Colors.transparent,
                        AppColors.primaryBlue.withOpacity(0.02),
                        AppColors.secondaryTeal.withOpacity(0.02),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),

            // Floating geometric shapes
            ...List.generate(12, (index) => _buildFloatingShape(index)),
            
            // Floating particles
            ...List.generate(20, (index) => _buildFloatingParticle(index)),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 
                               MediaQuery.of(context).padding.top,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      
                      // Animated logo section
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
                                  // Subtle glow effect
                                  Container(
                                    width: 100 * _logoGlowAnimation.value,
                                    height: 100 * _logoGlowAnimation.value,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryBlue.withOpacity(
                                            0.1 * _logoGlowAnimation.value,
                                          ),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                        BoxShadow(
                                          color: AppColors.secondaryTeal.withOpacity(
                                            0.08 * _logoGlowAnimation.value,
                                          ),
                                          blurRadius: 30,
                                          spreadRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Logo
                                  Container(
                                    width: 80,
                                    height: 80,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white,
                                          const Color(0xFFF8FAFF),
                                        ],
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

                      // Animated tab buttons
                      SlideTransition(
                        position: _tabSlideAnimation,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Colors.white,
                            border: Border.all(
                              color: AppColors.grey200,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withOpacity(0.1),
                                blurRadius: 15,
                                spreadRadius: 0,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildTabButton(
                                  'Login',
                                  _currentTab == 'login',
                                  () => _switchTab('login'),
                                ),
                              ),
                              Expanded(
                                child: _buildTabButton(
                                  'Register',
                                  _currentTab == 'register',
                                  () => _switchTab('register'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Animated form container
                      FadeTransition(
                        opacity: _formFadeAnimation,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            border: Border.all(
                              color: AppColors.grey200,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withOpacity(0.08),
                                blurRadius: 20,
                                spreadRadius: 0,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: AppColors.grey300.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 0,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white,
                                    const Color(0xFFFCFCFD),
                                  ],
                                ),
                              ),
                              child: _currentTab == 'login' 
                                  ? const LoginForm() 
                                  : const RegisterForm(),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
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
              ? LinearGradient(
                  colors: [AppColors.primaryBlue, AppColors.secondaryTeal],
                )
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

  Widget _buildFloatingShape(int index) {
    final double size = 40 + (index % 4) * 15.0;
    final double left = (index * 73.0) % MediaQuery.of(context).size.width;
    final double animationOffset = (index * 0.2) % 1.0;
    
    return Positioned(
      left: left,
      top: 80 + (index * 89.0) % 700,
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 4000 + (index * 400)),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          final adjustedValue = (value + animationOffset) % 1.0;
          return Transform.rotate(
            angle: adjustedValue * 2 * math.pi,
            child: Transform.translate(
              offset: Offset(
                15 * math.sin(adjustedValue * 4 * math.pi),
                20 * math.cos(adjustedValue * 3 * math.pi),
              ),
              child: Opacity(
                opacity: 0.03 + 0.02 * math.sin(adjustedValue * math.pi),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: index % 3 == 0 ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius: index % 3 != 0 ? BorderRadius.circular(10) : null,
                    border: Border.all(
                      color: index % 2 == 0 
                          ? AppColors.primaryBlue.withOpacity(0.1)
                          : AppColors.secondaryTeal.withOpacity(0.1),
                      width: 1.5,
                    ),
                    gradient: LinearGradient(
                      colors: [
                        (index % 2 == 0 ? AppColors.primaryBlue : AppColors.secondaryTeal)
                            .withOpacity(0.02),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final double size = 1.5 + (index % 3);
    final double left = (index * 47.0) % MediaQuery.of(context).size.width;
    final double animationOffset = (index * 0.3) % 1.0;
    
    return Positioned(
      left: left,
      top: 50 + (index * 67.0) % 600,
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 3000 + (index * 500)),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          final adjustedValue = (value + animationOffset) % 1.0;
          return Transform.translate(
            offset: Offset(
              8 * math.sin(adjustedValue * 2 * math.pi),
              -40 * adjustedValue,
            ),
            child: Opacity(
              opacity: (1 - adjustedValue) * 0.15,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index % 2 == 0 
                      ? AppColors.primaryBlue.withOpacity(0.3)
                      : AppColors.secondaryTeal.withOpacity(0.3),
                  boxShadow: [
                    BoxShadow(
                      color: (index % 2 == 0 ? AppColors.primaryBlue : AppColors.secondaryTeal)
                          .withOpacity(0.1),
                      blurRadius: 2,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}




// import 'package:Peeman/constants/assets.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import '../../constants/colors.dart';
// import 'login_form.dart';
// import 'register_form.dart';

// class AuthScreen extends StatefulWidget {
//   final String initialTab;

//   const AuthScreen({super.key, this.initialTab = 'login'});

//   @override
//   _AuthScreenState createState() => _AuthScreenState();
// }

// class _AuthScreenState extends State<AuthScreen> {
//   late String _currentTab;

//   @override
//   void initState() {
//     super.initState();
//     _currentTab = widget.initialTab;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
//                 child: Column(
//                   children: [
//                     SvgPicture.asset(
//                       'assets/images/peeman-logo.svg',
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         _buildTabButton('Login', _currentTab == 'login', () {
//                           setState(() {
//                             _currentTab = 'login';
//                           });
//                         }),
//                         const SizedBox(width: 8),
//                         _buildTabButton('Register', _currentTab == 'register', () {
//                           setState(() {
//                             _currentTab = 'register';
//                           });
//                         }),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               _currentTab == 'login' ? const LoginForm() : const RegisterForm(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTabButton(String title, bool isActive, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
//         decoration: BoxDecoration(
//           color: isActive ? AppColors.primaryBlue : AppColors.grey100,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(
//           title,
//           style: TextStyle(
//             color: isActive ? AppColors.white : AppColors.grey600,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//     );
//   }
// }