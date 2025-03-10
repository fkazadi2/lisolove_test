import 'package:flutter/material.dart';

/// CustomPainter pour dessiner le logo Google officiel à partir des chemins SVG
class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Mise à l'échelle pour s'adapter à la taille fournie
    final scale = size.width / 48;
    
    // Rouge (partie supérieure gauche)
    final redPaint = Paint()..color = const Color(0xFFEA4335);
    final redPath = Path()
      ..moveTo(24 * scale, 9.5 * scale)
      ..cubicTo(
        27.54 * scale, 9.5 * scale,
        30.71 * scale, 10.72 * scale,
        33.21 * scale, 13.1 * scale
      )
      ..lineTo(40.06 * scale, 6.25 * scale)
      ..cubicTo(
        35.9 * scale, 2.38 * scale,
        30.47 * scale, 0,
        24 * scale, 0
      )
      ..cubicTo(
        14.62 * scale, 0,
        6.51 * scale, 5.38 * scale,
        2.56 * scale, 13.22 * scale
      )
      ..lineTo(10.54 * scale, 19.41 * scale)
      ..cubicTo(
        12.43 * scale, 13.72 * scale,
        17.74 * scale, 9.5 * scale,
        24 * scale, 9.5 * scale
      );
    canvas.drawPath(redPath, redPaint);

    // Bleu (partie droite)
    final bluePaint = Paint()..color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..moveTo(46.98 * scale, 24.55 * scale)
      ..cubicTo(
        46.98 * scale, 22.98 * scale,
        46.83 * scale, 21.46 * scale,
        46.6 * scale, 20 * scale
      )
      ..lineTo(24 * scale, 20 * scale)
      ..lineTo(24 * scale, 29.02 * scale)
      ..lineTo(36.94 * scale, 29.02 * scale)
      ..cubicTo(
        36.36 * scale, 31.98 * scale,
        34.68 * scale, 34.5 * scale,
        32.16 * scale, 36.2 * scale
      )
      ..lineTo(39.89 * scale, 42.2 * scale)
      ..cubicTo(
        44.4 * scale, 38.02 * scale,
        46.98 * scale, 31.84 * scale,
        46.98 * scale, 24.55 * scale
      );
    canvas.drawPath(bluePath, bluePaint);

    // Jaune (partie inférieure gauche)
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    final yellowPath = Path()
      ..moveTo(10.53 * scale, 28.59 * scale)
      ..cubicTo(
        10.05 * scale, 27.14 * scale,
        9.77 * scale, 25.6 * scale,
        9.77 * scale, 24 * scale
      )
      ..cubicTo(
        9.77 * scale, 22.4 * scale,
        10.04 * scale, 20.86 * scale,
        10.53 * scale, 19.41 * scale
      )
      ..lineTo(2.55 * scale, 13.22 * scale)
      ..cubicTo(
        0.92 * scale, 16.46 * scale,
        0, 20.12 * scale,
        0, 24 * scale
      )
      ..cubicTo(
        0, 27.88 * scale,
        0.92 * scale, 31.54 * scale,
        2.56 * scale, 34.78 * scale
      )
      ..lineTo(10.53 * scale, 28.59 * scale);
    canvas.drawPath(yellowPath, yellowPaint);

    // Vert (partie inférieure droite)
    final greenPaint = Paint()..color = const Color(0xFF34A853);
    final greenPath = Path()
      ..moveTo(24 * scale, 48 * scale)
      ..cubicTo(
        30.48 * scale, 48 * scale,
        35.93 * scale, 45.87 * scale,
        39.89 * scale, 42.19 * scale
      )
      ..lineTo(32.16 * scale, 36.19 * scale)
      ..cubicTo(
        30.01 * scale, 37.64 * scale,
        27.24 * scale, 38.49 * scale,
        24 * scale, 38.49 * scale
      )
      ..cubicTo(
        17.74 * scale, 38.49 * scale,
        12.43 * scale, 34.27 * scale,
        10.53 * scale, 28.58 * scale
      )
      ..lineTo(2.55 * scale, 34.77 * scale)
      ..cubicTo(
        6.51 * scale, 42.62 * scale,
        14.62 * scale, 48 * scale,
        24 * scale, 48 * scale
      );
    canvas.drawPath(greenPath, greenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Widget qui affiche le logo Google
class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: GoogleLogoPainter(),
        size: Size(size, size),
      ),
    );
  }
}

/// Widget pour un bouton Google Sign-In officiel
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double height;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.text = 'Se connecter avec Google',
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F1F1F),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0xFF747775), width: 1),
        ),
        elevation: 0,
        minimumSize: Size.fromHeight(height),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GoogleLogo(size: height * 0.6),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.43,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
} 