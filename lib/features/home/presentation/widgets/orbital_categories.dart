import 'dart:math';

import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ojaewa/core/theme/wb_theme_exports.dart';

/// A single beauty category fed to [OrbitalCategorySelector].
class OrbitalCategory {
  const OrbitalCategory({
    required this.id,
    required this.label,
    required this.iconAsset,
    required this.onTap,
  });

  final String id;
  final String label;
  final String iconAsset;
  final VoidCallback onTap;
}

/// Circular "orbital" category selector — a port of WAWUBasket's feature-flagged
/// design, adapted to this app's theme tokens (WBColors / WBTypography /
/// WBShadows / WBMotion) and the WAWUBeauty raster category artwork.
///
/// Behaviour:
///   • Horizontal drag spins the ring with momentum (mobile + web).
///   • Spinning is visual-only — selection does NOT change until a node is tapped.
///   • Tapping a node selects it: the orbit snaps with a spring; the center disc
///     updates and the category's [OrbitalCategory.onTap] navigation fires.
///   • All nodes except the selected one stay in the orbit; the selected one
///     occupies the center disc.
class OrbitalCategorySelector extends StatefulWidget {
  const OrbitalCategorySelector({super.key, required this.categories});

  final List<OrbitalCategory> categories;

  @override
  State<OrbitalCategorySelector> createState() =>
      _OrbitalCategorySelectorState();
}

