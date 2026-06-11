/// All route paths in one place. Never hardcode route strings.
///
/// Usage: context.go(AppRoutes.home)
abstract final class AppRoutes {
  AppRoutes._();

  // ─── Root ──────────────────────────────────────────────────────
  static const String splash = '/';

  // ─── Auth ──────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String onboarding = '/auth/onboarding';

  // ─── Main ──────────────────────────────────────────────────────
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // ─── Helpers ───────────────────────────────────────────────────
  /// Build a dynamic path with parameters
  /// e.g. AppRoutes.buildPath(AppRoutes.home, 'detail/123')
  static String buildPath(String base, String child) => '$base/$child';
}
