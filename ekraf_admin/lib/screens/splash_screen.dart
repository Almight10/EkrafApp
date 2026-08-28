import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _logoFadeAnimation;
  late final Animation<Offset> _textSlideAnimation;
  late final Animation<double> _textFadeAnimation;

  late final AnimationController _breathingController;
  late final Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Controller untuk animasi kemunculan bertahap (Staggered Entry ~1600ms total)
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // A.1: Logo fade-in + scale up (0.65 -> 1.0), kurva jelas terlihat membesar & muncul bertahap
    _logoScaleAnimation = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.05, 0.65, curve: Curves.easeOutBack),
      ),
    );
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.05, 0.55, curve: Curves.easeInQuad),
      ),
    );

    // A.2: Teks menyusul (fade-in + slide jelas dari bawah), durasi ~750ms
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.50),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.45, 0.95, curve: Curves.easeOutCubic),
      ),
    );
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.45, 0.85, curve: Curves.easeIn),
      ),
    );

    // A.3: Animasi Breathing halus pada logo (1.0 -> 1.03 -> 1.0 berulang)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOut,
      ),
    );

    // Beri jeda singkat setelah frame pertama dirender di layar agar transisi fade-in terlihat penuh & tidak terpotong
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        _entryController.forward().then((_) {
          if (mounted) {
            _breathingController.repeat(reverse: true);
          }
        });
      }
    });

    // Jalankan inisialisasi sesi di background
    _checkSessionAndNavigate();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  Future<void> _checkSessionAndNavigate() async {
    final startTime = DateTime.now();

    final authProvider = context.read<AuthProvider>();
    if (authProvider.isPasswordRecovery) return;

    final isLoggedIn = await authProvider.checkSession();
    if (authProvider.isPasswordRecovery) return;

    // Pastikan user melihat animasi staggered & breathing dengan durasi yang nyaman (~2.8 detik)
    final elapsed = DateTime.now().difference(startTime);
    const minSplashDuration = Duration(milliseconds: 2800);
    if (elapsed < minSplashDuration) {
      await Future.delayed(minSplashDuration - elapsed);
    }

    if (!mounted || authProvider.isPasswordRecovery) return;

    if (isLoggedIn) {
      // Jika sudah login, transisi fade ke MainShell
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainShell(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      // B.6: Jika belum login, transisi ke LoginScreen dengan Hero & Fade yang lebih santai & halus
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(
            showSplash: false,
            isInitialLaunch: true,
          ),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: CurvedAnimation(
              parent: anim,
              curve: Curves.easeInOutCubic,
            ),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 900),
        ),
      );
    }
  }

  // Flight shuttle builder untuk logo Hero yang mulus
  Widget _logoFlightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return Image.asset(
      'assets/images/logo_dispopar_symbol.png',
      fit: BoxFit.contain,
    );
  }

  // Flight shuttle builder untuk teks Hero
  Widget _titleFlightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final isPop = flightDirection == HeroFlightDirection.pop;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = isPop ? (1.0 - animation.value) : animation.value;
        final curveValue = Curves.easeInOutCubic.transform(t);
        final fontSize = lerpDouble(30.0, 16.0, curveValue)!;
        final letterSpacing = lerpDouble(1.0, -0.2, curveValue)!;
        final text = curveValue < 0.5 ? 'Kreasi Ekraf' : 'KREASI EKRAF';

        return Material(
          color: Colors.transparent,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: letterSpacing,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Batik Lokal
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF001C39),
                  Color(0xFF004D8C),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Opacity(
            opacity: 0.35,
            child: Image.asset(
              'assets/images/splash_bg.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // Konten Tengah: Logo + Teks dengan Staggered & Breathing Animation
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo Animasi (Fade-in + Scale + Breathing) - Ukuran Lebih Besar (220x220)
                AnimatedBuilder(
                  animation: Listenable.merge([_entryController, _breathingController]),
                  builder: (context, child) {
                    final entryScale = _logoScaleAnimation.value;
                    final breathingScale =
                        _entryController.isCompleted ? _breathingAnimation.value : 1.0;
                    return Transform.scale(
                      scale: entryScale * breathingScale,
                      child: FadeTransition(
                        opacity: _logoFadeAnimation,
                        child: Hero(
                          tag: 'app_logo',
                          flightShuttleBuilder: _logoFlightShuttleBuilder,
                          child: SizedBox(
                            width: 220,
                            height: 220,
                            child: Image.asset(
                              'assets/images/logo_dispopar_symbol.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),

                // Teks Animasi (Fade-in + Slide dari bawah)
                SlideTransition(
                  position: _textSlideAnimation,
                  child: FadeTransition(
                    opacity: _textFadeAnimation,
                    child: Hero(
                      tag: 'app_title',
                      flightShuttleBuilder: _titleFlightShuttleBuilder,
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          'Kreasi Ekraf',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.0,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
