import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ─── Context Extensions ───────────────────────────────────────────

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }

  Future<T?> showAppBottomSheet<T>(Widget child) {
    return showModalBottomSheet<T>(
      context: this,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(this).viewInsets.bottom,
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─── String Extensions ─────────────────────────────────────────────

extension StringX on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';

  String get titleCase => split(' ').map((word) => word.capitalize).join(' ');

  bool get isValidEmail =>
      RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(trim());

  bool get isValidUrl {
    final uri = Uri.tryParse(trim());
    return uri != null && uri.isAbsolute;
  }

  String truncate(int maxLength, {String suffix = '...'}) =>
      length <= maxLength ? this : '${substring(0, maxLength - suffix.length)}$suffix';

  String? get nullIfEmpty => trim().isEmpty ? null : this;
}

extension NullableStringX on String? {
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;
  String get orEmpty => this ?? '';
}

// ─── DateTime Extensions ───────────────────────────────────────────

extension DateTimeX on DateTime {
  String get formatted => DateFormat('MMM dd, yyyy').format(this);
  String get formattedWithTime =>
      DateFormat('MMM dd, yyyy · HH:mm').format(this);
  String get timeOnly => DateFormat('HH:mm').format(this);
  String get dayMonthYear => DateFormat('dd/MM/yyyy').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  String get relative {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }
}

// ─── Num Extensions ────────────────────────────────────────────────

extension NumX on num {
  SizedBox get verticalSpace => SizedBox(height: toDouble());
  SizedBox get horizontalSpace => SizedBox(width: toDouble());

  EdgeInsets get allPadding => EdgeInsets.all(toDouble());
  EdgeInsets get horizontalPadding =>
      EdgeInsets.symmetric(horizontal: toDouble());
  EdgeInsets get verticalPadding => EdgeInsets.symmetric(vertical: toDouble());

  String get formatted => NumberFormat('#,###').format(this);
  String get formattedDecimal => NumberFormat('#,###.##').format(this);
  String get asCurrency => NumberFormat.currency(symbol: '\$').format(this);
}

// ─── List Extensions ───────────────────────────────────────────────

extension ListX<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;

  List<T> separated(T separator) {
    if (length <= 1) return this;
    return [
      for (int i = 0; i < length; i++) ...[
        this[i],
        if (i < length - 1) separator,
      ],
    ];
  }
}

// ─── Widget Extensions ─────────────────────────────────────────────

extension WidgetX on Widget {
  Widget get expanded => Expanded(child: this);
  Widget get flexible => Flexible(child: this);
  Widget get centered => Center(child: this);

  Widget padAll(double value) => Padding(
        padding: EdgeInsets.all(value),
        child: this,
      );

  Widget padSymmetric({double h = 0, double v = 0}) => Padding(
        padding: EdgeInsets.symmetric(horizontal: h, vertical: v),
        child: this,
      );

  Widget padOnly({double l = 0, double r = 0, double t = 0, double b = 0}) =>
      Padding(
        padding: EdgeInsets.only(left: l, right: r, top: t, bottom: b),
        child: this,
      );
}
