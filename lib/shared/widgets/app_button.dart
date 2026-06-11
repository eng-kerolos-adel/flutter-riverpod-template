import 'package:flutter/material.dart';

/// Opinionated button component.
/// Use AppButton for primary actions, AppButton.outlined for secondary.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.type = _ButtonType.filled,
    this.size = AppButtonSize.large,
    this.fullWidth = true,
  });

  const AppButton.outlined({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    Widget? icon,
    AppButtonSize size = AppButtonSize.large,
    bool fullWidth = true,
  }) : this(
          key: key,
          label: label,
          onPressed: onPressed,
          isLoading: isLoading,
          icon: icon,
          type: _ButtonType.outlined,
          size: size,
          fullWidth: fullWidth,
        );

  const AppButton.text({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    Widget? icon,
  }) : this(
          key: key,
          label: label,
          onPressed: onPressed,
          isLoading: isLoading,
          icon: icon,
          type: _ButtonType.text,
          fullWidth: false,
        );

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final _ButtonType type;
  final AppButtonSize size;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon!,
                  const SizedBox(width: 8),
                  Text(label),
                ],
              )
            : Text(label);

    final minSize = switch (size) {
      AppButtonSize.small => const Size(0, 36),
      AppButtonSize.medium => const Size(0, 44),
      AppButtonSize.large => const Size(double.infinity, 52),
    };

    final effectiveSize = fullWidth ? minSize : Size(0, minSize.height);

    return switch (type) {
      _ButtonType.filled => FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(minimumSize: effectiveSize),
          child: child,
        ),
      _ButtonType.outlined => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(minimumSize: effectiveSize),
          child: child,
        ),
      _ButtonType.text => TextButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
    };
  }
}

enum _ButtonType { filled, outlined, text }

enum AppButtonSize { small, medium, large }
