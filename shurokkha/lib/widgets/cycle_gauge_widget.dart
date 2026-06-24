import 'package:flutter/material.dart';
import 'dart:math';
import '../services/period_data_provider.dart';

class CycleGaugeWidget extends StatelessWidget {
  final PeriodDataProvider periodProvider;

  const CycleGaugeWidget({
    super.key,
    required this.periodProvider,
  });

  @override
  Widget build(BuildContext context) {
    final currentCycleDay = periodProvider.getCurrentCycleDay();
    final cycleLength = periodProvider.cycleLength;
    final periodLength = periodProvider.periodLength;

    return SizedBox(
      width: 200,
      height: 200,
      child: CustomPaint(
        painter: CycleGaugePainter(
          currentDay: currentCycleDay,
          totalDays: cycleLength,
          periodDays: periodLength,
        ),
      ),
    );
  }
}

class CycleGaugePainter extends CustomPainter {
  final int currentDay;
  final int totalDays;
  final int periodDays;

  CycleGaugePainter({
    required this.currentDay,
    required this.totalDays,
    required this.periodDays,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;

    // Draw background circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..style = PaintingStyle.fill,
    );

    // Draw colored segments for each phase
    double currentAngle = -pi / 2; // Start from top

    // Menstrual phase (days 1-5)
    _drawSegment(canvas, center, radius, currentAngle, 5 / totalDays * 2 * pi,
        const Color(0xFFFF4081));
    currentAngle += 5 / totalDays * 2 * pi;

    // Follicular phase (days 6-12)
    _drawSegment(canvas, center, radius, currentAngle, 7 / totalDays * 2 * pi,
        const Color(0xFFFFC107));
    currentAngle += 7 / totalDays * 2 * pi;

    // Ovulation phase (days 13-16)
    _drawSegment(canvas, center, radius, currentAngle, 4 / totalDays * 2 * pi,
        const Color(0xFFFF9800));
    currentAngle += 4 / totalDays * 2 * pi;

    // Luteal phase (remaining days)
    _drawSegment(canvas, center, radius, currentAngle, 12 / totalDays * 2 * pi,
        const Color(0xFFE91E63));

    // Draw outer ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Draw current day needle
    final needleAngle = -pi / 2 + (currentDay / totalDays) * 2 * pi;
    final needleX = center.dx + (radius - 20) * cos(needleAngle);
    final needleY = center.dy + (radius - 20) * sin(needleAngle);

    // Draw needle line
    canvas.drawLine(
      center,
      Offset(needleX, needleY),
      Paint()
        ..color = const Color(0xFF2C3E50)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Draw needle center circle
    canvas.drawCircle(
      center,
      8,
      Paint()
        ..color = const Color(0xFF2C3E50)
        ..style = PaintingStyle.fill,
    );

    // Draw day number in center
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Day\n$currentDay',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _drawSegment(Canvas canvas, Offset center, double radius, double startAngle,
      double sweepAngle, Color color) {
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      true,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(CycleGaugePainter oldDelegate) {
    return oldDelegate.currentDay != currentDay;
  }
}
