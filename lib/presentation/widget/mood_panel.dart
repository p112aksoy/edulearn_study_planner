import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:edulearn/core/responsive.dart';

class MoodData {
  final String label;
  final String message;
  const MoodData({required this.label, required this.message});
}

class MoodPanel extends StatefulWidget {
  const MoodPanel({super.key});

  @override
  State<MoodPanel> createState() => _MoodPanelState();
}

class _MoodPanelState extends State<MoodPanel> with TickerProviderStateMixin {
  // animation controllers handling different mood behaviors
  late AnimationController _jumpController;
  late AnimationController _breathController;
  late AnimationController _blinkController;

  String _selectedMoodKey = "Focused";

  static const Map<String, MoodData> _moodMap = {
    "Focused":   MoodData(label: "Focused",   message: "Deep work is your superpower. Stay sharp."),
    "Tired":     MoodData(label: "Tired",     message: "Rest if you must, but don't you quit."),
    "Energetic": MoodData(label: "Energetic", message: "Unleash the storm within. You are unstoppable!"),
  };

  @override
  void initState() {
    super.initState();
// loop translation animation up & down, for the energetic lightning bolt
    _jumpController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    // loop opacity animation (fade in & out) for the Tired moon icon
    _breathController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
// single shot animation controller to manage eye blinking speed
    _blinkController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180));
// timer triggers an automatic eye blink every 4 seconds only if "focused" is active
    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted &&
          _selectedMoodKey == "Focused" &&
          !_blinkController.isAnimating) {
        _blinkController.forward().then((_) => _blinkController.reverse());
      }
    });
  }

  @override
  void dispose() {
    _jumpController.dispose();
    _breathController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.spacing(context) * 1.375),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius:
        BorderRadius.circular(Responsive.radius(context) * 1.6),
        border: Border.all(
            color: color.primary.withValues(alpha: 0.15), width: 2),
      ),
      child: Column(
        children: [
          _buildMoodContent(color),
          SizedBox(height: Responsive.spacing(context) * 1.25),
          _buildMoodSelector(color),
        ],
      ),
    );
  }

  Widget _buildMoodContent(ColorScheme color) {
    final currentMood = _moodMap[_selectedMoodKey]!;
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 340) {
        return Column(children: [
          Text(currentMood.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color.onSurface.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                  height: 1.4)),
          SizedBox(height: Responsive.spacing(context) * 1.25),
          _buildAnimatedCharacter(color),
        ]);
      }
      return Row(children: [
        Expanded(
          child: Text(currentMood.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color.onSurface.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                  height: 1.4)),
        ),
        SizedBox(width: Responsive.spacing(context)),
        _buildAnimatedCharacter(color),
      ]);
    });
  }

  Widget _buildMoodSelector(ColorScheme color) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: color.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
      ),
      child: Row(
        children: _moodMap.keys.map((key) {
          final isSelected = _selectedMoodKey == key;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedMoodKey = key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(
                    vertical: Responsive.spacing(context) * 0.75),
                decoration: BoxDecoration(
                  color: isSelected ? color.primary : Colors.transparent,
                  borderRadius:
                  BorderRadius.circular(Responsive.cardRadius(context)),
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(key,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(
                          color: isSelected
                              ? color.onPrimary
                              : color.onSurface.withValues(alpha: 0.4),
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAnimatedCharacter(ColorScheme color) {
    if (_selectedMoodKey == "Energetic") {
      return SlideTransition(
        position:
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.3))
            .animate(_jumpController),
        child: Icon(Icons.bolt_rounded,
            color: color.primary, size: Responsive.icon(context) * 2.05),
      );
    }
    if (_selectedMoodKey == "Tired") {
      return FadeTransition(
        opacity:
        Tween<double>(begin: 0.3, end: 1.0).animate(_breathController),
        child: Icon(Icons.nights_stay_rounded,
            color: color.primary, size: Responsive.icon(context) * 1.82),
      );
    }
    // default mood (focused): Renders the interactive custom vector eye
    return AnimatedBuilder(
      animation: _blinkController,
      builder: (context, child) => CustomPaint(
        size: const Size(60, 35),
        painter: RealisticEyePainter(
          blinkValue:  _blinkController.value,
          lidColor:    color.primary,
          borderColor: color.primary.withValues(alpha: 0.6),
          scleraColor: color.surface,
          irisColor:   color.primary,
        ),
      ),
    );
  }
}

// custom painter that renders a fully dynamic eye with clipping paths and bezier curves
class RealisticEyePainter extends CustomPainter {
  final double blinkValue;
  final Color  lidColor;
  final Color  borderColor;
  final Color  scleraColor;
  final Color  irisColor;

  RealisticEyePainter({
    required this.blinkValue,
    required this.lidColor,
    required this.borderColor,
    required this.scleraColor,
    required this.irisColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w       = size.width;
    final h       = size.height;
    final centerX = w / 2;
    final centerY = h / 2;

    final scleraPaint = Paint()..color = scleraColor..style = PaintingStyle.fill;
    final lidPaint    = Paint()..color = lidColor..style = PaintingStyle.fill;
    final irisPaint   = Paint()..color = irisColor..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    final eyePath = Path()
      ..moveTo(0, centerY)
      ..cubicTo(w * 0.2, h * -0.1, w * 0.8, h * -0.1, w, centerY)
      ..cubicTo(w * 0.8, h * 1.1, w * 0.2, h * 1.1, 0, centerY)
      ..close();

    canvas.drawPath(eyePath, borderPaint);
    canvas.drawPath(eyePath, scleraPaint);
    canvas.clipPath(eyePath);// ensures iris and eyelid remain inside the borders

    if (blinkValue < 0.95) {
      canvas.drawCircle(Offset(centerX, centerY), h * 0.45, irisPaint);
      canvas.drawCircle(Offset(centerX * 1.15, centerY * 0.8), 3,
          Paint()..color = scleraColor);
    }
// calculates top eyelid displacement using the controller value to simulate blinking
    final topLidY =
    math.max(h * -0.1, h * (blinkValue * 1.2) - h * 0.1);
    final topPath = Path()
      ..moveTo(0, centerY)
      ..cubicTo(w * 0.2, topLidY, w * 0.8, topLidY, w, centerY)
      ..lineTo(w, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(topPath, lidPaint);
  }

  @override
  bool shouldRepaint(RealisticEyePainter old) =>
      old.blinkValue != blinkValue;
}