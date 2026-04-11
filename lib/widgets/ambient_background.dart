import 'package:flutter/material.dart';

/// Decorative soft blobs — purely visual; excluded from semantics and pointer events.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({
    super.key,
    this.variant = AmbientVariant.home,
  });

  final AmbientVariant variant;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: SizedBox.expand(
          child: CustomPaint(
            painter: _AmbientPainter(variant),
          ),
        ),
      ),
    );
  }
}

enum AmbientVariant { home, welcome }

class _AmbientPainter extends CustomPainter {
  _AmbientPainter(this.variant);

  final AmbientVariant variant;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    void blob(Offset c, double r, Color color) {
      canvas.drawCircle(c, r, Paint()..color = color);
    }

    if (variant == AmbientVariant.home) {
      blob(Offset(size.width * 0.92, size.height * 0.06), size.width * 0.28,
          const Color(0xFF2DD4BF).withValues(alpha: 0.22));
      blob(Offset(size.width * -0.06, size.height * 0.18), size.width * 0.24,
          const Color(0xFFA78BFA).withValues(alpha: 0.18));
      blob(Offset(size.width * 0.72, size.height * 0.42), size.width * 0.35,
          const Color(0xFF38BDF8).withValues(alpha: 0.12));
      blob(Offset(size.width * 0.08, size.height * 0.72), size.width * 0.26,
          const Color(0xFF34D399).withValues(alpha: 0.14));
      blob(Offset(size.width * 0.88, size.height * 0.88), size.width * 0.2,
          const Color(0xFFF472B6).withValues(alpha: 0.1));
    } else {
      blob(Offset(size.width * 0.15, size.height * 0.2), size.width * 0.45,
          Colors.white.withValues(alpha: 0.07));
      blob(Offset(size.width * 0.95, size.height * 0.35), size.width * 0.3,
          const Color(0xFF5EEAD4).withValues(alpha: 0.15));
      blob(Offset(size.width * 0.4, size.height * 0.85), size.width * 0.38,
          const Color(0xFFC4B5FD).withValues(alpha: 0.12));
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientPainter oldDelegate) =>
      oldDelegate.variant != variant;
}