class _OrbitalCategorySelectorState extends State<OrbitalCategorySelector>
    with TickerProviderStateMixin {
  double _rotation = 0.0;
  double _vel = 0.0;
  Ticker? _ticker;

  /// Index of the currently selected category in [widget.categories]; this one
  /// is shown in the center disc.
  int _selectedIdx = 0;

  /// Visual front-node index into [_orbitCats] (does NOT drive selection).
  int _spinIdx = 0;

  late final AnimationController _snapCtrl;
  Animation<double>? _snapAnim;
  CurvedAnimation? _snapCurve;

  // Tuned for a light, responsive spin (see WAWUBasket): more rotation per
  // pixel, a longer glide, and a quick settle so it never appears to "rewind".
  static const _sensitivity = 0.0110;
  static const _friction = 0.945;
  static const _stopVel = 0.0022;

  void _onSnapTick() {
    if (mounted) setState(() => _rotation = _snapAnim?.value ?? _rotation);
  }

  /// The orbit is all categories EXCEPT the currently selected one.
  List<OrbitalCategory> get _orbitCats {
    final cats = widget.categories;
    return [
      for (var i = 0; i < cats.length; i++)
        if (i != _selectedIdx) cats[i],
    ];
  }

  @override
  void initState() {
    super.initState();
    _snapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _snapAnim?.removeListener(_onSnapTick);
    _snapCurve?.dispose();
    _snapCtrl.dispose();
    super.dispose();
  }

  double _angleFor(int i, int n) => 2 * pi * i / n;

  int _nearestIdx(int n) {
    if (n == 0) return 0;
    final step = 2 * pi / n;
    final norm = ((-_rotation) % (2 * pi) + 2 * pi) % (2 * pi);
    return ((norm + step / 2) / step).floor() % n;
  }

  double _depth(int i, int n) {
    final angle = (_angleFor(i, n) + _rotation) % (2 * pi);
    return (1.0 - cos(angle)) / 2.0;
  }

  // ── Gesture handlers ───────────────────────────────────────────────────────
  // Horizontal-drag (not pan) so the parent ListView keeps its vertical scroll.

  void _onHorizontalDragUpdate(DragUpdateDetails d) {
    _ticker?.stop();
    _snapCtrl.stop();
    setState(() => _rotation += d.delta.dx * _sensitivity);
    _updateSpinIdx();
  }

  void _onHorizontalDragEnd(DragEndDetails d) {
    _vel = (d.velocity.pixelsPerSecond.dx * _sensitivity).clamp(-0.34, 0.34);
    _ticker ??= createTicker(_onTick);
    _ticker!.start();
  }

  void _onTick(Duration _) {
    _vel *= _friction;
    setState(() => _rotation += _vel);
    _updateSpinIdx();
    if (_vel.abs() < _stopVel) {
      _ticker!.stop();
      final n = _orbitCats.length;
      if (n > 0) _snapVisual(_nearestIdx(n));
    }
  }

  void _updateSpinIdx() {
    final n = _orbitCats.length;
    if (n == 0) return;
    final idx = _nearestIdx(n);
    if (idx != _spinIdx) {
      setState(() => _spinIdx = idx);
      HapticFeedback.selectionClick();
    }
  }

  /// Tap: snap + select (updates center disc + fires navigation).
  void _tapNode(int idx) {
    final orbit = _orbitCats;
    if (orbit.isEmpty || idx >= orbit.length) return;
    setState(() => _spinIdx = idx);
    _animateSnap(idx, const Duration(milliseconds: 400), spring: true);

    final selected = orbit[idx];
    final newSelectedIdx = widget.categories.indexWhere(
      (c) => c.id == selected.id,
    );
    if (newSelectedIdx >= 0 && newSelectedIdx != _selectedIdx) {
      setState(() {
        _selectedIdx = newSelectedIdx;
        _spinIdx = 0;
        _rotation = 0.0;
      });
    }
    selected.onTap();
  }

  /// Post-momentum snap: visual only, no selection change.
  void _snapVisual(int idx) {
    setState(() => _spinIdx = idx);
    _animateSnap(idx, const Duration(milliseconds: 240), spring: false);
  }

  void _animateSnap(int idx, Duration duration, {required bool spring}) {
    final n = _orbitCats.length;
    if (n == 0) return;
    final target = -_angleFor(idx, n);
    final diff = (target - _rotation + pi) % (2 * pi) - pi;
    final dest = _rotation + diff;
    if ((dest - _rotation).abs() < 0.001) return;

    _snapCtrl.stop();
    _snapCtrl.duration = duration;
    _snapCtrl.reset();
    final begin = _rotation;
    final curve = spring ? Curves.easeOutBack : Curves.easeOutCubic;
    _snapAnim?.removeListener(_onSnapTick);
    _snapCurve?.dispose();
    _snapCurve = CurvedAnimation(parent: _snapCtrl, curve: curve);
    _snapAnim = Tween<double>(begin: begin, end: dest).animate(_snapCurve!)
      ..addListener(_onSnapTick);
    _snapCtrl.forward();
  }

  static Widget _artwork(String asset) {
    final isSvg = asset.toLowerCase().endsWith('.svg');
    return isSvg
        ? SvgPicture.asset(asset, fit: BoxFit.contain)
        : Image.asset(asset, fit: BoxFit.contain);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cats = widget.categories;
    if (cats.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (_, constraints) {
        final w = constraints.maxWidth;

        final orbitR = (w * 0.315).clamp(116.0, 152.0);
        final orbitD = (w * 0.200).clamp(72.0, 92.0);
        final centerD = (w * 0.330).clamp(122.0, 156.0);
        final totalH = 2 * orbitR + orbitD + 20.0;
        final cx = w / 2;
        final cy = orbitR + orbitD / 2 + 10.0;

        final selectedCat = cats[_selectedIdx.clamp(0, cats.length - 1)];
        final orbitCats = _orbitCats;
        final n = orbitCats.length;

        final byDepth = List.generate(n, (i) => i)
          ..sort((a, b) => _depth(a, n).compareTo(_depth(b, n)));

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          dragStartBehavior: DragStartBehavior.down,
          onHorizontalDragUpdate: _onHorizontalDragUpdate,
          onHorizontalDragEnd: _onHorizontalDragEnd,
          child: SizedBox(
            width: w,
            height: totalH,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (final i in byDepth)
                  _buildNode(
                    orbitCats[i],
                    i,
                    n,
                    cx,
                    cy,
                    orbitR: orbitR,
                    orbitD: orbitD,
                  ),
                Positioned(
                  left: cx - centerD / 2,
                  top: cy - centerD / 2,
                  width: centerD,
                  height: centerD,
                  child: AnimatedSwitcher(
                    duration: WBMotion.base,
                    child: _buildCenter(selectedCat, centerD),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNode(
    OrbitalCategory cat,
    int i,
    int n,
    double cx,
    double cy, {
    required double orbitR,
    required double orbitD,
  }) {
    final angle = _angleFor(i, n) + _rotation;
    final dx = orbitR * sin(angle);
    final dy = -orbitR * cos(angle);
    final depth = _depth(i, n);
    final scale = 1.0 - depth * 0.12;
    final opacity = (1.0 - depth * 0.38).clamp(0.42, 1.0);

    return Positioned(
      left: cx + dx - orbitD / 2,
      top: cy + dy - orbitD / 2,
      width: orbitD,
      height: orbitD,
      child: GestureDetector(
        onTap: () => _tapNode(i),
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                color: WBColors.surfaceCard,
                shape: BoxShape.circle,
                border: Border.all(color: WBColors.borderFilled, width: 1.2),
                boxShadow: WBShadows.card,
              ),
              padding: EdgeInsets.all(orbitD * 0.20),
              child: _artwork(cat.iconAsset),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenter(OrbitalCategory cat, double d) {
    return Container(
      key: ValueKey(cat.id),
      width: d,
      height: d,
      decoration: const BoxDecoration(
        color: WBColors.surfaceDark,
        shape: BoxShape.circle,
        boxShadow: WBShadows.card,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: d * 0.34,
            height: d * 0.34,
            child: _artwork(cat.iconAsset),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: d * 0.10),
            child: Text(
              cat.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: WBTypography.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
