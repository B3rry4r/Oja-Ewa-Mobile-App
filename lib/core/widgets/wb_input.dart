import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/wb_theme_exports.dart';
import 'wb_icon.dart';

/// Filled, pill-cornered input. Matches the 52px height + 16px radius +
/// soft fill spec, with the `D4D4D4` hairline border applied once filled or
/// focused (no harsh black border, per the design-system update).
class WBInput extends StatefulWidget {
  const WBInput({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.leadingIcon,
    this.trailing,
    this.obscureText = false,
    this.keyboardType,
    this.helper,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.initialValue,
    this.maxLength,
    this.inputFormatters,
    this.enabled = true,
  });

  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final WBIconName? leadingIcon;
  final Widget? trailing;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? helper;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final String? initialValue;

  /// Hard character cap (e.g. NIN/BVN = 11). The counter is hidden.
  final int? maxLength;

  /// Keystroke filters — e.g. `FilteringTextInputFormatter.digitsOnly`.
  final List<TextInputFormatter>? inputFormatters;

  /// When false the field is read-only (used by tappable picker fields).
  final bool enabled;

  @override
  State<WBInput> createState() => _WBInputState();
}

class _WBInputState extends State<WBInput> {
  late final TextEditingController _controller;
  late final FocusNode _focus;
  bool _focused = false;
  bool get _filled => _controller.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        TextEditingController(text: widget.initialValue ?? '');
    _focus = FocusNode()..addListener(_onFocus);
    _controller.addListener(_onTextChanged);
  }

  void _onFocus() => setState(() => _focused = _focus.hasFocus);
  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _focus.dispose();
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final showBorder = _filled || _focused || hasError;
    final borderColor = hasError
        ? WBColors.statusError
        : (showBorder ? WBColors.borderFilled : Colors.transparent);
    final bgColor = _filled || _focused ? WBColors.bgPrimary : WBColors.surfaceInput;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: WBTypography.caption.copyWith(
              color: WBColors.fgSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
        ],
        AnimatedContainer(
          duration: WBMotion.base,
          curve: WBMotion.easeSoft,
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(WBRadius.input),
          ),
          child: Row(
            children: [
              if (widget.leadingIcon != null) ...[
                WBIcon(
                  widget.leadingIcon!,
                  size: 20,
                  color: _filled ? WBColors.fgHeader : WBColors.fgPlaceholder,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  autofocus: widget.autofocus,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  enabled: widget.enabled,
                  maxLength: widget.maxLength,
                  inputFormatters: widget.inputFormatters,
                  buildCounter: (_,
                          {required currentLength,
                          required isFocused,
                          maxLength}) =>
                      null,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  cursorColor: WBColors.fgHeader,
                  style: WBTypography.body.copyWith(color: WBColors.fgHeader),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    hintText: widget.placeholder,
                    hintStyle: WBTypography.body.copyWith(
                      color: WBColors.fgPlaceholder,
                    ),
                  ),
                ),
              ),
              if (widget.trailing != null) ...[
                const SizedBox(width: 8),
                widget.trailing!,
              ],
            ],
          ),
        ),
        if (widget.helper != null || hasError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              widget.errorText ?? widget.helper!,
              style: WBTypography.caption.copyWith(
                color: hasError ? WBColors.statusError : WBColors.fgPlaceholder,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
