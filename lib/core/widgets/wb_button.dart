import 'package:flutter/material.dart';

import '../theme/wb_theme_exports.dart';
import 'wb_icon.dart';

enum WBButtonVariant { primary, secondary, ghost, danger }

enum WBButtonSize { sm, md, lg }

/// Pill-radius CTA used across the app. Defaults to a full-width primary
/// button, the most common pattern in the design.
class WBButton extends StatefulWidget {
  const WBButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = WBButtonVariant.primary,
    this.size = WBButtonSize.md,
    this.icon,
    this.trailingIcon,
    this.trailing,
    this.leading,
    this.fullWidth = false,
    this.disabled = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final WBButtonVariant variant;
  final WBButtonSize size;
  final WBIconName? icon;
  final WBIconName? trailingIcon;
  final Widget? trailing;
  final Widget? leading;
  final bool fullWidth;
  final bool disabled;

  /// When true the button shows a centred spinner and ignores taps —
  /// used while an async action (API call) is in flight.
  final bool loading;

  @override
  State<WBButton> createState() => _WBButtonState();
}

class _WBButtonState extends State<WBButton> {
  bool _pressed = false;

  ({double height, double px, double fs}) get _sizeSpec {
    switch (widget.size) {
      case WBButtonSize.sm:
        return (height: 40, px: 16, fs: 14);
      case WBButtonSize.md:
        return (height: 52, px: 24, fs: 16);
      case WBButtonSize.lg:
        return (height: 56, px: 28, fs: 16);
    }
  }

  ({Color bg, Color fg}) get _variantSpec {
    if (widget.disabled) {
      return (bg: WBColors.bgSoft, fg: WBColors.fgDisabled);
    }
    switch (widget.variant) {
      case WBButtonVariant.primary:
        return (bg: WBColors.surfaceDark, fg: Colors.white);
      case WBButtonVariant.secondary:
        return (bg: WBColors.bgSoft, fg: WBColors.fgHeader);
      case WBButtonVariant.ghost:
        return (bg: Colors.transparent, fg: WBColors.fgHeader);
      case WBButtonVariant.danger:
        return (bg: WBColors.statusError, fg: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _sizeSpec;
    final v = _variantSpec;
    final disabled =
        widget.disabled || widget.loading || widget.onPressed == null;

    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapCancel: disabled ? null : () => setState(() => _pressed = false),
      onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
      onTap: disabled ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: WBMotion.fast,
        curve: WBMotion.easeSoft,
        child: AnimatedContainer(
          duration: WBMotion.base,
          curve: WBMotion.easeSoft,
          height: s.height,
          width: widget.fullWidth ? double.infinity : null,
          padding: EdgeInsets.symmetric(horizontal: s.px),
          decoration: BoxDecoration(
            color: v.bg,
            borderRadius: BorderRadius.circular(WBRadius.pill),
          ),
          child: widget.loading
              ? Center(
                  child: SizedBox(
                    width: s.fs + 4,
                    height: s.fs + 4,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation(v.fg),
                    ),
                  ),
                )
              : Row(
            mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: widget.trailing == null
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                const SizedBox(width: 8),
              ] else if (widget.icon != null) ...[
                WBIcon(widget.icon!, size: 18, color: v.fg),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  style: WBTypography.button.copyWith(
                    color: v.fg,
                    fontSize: s.fs,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.trailingIcon != null) ...[
                const SizedBox(width: 8),
                WBIcon(widget.trailingIcon!, size: 18, color: v.fg),
              ],
              if (widget.trailing != null) widget.trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
