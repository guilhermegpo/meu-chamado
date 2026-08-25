import 'package:flutter/material.dart';

class AppsMeuMark extends StatelessWidget {
  const AppsMeuMark({this.size = 56, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Apps Meu',
      image: true,
      child: ExcludeSemantics(
        // Center isola a marca do alinhamento do pai. Dentro de uma Column com
        // CrossAxisAlignment.stretch, o SizedBox sozinho recebe largura forçada
        // e o desenho sai esticado.
        child: Center(
          child: SizedBox.square(
            dimension: size,
            child: CustomPaint(
              painter: _AppsMeuMarkPainter(
                primary: Theme.of(context).colorScheme.primary,
                accent: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppsMeuMarkPainter extends CustomPainter {
  const _AppsMeuMarkPainter({required this.primary, required this.accent});

  final Color primary;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.width * 0.24);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, radius),
      Paint()..color = primary,
    );

    final line = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.7)
      ..lineTo(size.width * 0.22, size.height * 0.32)
      ..lineTo(size.width * 0.5, size.height * 0.56)
      ..lineTo(size.width * 0.78, size.height * 0.32)
      ..lineTo(size.width * 0.78, size.height * 0.7);
    canvas.drawPath(path, line);
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.22),
      size.width * 0.08,
      Paint()..color = accent,
    );
  }

  @override
  bool shouldRepaint(_AppsMeuMarkPainter oldDelegate) =>
      primary != oldDelegate.primary || accent != oldDelegate.accent;
}
