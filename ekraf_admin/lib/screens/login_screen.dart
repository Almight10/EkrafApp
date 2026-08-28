import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'main_shell.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool showSplash;
  final bool isInitialLaunch;

  const LoginScreen({
    super.key,
    this.showSplash = false,
    this.isInitialLaunch = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _hasEmailText = false;
  String _appVersion = '1.0.0';

  // Animasi Card Slide-Up dari bawah (B.5)
  late AnimationController _cardController;
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _cardFadeAnimation;

  // Interaktif Drag Atas-Bawah dengan Elastic Spring Physics
  double _dragOffsetY = 0.0;
  late AnimationController _springController;
  late Animation<double> _springAnimation;

  // Animasi Pulsing Accent Dot pada judul
  late AnimationController _dotPulseController;
  late Animation<double> _dotScaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();

    // 1. Card Slide-up Controller
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      value: widget.isInitialLaunch ? 0.0 : 1.0,
    );

    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.45),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _cardController,
        curve: Curves.easeOutQuart,
      ),
    );

    _cardFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _cardController,
        curve: const Interval(0.10, 1.0, curve: Curves.easeOut),
      ),
    );

    // 2. Spring Physics Controller saat dilepas
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _springAnimation = const AlwaysStoppedAnimation(0.0);

    // 2. Dot Pulse Controller (Subtle interactive breathing on accent period)
    _dotPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _dotScaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _dotPulseController, curve: Curves.easeInOut),
    );

    // 3. Focus Listeners for micro-interactions
    _emailFocusNode.addListener(() {
      setState(() => _isEmailFocused = _emailFocusNode.hasFocus);
    });

    _passwordFocusNode.addListener(() {
      setState(() => _isPasswordFocused = _passwordFocusNode.hasFocus);
    });

    _emailController.addListener(() {
      final hasText = _emailController.text.isNotEmpty;
      if (hasText != _hasEmailText) {
        setState(() => _hasEmailText = hasText);
      }
    });

    if (widget.isInitialLaunch) {
      _cardController.forward();
    }
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = info.version;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _cardController.dispose();
    _springController.dispose();
    _dotPulseController.dispose();
    super.dispose();
  }

  void _onCardVerticalDragUpdate(DragUpdateDetails details) {
    if (_springController.isAnimating) {
      _springController.stop();
    }
    setState(() {
      _dragOffsetY += details.primaryDelta! * 0.70;
      // Batasi tarikan ke atas maksimal -80px dan ke bawah maksimal 260px
      if (_dragOffsetY < -70.0) _dragOffsetY = -70.0;
      if (_dragOffsetY > 260.0) _dragOffsetY = 260.0;
    });
  }

  void _onCardVerticalDragEnd(DragEndDetails details) {
    final startOffset = _dragOffsetY;
    _springAnimation = Tween<double>(begin: startOffset, end: 0.0).animate(
      CurvedAnimation(
        parent: _springController,
        curve: Curves.easeOutBack,
      ),
    )..addListener(() {
        setState(() {
          _dragOffsetY = _springAnimation.value;
        });
      });

    _springController.forward(from: 0.0);
  }

  Future<void> _handleLogin() async {
    // Unfocus keyboard before login
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainShell(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      } else {
        final errMsg = authProvider.errorMessage ?? 'Email atau password tidak sesuai.';

        // Jangan tampilkan snackbar jika error karena koneksi
        final lowerMsg = errMsg.toLowerCase();
        if (lowerMsg.contains('socketexception') ||
            lowerMsg.contains('clientexception') ||
            lowerMsg.contains('host lookup') ||
            lowerMsg.contains('koneksi internet bermasalah')) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    errMsg,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  // Flight shuttle builder untuk logo Hero
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
    final safeAreaTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Batik Lokal dengan overlay gradien premium
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

          // 2. Konten Login dengan Header Hero dan Card Slide Up
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Header Login dengan Hero (Logo di kiri, Teks di kanan)
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, safeAreaTop + 12, 20, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Hero Logo (80x80)
                              Hero(
                                tag: 'app_logo',
                                flightShuttleBuilder: _logoFlightShuttleBuilder,
                                child: SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: Image.asset(
                                    'assets/images/logo_dispopar_symbol.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              // Hero Text ('KREASI EKRAF')
                              Hero(
                                tag: 'app_title',
                                flightShuttleBuilder: _titleFlightShuttleBuilder,
                                child: Material(
                                  color: Colors.transparent,
                                  child: Text(
                                    'KREASI EKRAF',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // 3. Form Login Card Interaktif (Mendukung Gerak Tarik Atas & Bawah dengan Elastic Spring)
                        SlideTransition(
                          position: _cardSlideAnimation,
                          child: FadeTransition(
                            opacity: _cardFadeAnimation,
                            child: Transform.translate(
                              offset: Offset(0, _dragOffsetY),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.97),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(36),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF001C39).withValues(alpha: 0.18),
                                      blurRadius: 30,
                                      offset: const Offset(0, -10),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 10,
                                      offset: const Offset(0, -3),
                                    ),
                                  ],
                                  border: const Border(
                                    top: BorderSide(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Decorative Interactive Drag Handle (Area Sentuh Tarik Atas-Bawah)
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onVerticalDragUpdate: _onCardVerticalDragUpdate,
                                        onVerticalDragEnd: _onCardVerticalDragEnd,
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.only(top: 4, bottom: 18),
                                          child: Center(
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 150),
                                              width: _dragOffsetY.abs() > 8 ? 58 : 44,
                                              height: 5,
                                              decoration: BoxDecoration(
                                                color: _dragOffsetY.abs() > 8
                                                    ? const Color(0xFF003665).withValues(alpha: 0.5)
                                                    : const Color(0xFFC2C6D2).withValues(alpha: 0.8),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                    // Welcome Title with Animated Accent Dot
                                    Text(
                                      'Selamat',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF003665),
                                        height: 1.1,
                                        letterSpacing: -1.0,
                                      ),
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          'Datang',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF003665),
                                            height: 1.1,
                                            letterSpacing: -1.0,
                                          ),
                                        ),
                                        ScaleTransition(
                                          scale: _dotScaleAnimation,
                                          child: Text(
                                            '.',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 36,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFFFC9910),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Description
                                    Text(
                                      'Silakan masuk untuk melanjutkan ke platform ekonomi kreatif Kota Probolinggo.',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: const Color(0xFF424750),
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // ── Email Input Field (Interactive Glow & Focus Feedback) ──
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      decoration: BoxDecoration(
                                        color: _isEmailFocused
                                            ? Colors.white
                                            : const Color(0xFFF4F6F9),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: _isEmailFocused
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xFF003665).withValues(alpha: 0.10),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: TextFormField(
                                        controller: _emailController,
                                        focusNode: _emailFocusNode,
                                        keyboardType: TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Alamat Email',
                                          hintStyle: GoogleFonts.inter(
                                            color: const Color(0xFF8C9199),
                                            fontSize: 14,
                                          ),
                                          prefixIcon: AnimatedScale(
                                            scale: _isEmailFocused ? 1.12 : 1.0,
                                            duration: const Duration(milliseconds: 200),
                                            child: Icon(
                                              Icons.mail_outline_rounded,
                                              color: _isEmailFocused
                                                  ? const Color(0xFF003665)
                                                  : const Color(0xFF727781),
                                            ),
                                          ),
                                          suffixIcon: _hasEmailText && _isEmailFocused
                                              ? IconButton(
                                                  icon: const Icon(
                                                    Icons.cancel_rounded,
                                                    color: Color(0xFF8C9199),
                                                    size: 18,
                                                  ),
                                                  onPressed: () {
                                                    _emailController.clear();
                                                  },
                                                )
                                              : null,
                                          filled: false,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide(
                                              color: _isEmailFocused
                                                  ? const Color(0xFF003665)
                                                  : const Color(0xFFE2E6EC),
                                              width: _isEmailFocused ? 1.8 : 1.0,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE2E6EC),
                                              width: 1.0,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF003665),
                                              width: 2.0,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: const BorderSide(
                                              color: AppColors.error,
                                              width: 1.5,
                                            ),
                                          ),
                                          focusedErrorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: const BorderSide(
                                              color: AppColors.error,
                                              width: 2.0,
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
                                          if (!v.contains('@')) return 'Format email tidak valid';
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 14),

                                    // ── Password Input Field (Interactive Glow & Focus Feedback) ──
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      decoration: BoxDecoration(
                                        color: _isPasswordFocused
                                            ? Colors.white
                                            : const Color(0xFFF4F6F9),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: _isPasswordFocused
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xFF003665).withValues(alpha: 0.10),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: TextFormField(
                                        controller: _passwordController,
                                        focusNode: _passwordFocusNode,
                                        obscureText: _obscurePassword,
                                        textInputAction: TextInputAction.done,
                                        onFieldSubmitted: (_) => _handleLogin(),
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Kata Sandi',
                                          hintStyle: GoogleFonts.inter(
                                            color: const Color(0xFF8C9199),
                                            fontSize: 14,
                                          ),
                                          prefixIcon: AnimatedScale(
                                            scale: _isPasswordFocused ? 1.12 : 1.0,
                                            duration: const Duration(milliseconds: 200),
                                            child: Icon(
                                              Icons.lock_open_rounded,
                                              color: _isPasswordFocused
                                                  ? const Color(0xFF003665)
                                                  : const Color(0xFF727781),
                                            ),
                                          ),
                                          suffixIcon: IconButton(
                                            splashRadius: 20,
                                            icon: AnimatedSwitcher(
                                              duration: const Duration(milliseconds: 250),
                                              transitionBuilder: (child, anim) =>
                                                  ScaleTransition(scale: anim, child: child),
                                              child: Icon(
                                                _obscurePassword
                                                    ? Icons.visibility_outlined
                                                    : Icons.visibility_off_outlined,
                                                key: ValueKey(_obscurePassword),
                                                color: _isPasswordFocused
                                                    ? const Color(0xFF003665)
                                                    : const Color(0xFF727781),
                                              ),
                                            ),
                                            onPressed: () => setState(
                                                () => _obscurePassword = !_obscurePassword),
                                          ),
                                          filled: false,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide(
                                              color: _isPasswordFocused
                                                  ? const Color(0xFF003665)
                                                  : const Color(0xFFE2E6EC),
                                              width: _isPasswordFocused ? 1.8 : 1.0,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE2E6EC),
                                              width: 1.0,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF003665),
                                              width: 2.0,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: const BorderSide(
                                              color: AppColors.error,
                                              width: 1.5,
                                            ),
                                          ),
                                          focusedErrorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: const BorderSide(
                                              color: AppColors.error,
                                              width: 2.0,
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
                                          if (v.length < 6) return 'Password minimal 6 karakter';
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Forgot Password Link with Touch Feedback
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: _InteractiveLink(
                                        label: 'Lupa Password?',
                                        color: const Color(0xFF003665),
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => const ForgotPasswordScreen()),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Masuk Button (Neo-Brutalist with Tactile Elevation)
                                    _MasukButton(
                                      isLoading: _isLoading,
                                      onTap: _handleLogin,
                                    ),
                                    const SizedBox(height: 24),

                                    // Divider & Register Link
                                    const Divider(height: 1, color: Color(0x22C2C6D2)),
                                    const SizedBox(height: 18),
                                    Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Belum punya akun Pelaku? ',
                                            style: GoogleFonts.inter(
                                              color: const Color(0xFF424750),
                                              fontSize: 14,
                                            ),
                                          ),
                                          _InteractiveLink(
                                            label: 'Daftar Disini',
                                            color: const Color(0xFF003665),
                                            isUnderlined: true,
                                            isBold: true,
                                            onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) => const RegisterScreen()),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Footer Links
                                    Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Bantuan',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: const Color(0xFF727781),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            width: 4,
                                            height: 4,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFFC2C6D2),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Syarat & Ketentuan',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: const Color(0xFF727781),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Center(
                                      child: Text(
                                        '© 2026 DISPOPAR Kota Probolinggo • v$_appVersion',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: const Color(0xFF727781),
                                        ),
                                      ),
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
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Interactive Link with Touch Feedback ────────────────────────────────────────
class _InteractiveLink extends StatefulWidget {
  final String label;
  final Color color;
  final bool isUnderlined;
  final bool isBold;
  final VoidCallback onTap;

  const _InteractiveLink({
    required this.label,
    required this.color,
    this.isUnderlined = false,
    this.isBold = false,
    required this.onTap,
  });

  @override
  State<_InteractiveLink> createState() => _InteractiveLinkState();
}

class _InteractiveLinkState extends State<_InteractiveLink> {
  bool _isDown = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isDown = true),
      onTapUp: (_) {
        setState(() => _isDown = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isDown = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: _isDown ? 0.5 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: widget.color,
              fontWeight: widget.isBold ? FontWeight.bold : FontWeight.w600,
              decoration: widget.isUnderlined ? TextDecoration.underline : TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Interactive Neo-Brutalist Masuk Button ──────────────────────────────────────
class _MasukButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback? onTap;

  const _MasukButton({required this.isLoading, this.onTap});

  @override
  State<_MasukButton> createState() => _MasukButtonState();
}

class _MasukButtonState extends State<_MasukButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isLoading) setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (!widget.isLoading) {
          setState(() => _isPressed = false);
          if (widget.onTap != null) widget.onTap!();
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        transform: Matrix4.translationValues(
          _isPressed ? 2.0 : 0.0,
          _isPressed ? 2.0 : 0.0,
          0.0,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF003665),
              Color(0xFF004D8C),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(28),
            bottomRight: Radius.circular(14),
            bottomLeft: Radius.circular(28),
          ),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF003665).withValues(alpha: 0.35),
                    offset: const Offset(4, 4),
                    blurRadius: 8,
                  ),
                ],
        ),
        alignment: Alignment.center,
        height: 54,
        child: widget.isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Masuk',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
      ),
    );
  }
}
