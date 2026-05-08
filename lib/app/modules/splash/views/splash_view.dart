import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_assist/core/constants/app_colors.dart';
import 'package:medi_assist/core/services/permission_service.dart';
import '../../../routes/app_pages.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with TickerProviderStateMixin {
  // ─── Animation Controllers ───────────────────────────────────────────────────
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _progressValue;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    // Logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Text animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    // Progress animation
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // Pulse animation (looping)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _startSequence() async {
    // Step 1: Logo appears
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    // Step 2: Text slides in
    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();

    // Step 3: Progress bar starts
    await Future.delayed(const Duration(milliseconds: 400));
    _progressController.forward();

    // Step 4: Request permissions then navigate
    await Future.delayed(const Duration(milliseconds: 500));
    await _requestPermissions();

    // Step 5: Wait for progress to finish then navigate
    await _progressController.forward();
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      Get.offAllNamed(Routes.home);
    }
  }

  Future<void> _requestPermissions() async {
    try {
      await PermissionService.to.requestAllPermissions();
    } catch (_) {}
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF2563EB),
              Color(0xFF6366F1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // ── Background decorative circles ──
              _buildBackgroundDecorations(),

              // ── Main content ──
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Logo
                    _buildLogo(),

                    const SizedBox(height: 32),

                    // App name + tagline
                    _buildAppName(),

                    const Spacer(flex: 2),

                    // Progress + loading text
                    _buildProgressSection(),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Background Decorations ──────────────────────────────────────────────────
  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          top: -60,
          right: -60,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
        ),
        Positioned(
          bottom: -80,
          left: -50,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
        Positioned(
          top: 100,
          left: -30,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.04),
            ),
          ),
        ),
        Positioned(
          bottom: 160,
          right: -20,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Logo ────────────────────────────────────────────────────────────────────
  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _pulseController]),
      builder: (context, child) {
        return Opacity(
          opacity: _logoOpacity.value,
          child: Transform.scale(
            scale: _logoScale.value * _pulseScale.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 40,
              offset: const Offset(0, 16),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.15),
                  width: 8,
                ),
              ),
            ),
            // Icon
            const Icon(
              Icons.favorite_rounded,
              color: AppColors.primary,
              size: 44,
            ),
            // Small pill icon overlay
            Positioned(
              bottom: 22,
              right: 20,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── App Name ────────────────────────────────────────────────────────────────
  Widget _buildAppName() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return SlideTransition(
          position: _textSlide,
          child: FadeTransition(
            opacity: _textOpacity,
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          const Text(
            'MediAssist',
            style: TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1,
              ),
            ),
            child: const Text(
              'Your Personal Health Companion',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Feature pills
          _buildFeaturePills(),
        ],
      ),
    );
  }

  Widget _buildFeaturePills() {
    final features = [
      ('💊', 'Medicine'),
      ('🍽️', 'Meals'),
      ('📋', 'Records'),
      ('🏃', 'Activity'),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: features
          .map(
            (f) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(f.$1, style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    f.$2,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // ─── Progress Section ────────────────────────────────────────────────────────
  Widget _buildProgressSection() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Column(
            children: [
              // Loading text
              Text(
                _getLoadingText(_progressValue.value),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 16),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progressValue.value,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getLoadingText(double progress) {
    if (progress < 0.3) return 'Initializing services...';
    if (progress < 0.6) return 'Setting up reminders...';
    if (progress < 0.85) return 'Requesting permissions...';
    return 'Almost ready...';
  }
}