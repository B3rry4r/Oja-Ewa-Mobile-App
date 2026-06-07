import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/wb_theme_exports.dart';

/// Minimal outline icon system. Each icon is rendered with direct Canvas
/// commands on a 24×24 design grid to match the design's stroke-style
/// (rounded, thin, monochrome).
enum WBIconName {
  home,
  search,
  basket,
  heart,
  user,
  pin,
  bell,
  clock,
  star,
  arrowRight,
  arrowLeft,
  chevronRight,
  chevronLeft,
  chevronDown,
  check,
  close,
  plus,
  minus,
  filter,
  more,
  bike,
  phone,
  message,
  card,
  book,
  lock,
  globe,
  store,
  services,
  shield,
  doc,
  help,
  trash,
  logout,
}

class WBIcon extends StatelessWidget {
  const WBIcon(
    this.name, {
    super.key,
    this.size = 20,
    this.color = WBColors.fgHeader,
    this.strokeWidth = 1.5,
  });

  final WBIconName name;
  final double size;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _WBIconPainter(
          name: name,
          color: color,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _WBIconPainter extends CustomPainter {
  _WBIconPainter({
    required this.name,
    required this.color,
    required this.strokeWidth,
  });

  final WBIconName name;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final stroke = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (name) {
      case WBIconName.home:
        final p = Path()
          ..moveTo(3, 10.5)
          ..lineTo(12, 3)
          ..lineTo(21, 10.5)
          ..lineTo(21, 20)
          ..lineTo(15, 20)
          ..lineTo(15, 14)
          ..lineTo(9, 14)
          ..lineTo(9, 20)
          ..lineTo(3, 20)
          ..close();
        canvas.drawPath(p, stroke);
      case WBIconName.search:
        canvas.drawCircle(const Offset(11, 11), 7, stroke);
        canvas.drawLine(const Offset(16, 16), const Offset(21, 21), stroke);
      case WBIconName.basket:
        // Bucket outline (top rect + slanted sides + bottom)
        final body = Path()
          ..moveTo(3, 6)
          ..lineTo(21, 6)
          ..lineTo(19, 20)
          ..lineTo(5, 20)
          ..close();
        canvas.drawPath(body, stroke);
        // Handle
        canvas.drawArc(
          const Rect.fromLTWH(9, 3, 6, 6),
          math.pi,
          math.pi,
          false,
          stroke,
        );
      case WBIconName.heart:
        final p = Path()
          ..moveTo(12, 20.5)
          ..cubicTo(5, 16, 4, 12, 4, 9)
          ..cubicTo(4, 6.5, 6, 4.5, 8.5, 4.5)
          ..cubicTo(10, 4.5, 11.3, 5.3, 12, 6.5)
          ..cubicTo(12.7, 5.3, 14, 4.5, 15.5, 4.5)
          ..cubicTo(18, 4.5, 20, 6.5, 20, 9)
          ..cubicTo(20, 12, 19, 16, 12, 20.5)
          ..close();
        canvas.drawPath(p, stroke);
      case WBIconName.user:
        canvas.drawCircle(const Offset(12, 8), 4, stroke);
        canvas.drawArc(
          const Rect.fromLTWH(4, 13, 16, 16),
          math.pi,
          math.pi,
          false,
          stroke,
        );
      case WBIconName.pin:
        final p = Path()
          ..moveTo(12, 22)
          ..cubicTo(12, 22, 20, 16, 20, 10)
          ..cubicTo(20, 5.6, 16.4, 2, 12, 2)
          ..cubicTo(7.6, 2, 4, 5.6, 4, 10)
          ..cubicTo(4, 16, 12, 22, 12, 22)
          ..close();
        canvas.drawPath(p, stroke);
        canvas.drawCircle(const Offset(12, 10), 3, stroke);
      case WBIconName.bell:
        final p = Path()
          ..moveTo(6, 8)
          ..cubicTo(6, 4.7, 8.7, 2, 12, 2)
          ..cubicTo(15.3, 2, 18, 4.7, 18, 8)
          ..cubicTo(18, 15, 21, 15, 21, 17)
          ..lineTo(3, 17)
          ..cubicTo(3, 15, 6, 15, 6, 8)
          ..close();
        canvas.drawPath(p, stroke);
        // Bell clapper
        canvas.drawArc(
          const Rect.fromLTWH(10, 19, 4, 4),
          0,
          math.pi,
          false,
          stroke,
        );
      case WBIconName.clock:
        canvas.drawCircle(const Offset(12, 12), 9, stroke);
        final hands = Path()
          ..moveTo(12, 7)
          ..lineTo(12, 12)
          ..lineTo(15, 14);
        canvas.drawPath(hands, stroke);
      case WBIconName.star:
        const cx = 12.0, cy = 12.0;
        final path = Path();
        for (var i = 0; i < 10; i++) {
          final r = i.isEven ? 9.0 : 4.0;
          final a = -math.pi / 2 + i * math.pi / 5;
          final x = cx + r * math.cos(a);
          final y = cy + r * math.sin(a);
          i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
        }
        path.close();
        canvas.drawPath(path, fill);
      case WBIconName.arrowRight:
        canvas.drawLine(const Offset(5, 12), const Offset(19, 12), stroke);
        final head = Path()
          ..moveTo(13, 6)
          ..lineTo(19, 12)
          ..lineTo(13, 18);
        canvas.drawPath(head, stroke);
      case WBIconName.arrowLeft:
        canvas.drawLine(const Offset(19, 12), const Offset(5, 12), stroke);
        final head = Path()
          ..moveTo(11, 18)
          ..lineTo(5, 12)
          ..lineTo(11, 6);
        canvas.drawPath(head, stroke);
      case WBIconName.chevronRight:
        final p = Path()
          ..moveTo(9, 6)
          ..lineTo(15, 12)
          ..lineTo(9, 18);
        canvas.drawPath(p, stroke);
      case WBIconName.chevronLeft:
        final p = Path()
          ..moveTo(15, 6)
          ..lineTo(9, 12)
          ..lineTo(15, 18);
        canvas.drawPath(p, stroke);
      case WBIconName.chevronDown:
        final p = Path()
          ..moveTo(6, 9)
          ..lineTo(12, 15)
          ..lineTo(18, 9);
        canvas.drawPath(p, stroke);
      case WBIconName.check:
        final p = Path()
          ..moveTo(5, 12)
          ..lineTo(10, 17)
          ..lineTo(19, 7);
        canvas.drawPath(p, stroke);
      case WBIconName.close:
        canvas.drawLine(const Offset(6, 6), const Offset(18, 18), stroke);
        canvas.drawLine(const Offset(18, 6), const Offset(6, 18), stroke);
      case WBIconName.plus:
        canvas.drawLine(const Offset(12, 5), const Offset(12, 19), stroke);
        canvas.drawLine(const Offset(5, 12), const Offset(19, 12), stroke);
      case WBIconName.minus:
        canvas.drawLine(const Offset(5, 12), const Offset(19, 12), stroke);
      case WBIconName.filter:
        canvas.drawLine(const Offset(4, 6), const Offset(20, 6), stroke);
        canvas.drawLine(const Offset(7, 12), const Offset(17, 12), stroke);
        canvas.drawLine(const Offset(10, 18), const Offset(14, 18), stroke);
      case WBIconName.more:
        canvas.drawCircle(const Offset(5, 12), 1.4, fill);
        canvas.drawCircle(const Offset(12, 12), 1.4, fill);
        canvas.drawCircle(const Offset(19, 12), 1.4, fill);
      case WBIconName.bike:
        canvas.drawCircle(const Offset(5, 16), 3, stroke);
        canvas.drawCircle(const Offset(19, 16), 3, stroke);
        final frame = Path()
          ..moveTo(12, 16)
          ..lineTo(9, 7)
          ..lineTo(7, 7);
        canvas.drawPath(frame, stroke);
        final fork = Path()
          ..moveTo(15, 7)
          ..lineTo(18, 7)
          ..lineTo(19, 13);
        canvas.drawPath(fork, stroke);
        canvas.drawLine(const Offset(9, 10), const Offset(16, 10), stroke);
      case WBIconName.phone:
        final p = Path()
          ..moveTo(4, 4)
          ..lineTo(7, 4)
          ..lineTo(9, 9)
          ..lineTo(7.5, 10.5)
          ..cubicTo(8.5, 13.5, 10.5, 15.5, 13.5, 16.5)
          ..lineTo(15, 15)
          ..lineTo(20, 17)
          ..lineTo(20, 20)
          ..cubicTo(20, 20.5, 19.5, 21, 19, 21)
          ..cubicTo(10, 21, 3, 14, 3, 5)
          ..cubicTo(3, 4.5, 3.5, 4, 4, 4)
          ..close();
        canvas.drawPath(p, stroke);
      case WBIconName.message:
        final p = Path()
          ..moveTo(3, 21)
          ..lineTo(5, 16)
          ..cubicTo(3.5, 14, 3, 12, 3, 11.5)
          ..cubicTo(3, 6.8, 6.8, 3, 11.5, 3)
          ..cubicTo(11.7, 3, 12, 3, 12, 3)
          ..cubicTo(16.7, 3, 21, 6.8, 21, 11.5)
          ..cubicTo(21, 16.2, 17.2, 20, 12.5, 20)
          ..cubicTo(11, 20, 9.5, 19.5, 8, 19)
          ..close();
        canvas.drawPath(p, stroke);
      case WBIconName.card:
        final rect = RRect.fromRectAndRadius(
          const Rect.fromLTWH(2.5, 5.5, 19, 13),
          const Radius.circular(2),
        );
        canvas.drawRRect(rect, stroke);
        canvas.drawLine(const Offset(2.5, 9), const Offset(21.5, 9), stroke);
      case WBIconName.book:
        final pages = Path()
          ..moveTo(12, 6.5)
          ..lineTo(5, 5)
          ..lineTo(5, 18.5)
          ..lineTo(12, 20)
          ..lineTo(19, 18.5)
          ..lineTo(19, 5)
          ..lineTo(12, 6.5)
          ..close();
        canvas.drawPath(pages, stroke);
        canvas.drawLine(const Offset(12, 6.5), const Offset(12, 20), stroke);
      case WBIconName.lock:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(5, 10.5, 14, 10),
            const Radius.circular(2.5),
          ),
          stroke,
        );
        canvas.drawArc(
          const Rect.fromLTWH(8, 5.5, 8, 9),
          math.pi,
          math.pi,
          false,
          stroke,
        );
        canvas.drawCircle(const Offset(12, 15), 1.4, fill);
      case WBIconName.globe:
        canvas.drawCircle(const Offset(12, 12), 9, stroke);
        canvas.drawLine(const Offset(3, 12), const Offset(21, 12), stroke);
        final meridian = Path()
          ..moveTo(12, 3)
          ..cubicTo(7, 7, 7, 17, 12, 21)
          ..cubicTo(17, 17, 17, 7, 12, 3)
          ..close();
        canvas.drawPath(meridian, stroke);
      case WBIconName.store:
        final roof = Path()
          ..moveTo(4, 9)
          ..lineTo(5.5, 5)
          ..lineTo(18.5, 5)
          ..lineTo(20, 9)
          ..close();
        canvas.drawPath(roof, stroke);
        final body = Path()
          ..moveTo(5, 9)
          ..lineTo(5, 20)
          ..lineTo(19, 20)
          ..lineTo(19, 9);
        canvas.drawPath(body, stroke);
        final door = Path()
          ..moveTo(10, 20)
          ..lineTo(10, 14.5)
          ..lineTo(14, 14.5)
          ..lineTo(14, 20);
        canvas.drawPath(door, stroke);
      case WBIconName.shield:
        final s = Path()
          ..moveTo(12, 3)
          ..lineTo(19, 6)
          ..lineTo(19, 11)
          ..cubicTo(19, 16, 15.5, 19.5, 12, 21)
          ..cubicTo(8.5, 19.5, 5, 16, 5, 11)
          ..lineTo(5, 6)
          ..close();
        canvas.drawPath(s, stroke);
        final check = Path()
          ..moveTo(9, 11.5)
          ..lineTo(11.2, 13.7)
          ..lineTo(15, 9.5);
        canvas.drawPath(check, stroke);
      case WBIconName.doc:
        final outline = Path()
          ..moveTo(6, 3)
          ..lineTo(14, 3)
          ..lineTo(18, 7)
          ..lineTo(18, 21)
          ..lineTo(6, 21)
          ..close();
        canvas.drawPath(outline, stroke);
        final fold = Path()
          ..moveTo(14, 3)
          ..lineTo(14, 7)
          ..lineTo(18, 7);
        canvas.drawPath(fold, stroke);
        canvas.drawLine(const Offset(9, 12), const Offset(15, 12), stroke);
        canvas.drawLine(const Offset(9, 16), const Offset(15, 16), stroke);
      case WBIconName.help:
        canvas.drawCircle(const Offset(12, 12), 9, stroke);
        final q = Path()
          ..moveTo(9.3, 9.5)
          ..cubicTo(9.3, 7, 14.7, 7, 14.7, 10)
          ..cubicTo(14.7, 12.2, 12, 12.2, 12, 14.5);
        canvas.drawPath(q, stroke);
        canvas.drawCircle(const Offset(12, 17.2), 1.1, fill);
      case WBIconName.trash:
        canvas.drawLine(const Offset(4, 7), const Offset(20, 7), stroke);
        final handle = Path()
          ..moveTo(9, 7)
          ..lineTo(9, 4.8)
          ..lineTo(15, 4.8)
          ..lineTo(15, 7);
        canvas.drawPath(handle, stroke);
        final can = Path()
          ..moveTo(6, 7)
          ..lineTo(7, 20)
          ..lineTo(17, 20)
          ..lineTo(18, 7);
        canvas.drawPath(can, stroke);
        canvas.drawLine(const Offset(10, 10.5), const Offset(10, 16.5), stroke);
        canvas.drawLine(const Offset(14, 10.5), const Offset(14, 16.5), stroke);
      case WBIconName.logout:
        final frame = Path()
          ..moveTo(14, 4)
          ..lineTo(6, 4)
          ..lineTo(6, 20)
          ..lineTo(14, 20);
        canvas.drawPath(frame, stroke);
        canvas.drawLine(const Offset(10, 12), const Offset(21, 12), stroke);
        final head = Path()
          ..moveTo(17, 8)
          ..lineTo(21, 12)
          ..lineTo(17, 16);
        canvas.drawPath(head, stroke);
      case WBIconName.services:
        // 2×2 grid of rounded squares — the "all services" / apps glyph.
        const r = Radius.circular(2);
        for (final o in const [
          Offset(4, 4),
          Offset(13, 4),
          Offset(4, 13),
          Offset(13, 13),
        ]) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(o.dx, o.dy, 7, 7),
              r,
            ),
            stroke,
          );
        }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_WBIconPainter old) =>
      old.name != name || old.color != color || old.strokeWidth != strokeWidth;
}
