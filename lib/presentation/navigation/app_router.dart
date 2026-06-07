import 'package:go_router/go_router.dart';

import 'package:shapeup/features/splash/presentation/splash_screen.dart';
import 'package:shapeup/features/auth/presentation/login_screen.dart';
import 'package:shapeup/features/auth/presentation/register_screen.dart';
import 'package:shapeup/features/auth/presentation/otp_screen.dart';
import 'package:shapeup/features/onboarding/presentation/onboarding_screen.dart';
import 'package:shapeup/features/home/presentation/home_screen.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/otp', builder: (_, __) => const OtpScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    ],
  );
}
