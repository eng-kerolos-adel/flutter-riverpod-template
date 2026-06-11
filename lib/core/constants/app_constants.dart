/// Central place for all app-wide constants.
/// Never hardcode strings or values anywhere else — put them here.
abstract final class AppConstants {
  AppConstants._();

  // ─── App Info ──────────────────────────────────────────────────
  static const String appName = 'Flutter Template';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // ─── API ───────────────────────────────────────────────────────
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.yourapp.com/v1',
  );
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ─── Pagination ─────────────────────────────────────────────────
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ─── Storage Keys ───────────────────────────────────────────────
  static const String themeKey = 'theme_mode';
  static const String localeKey = 'app_locale';
  static const String onboardingKey = 'onboarding_done';
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'current_user';

  // ─── Supported Locales ──────────────────────────────────────────
  static const List<String> supportedLocales = ['en', 'ar'];
  static const String defaultLocale = 'en';

  // ─── Cache Durations ────────────────────────────────────────────
  static const Duration shortCache = Duration(minutes: 5);
  static const Duration mediumCache = Duration(hours: 1);
  static const Duration longCache = Duration(hours: 24);

  // ─── Timeouts & Delays ─────────────────────────────────────────
  static const Duration splashDelay = Duration(seconds: 2);
  static const Duration debounceDelay = Duration(milliseconds: 500);
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ─── Validation ─────────────────────────────────────────────────
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 32;
  static const int otpLength = 6;

  // ─── Firebase Collections ───────────────────────────────────────
  static const String usersCollection = 'users';
  static const String postsCollection = 'posts';
  static const String notificationsCollection = 'notifications';
}
