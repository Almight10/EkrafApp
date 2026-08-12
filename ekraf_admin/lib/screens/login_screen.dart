import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'main_shell.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Animasi Transisi dari Splash ke Login
  late AnimationController _transitionController;
  bool _isSplashActive = true;

  @override
  void initState() {
    super.initState();
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Dihapus listener setState(() {}) untuk mencegah rebuild seluruh pohon widget di setiap frame,
    // kita menggantinya dengan AnimatedBuilder agar animasi berjalan sangat mulus (60fps).

    _checkSessionAndAnimate();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  Future<void> _checkSessionAndAnimate() async {
    final startTime = DateTime.now();

    // 1. Cek sesi login aktif via AuthProvider
    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = await authProvider.checkSession();

    if (isLoggedIn) {
      if (mounted) {
        // Jika sudah login, langsung pindah ke MainShell tanpa animasi login
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainShell(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
      return;
    }

    // 2. Hitung sisa waktu agar total tampilan splash = 3.5 detik (sesuai permintaan agak dilamain)
    final elapsed = DateTime.now().difference(startTime);
    final remaining = const Duration(milliseconds: 3500) - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }

    if (mounted) {
      setState(() {
        _isSplashActive = false;
      });
      // Jalankan animasi transisi pergeseran elemen
      _transitionController.forward();
    }
  }

  Future<void> _handleLogin() async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errMsg,
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final safeAreaTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Batik Lokal dengan overlay gradien premium (Pemuatan instan, bebas lag)
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

          // 2. AnimatedBuilder untuk memperbarui koordinat posisi & tinggi header secara halus
          AnimatedBuilder(
            animation: _transitionController,
            builder: (context, child) {
              final curve = CurvedAnimation(
                parent: _transitionController,
                curve: Curves.fastOutSlowIn,
              );
              final val = curve.value;

              // --- Interpolasi Koordinat Logo ---
              final logoSize = lerpDouble(200.0, 80.0, val)!;
              final logoSplashLeft = (screenWidth - 200.0) / 2;
              final logoSplashTop = (screenHeight - 200.0) / 2 - 50.0;
              final logoLeft = lerpDouble(logoSplashLeft, 16.0, val)!;
              final logoTop = lerpDouble(logoSplashTop, safeAreaTop + 16.0, val)!;

              // --- Interpolasi Koordinat Teks/Badge ---
              final textWidth = lerpDouble(240.0, 150.0, val)!;
              final textHeight = lerpDouble(44.0, 32.0, val)!;
              final textSplashLeft = (screenWidth - 240.0) / 2;
              final textSplashTop = logoSplashTop + 200.0 + 8.0;
              final textLeft = lerpDouble(textSplashLeft, screenWidth - 16.0 - 150.0, val)!;
              final textTop = lerpDouble(textSplashTop, safeAreaTop + 16.0 + (80.0 - 32.0) / 2, val)!;

              // Tinggi Header yang menyesuaikan fase animasi (sedikit lebih tinggi karena logo 80x80)
              final headerHeight = lerpDouble(screenHeight, safeAreaTop + 112.0, val)!;

              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: val < 0.99
                        ? const NeverScrollableScrollPhysics()
                        : const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Dynamic Header (SizedBox untuk efisiensi performa)
                            SizedBox(
                              width: double.infinity,
                              height: headerHeight,
                              child: val < 1.0
                                  ? Stack(
                                      children: [
                                        // Animated Logo (Tanpa background putih/padding dan ukuran diperbesar)
                                        Positioned(
                                          left: logoLeft,
                                          top: logoTop,
                                          child: SizedBox(
                                            width: logoSize,
                                            height: logoSize,
                                            child: Image.asset(
                                              'assets/images/logo_dispopar_symbol.png',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                        // Animated Text / Badge (Tanpa background putih/padding)
                                        Positioned(
                                          left: textLeft,
                                          top: textTop,
                                          child: SizedBox(
                                            width: textWidth,
                                            height: textHeight,
                                            child: Align(
                                              alignment: Alignment(val, 0.0),
                                              child: Text(
                                                val < 0.5 ? 'Kreasi Ekraf' : 'KREASI EKRAF',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: lerpDouble(28.0, 16.0, val)!,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white, // Teks selalu putih di atas gradien/batik
                                                  letterSpacing: lerpDouble(2.0, -0.2, val)!,
                                                  shadows: val < 0.5
                                                      ? [
                                                          Shadow(
                                                            color: Colors.black.withValues(alpha: 0.4 * (1.0 - val)),
                                                            blurRadius: 12,
                                                            offset: const Offset(0, 4),
                                                          ),
                                                        ]
                                                      : [],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(
                                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                                      child: SafeArea(
                                        bottom: false,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            // Original Logo (Tanpa background putih/padding, uncropped)
                                            SizedBox(
                                              width: 80,
                                              height: 80,
                                              child: Image.asset(
                                                'assets/images/logo_dispopar_symbol.png',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            // Original Badge (Tanpa background putih/padding)
                                            Text(
                                              'KREASI EKRAF',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: -0.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ),
                            
                            // 3. Form Login (Exact Original Layout & Behavior)
                            // Dibungkus RepaintBoundary untuk meng-cache tampilan form input selama animasi meluncur naik
                            Opacity(
                              opacity: val,
                              child: RepaintBoundary(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.96),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(40),
                                    ),
                                    border: const Border(
                                      top: BorderSide(
                                        color: Colors.white,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Decorative Handle
                                        Center(
                                          child: Container(
                                            margin: const EdgeInsets.only(bottom: 24),
                                            width: 48,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFC2C6D2).withValues(alpha: 0.5),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                        // Welcome Title
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
                                            Text(
                                              '.',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 36,
                                                fontWeight: FontWeight.w800,
                                                color: const Color(0xFFFC9910),
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
                                        const SizedBox(height: 28),
                                        // Email Input
                                        TextFormField(
                                          controller: _emailController,
                                          keyboardType: TextInputType.emailAddress,
                                          textInputAction: TextInputAction.next,
                                          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                                          decoration: InputDecoration(
                                            hintText: 'Alamat Email',
                                            prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFF727781)),
                                            filled: true,
                                            fillColor: const Color(0xFFF2F4F6).withValues(alpha: 0.5),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: const BorderSide(color: Color(0xFF003665), width: 2),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                          ),
                                          validator: (v) {
                                            if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
                                            if (!v.contains('@')) return 'Format email tidak valid';
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 14),
                                        // Password Input
                                        TextFormField(
                                          controller: _passwordController,
                                          obscureText: _obscurePassword,
                                          textInputAction: TextInputAction.done,
                                          onFieldSubmitted: (_) => _handleLogin(),
                                          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                                          decoration: InputDecoration(
                                            hintText: 'Kata Sandi',
                                            prefixIcon: const Icon(Icons.lock_open_rounded, color: Color(0xFF727781)),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons.visibility_outlined
                                                    : Icons.visibility_off_outlined,
                                                color: const Color(0xFF727781),
                                              ),
                                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFF2F4F6).withValues(alpha: 0.5),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: const BorderSide(color: Color(0xFF003665), width: 2),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                          ),
                                          validator: (v) {
                                            if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
                                            if (v.length < 6) return 'Password minimal 6 karakter';
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        // Forgot Password
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: GestureDetector(
                                            onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 6),
                                              child: Text(
                                                'Lupa Password?',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  color: const Color(0xFF003665),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                        // Masuk Button
                                        _MasukButton(
                                          isLoading: _isLoading,
                                          onTap: _handleLogin,
                                        ),
                                        const SizedBox(height: 24),
                                        // Divider & Register Link
                                        const Divider(height: 1, color: Color(0x33C2C6D2)),
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
                                              GestureDetector(
                                                onTap: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                                ),
                                                child: Text(
                                                  'Daftar Disini',
                                                  style: GoogleFonts.inter(
                                                    color: const Color(0xFF003665),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    decoration: TextDecoration.underline,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 28),
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
                                              Container(width: 4, height: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFC2C6D2))),
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
                                            '© 2026 DISPOPAR Kota Probolinggo',
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
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // 3. Loading Spinner pada saat mode Splash Screen pertama aktif
          if (_isSplashActive)
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            ),
        ],
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
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (widget.onTap != null) widget.onTap!();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(
          _isPressed ? 2.0 : 0.0,
          _isPressed ? 2.0 : 0.0,
          0.0,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF003665),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(12),
            bottomLeft: Radius.circular(24),
          ),
          boxShadow: _isPressed
              ? []
              : [
                  const BoxShadow(
                    color: Color(0x33003665),
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
        ),
        alignment: Alignment.center,
        height: 54,
        child: widget.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
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
