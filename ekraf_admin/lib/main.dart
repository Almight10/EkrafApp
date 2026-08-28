import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import 'theme/app_theme.dart';
import 'providers/ekraf_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/reset_password_screen.dart';
import 'widgets/no_internet_banner.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const EkrafAdminApp());
}

class EkrafAdminApp extends StatefulWidget {
  const EkrafAdminApp({super.key});

  @override
  State<EkrafAdminApp> createState() => _EkrafAdminAppState();
}

class _EkrafAdminAppState extends State<EkrafAdminApp> {
  late final StreamSubscription<AuthState> _authSubscription;
  final _authProvider = AuthProvider();
  final _ekrafProvider = EkrafProvider();

  @override
  void initState() {
    super.initState();
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      debugPrint('[AUTH] Supabase AuthChangeEvent: $event');
      if (event == AuthChangeEvent.passwordRecovery) {
        debugPrint('[AUTH] Password recovery detected -> Opening ResetPasswordScreen');
        _authProvider.setPasswordRecovery(true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const ResetPasswordScreen(),
            ),
            (route) => false,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _ekrafProvider),
        ChangeNotifierProvider.value(value: _authProvider),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Kreasi Ekraf',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        builder: (context, child) {
          return NoInternetBanner(child: child!);
        },
        home: const SplashScreen(),
      ),
    );
  }
}
