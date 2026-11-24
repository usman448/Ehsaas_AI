import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/emotions.dart';

const kPurple = Color(0xFF6D5CF0);
const kBlue = Color(0xFF3B82F6);
const kTeal = Color(0xFF2CC5B5);
const kGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kBlue, Color(0xFF7C5CF0), kTeal],
);

TextStyle urduStyle(double size, {Color? color}) =>
    GoogleFonts.notoNastaliqUrdu(fontSize: size, height: 2.0, color: color);

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 84});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: kGradient,
          borderRadius: BorderRadius.circular(size * .33),
          boxShadow: [BoxShadow(color: kPurple.withValues(alpha: .35), blurRadius: 24, offset: const Offset(0, 10))],
        ),
        child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: size * .55),
      );
}

class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  const SoftCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [BoxShadow(color: kPurple.withValues(alpha: .07), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(borderRadius: BorderRadius.circular(22), onTap: onTap, child: Padding(padding: padding, child: child)),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final IconData? icon;
  const GradientButton({super.key, required this.label, this.onTap, this.loading = false, this.icon});
  @override
  Widget build(BuildContext context) => Opacity(
        opacity: onTap == null ? .6 : 1,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              gradient: kGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: kPurple.withValues(alpha: .35), blurRadius: 18, offset: const Offset(0, 8))],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: loading ? null : onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Center(
                  child: loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Row(mainAxisSize: MainAxisSize.min, children: [
                          if (icon != null) ...[Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 8)],
                          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                        ]),
                ),
              ),
            ),
          ),
        ),
      );
}

class EmotionBadge extends StatelessWidget {
  final String emotion;
  const EmotionBadge(this.emotion, {super.key});
  @override
  Widget build(BuildContext context) {
    final e = emo(emotion);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: e.color.withValues(alpha: .15), borderRadius: BorderRadius.circular(99)),
      child: Text('${e.emoji} ${e.en}', style: TextStyle(color: e.color, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}

/// Robot mascot (same idea as the mockup screens). Draws on a transparent background.
class RobotLogo extends StatelessWidget {
  final double size;
  const RobotLogo({super.key, this.size = 120});
  @override
  Widget build(BuildContext context) {
    final h = size * 134 / 120;
    return SizedBox(
      width: size,
      height: h,
      child: Stack(children: [
        CustomPaint(size: Size(size, h), painter: _RobotPainter()),
        Positioned(left: size * .425, top: size * 100 / 120, child: Icon(Icons.favorite, color: kPurple, size: size * .15)),
      ]),
    );
  }
}

class _RobotPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size sz) {
    c.scale(sz.width / 120);
    final w = Paint()..color = Colors.white;
    final teal = Paint()..color = kTeal;
    c.drawLine(const Offset(60, 12), const Offset(60, 28), Paint()..color = Colors.white..strokeWidth = 4..strokeCap = StrokeCap.round);
    c.drawCircle(const Offset(60, 9), 6, Paint()..color = const Color(0xFFFFD166));
    c.drawCircle(const Offset(14, 56), 8, w);
    c.drawCircle(const Offset(106, 56), 8, w);
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(20, 28, 80, 58), const Radius.circular(24)), w);
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(31, 40, 58, 34), const Radius.circular(15)), Paint()..color = const Color(0xFF1B2250));
    c.drawCircle(const Offset(47, 55), 6, teal);
    c.drawCircle(const Offset(73, 55), 6, teal);
    final smile = Path()..moveTo(52, 65)..quadraticBezierTo(60, 71, 68, 65);
    c.drawPath(smile, Paint()..color = kTeal..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round);
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(34, 92, 52, 36), const Radius.circular(17)), w);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class UserAvatar extends StatelessWidget {
  final Uint8List? bytes;
  final String name;
  final double size;
  final VoidCallback? onTap;
  const UserAvatar({super.key, this.bytes, required this.name, this.size = 44, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: bytes == null ? kGradient : null,
            image: bytes != null ? DecorationImage(image: MemoryImage(bytes!), fit: BoxFit.cover) : null,
            boxShadow: [BoxShadow(color: kPurple.withValues(alpha: .3), blurRadius: 14, offset: const Offset(0, 5))],
          ),
          child: bytes == null
              ? Text(name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: size * .42))
              : null,
        ),
      );
}
