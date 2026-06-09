import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:edulearn/logic/providers/courses.provider.dart';
import 'package:edulearn/logic/providers/study_provider.dart';
import 'package:edulearn/presentation/widget/pomodoro_music_section.dart';
import 'package:edulearn/core/responsive.dart';

class PomodoroPage extends StatefulWidget {
  final String? courseName;
  final int?    courseId;
  final bool    hasDownBar;

  const PomodoroPage({
    super.key,
    this.courseName,
    this.courseId,
    this.hasDownBar = false,
  });

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  int _studyMinutes = 25;
  int _breakMinutes = 5;

  late int _secondsRemaining;
  late int _totalSeconds;
  int  _studySecondsCompleted = 0;

  Timer? _timer;
  bool   _isRunning = false;
  bool   _isBreak   = false;

  @override
  void initState() {
    super.initState();
    _totalSeconds     = _studyMinutes * 60;
    _secondsRemaining = _totalSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // for mode switch
  void _switchMode() {
    _timer?.cancel();

    if (!_isBreak && widget.courseId != null) {
      final minutes = _studySecondsCompleted ~/ 60;
      if (minutes > 0) {
        context.read<CoursesProvider>().updateProgress(
            widget.courseId!, minutes);
      }
    }

    setState(() {
      _isBreak               = !_isBreak;
      _isRunning             = false;
      _studySecondsCompleted = 0;
      _totalSeconds          =
          (_isBreak ? _breakMinutes : _studyMinutes) * 60;
      _secondsRemaining      = _totalSeconds;
    });

    if (_isBreak) context.read<StudyProvider>().stopMusic();
  }

  // for timer
  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
            if (!_isBreak) _studySecondsCompleted++;
          } else {
            _switchMode();
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted && !_isRunning) _toggleTimer();
            });
          }
        });
      });
      setState(() => _isRunning = true);
    }
  }

  // reset part
  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning             = false;
      _studySecondsCompleted = 0;
      _secondsRemaining      = _totalSeconds;
    });
  }

  // important: build part
  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final color     = theme.colorScheme;
    final text      = theme.textTheme;
    final hasCourse = widget.courseName?.isNotEmpty == true;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints:
            BoxConstraints(minHeight: Responsive.height(context)),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.pagePadding(context)),
              child: Column(
                children: [
                  SizedBox(height: Responsive.pageTopSpacing(context)),

                  // for top bar
                  SizedBox(
                    height: Responsive.buttonHeight(context),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (!widget.hasDownBar && hasCourse)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: EdgeInsets.all(
                                    Responsive.spacing(context) * 0.625),
                                decoration: BoxDecoration(
                                  color: color.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: color.primary
                                          .withValues(alpha: 0.2),
                                      width: 1.5),
                                ),
                                child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: color.primary,
                                    size: Responsive.smallIcon(context)),
                              ),
                            ),
                          ),
                        if (hasCourse)
                          ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth:
                                Responsive.width(context) * 0.6),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                Responsive.spacing(context) * 1.5,
                                vertical:
                                Responsive.spacing(context) * 0.625,
                              ),
                              decoration: ShapeDecoration(
                                color: color.surface,
                                shape: StadiumBorder(
                                    side: BorderSide(
                                        color: color.primary, width: 2)),
                              ),
                              child: Text(
                                widget.courseName!.toLowerCase(),
                                overflow: TextOverflow.ellipsis,
                                style: text.titleSmall?.copyWith(
                                    color: color.primary,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: Responsive.sectionSpacing(context)),

                  // mode toggle
                  _buildModeToggle(color, text),

                  SizedBox(height: Responsive.sectionSpacing(context) * 1.5),

                  // for timer display
                  _buildTimerDisplay(color, text),

                  SizedBox(height: Responsive.sectionSpacing(context) * 1.5),

                  // adjust button
                  _buildAdjustBtn(color, text),

                  SizedBox(height: Responsive.sectionSpacing(context)),

                  // for controls
                  _buildControls(color),

                  // this is music section (in the widget file, there has operation)
                  const PomodoroMusicSection(),

                  SizedBox(height: Responsive.sectionSpacing(context) * 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // this part is mode toggle
  Widget _buildModeToggle(ColorScheme color, TextTheme text) {
    return Container(
      width: Responsive.isMobile(context)
          ? Responsive.width(context) * 0.58
          : 260,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.onSurface.withValues(alpha: 0.05),
        borderRadius:
        BorderRadius.circular(Responsive.radius(context) * 1.5),
      ),
      child: Row(children: [
        _modeTab("Study", !_isBreak, color, text),
        _modeTab("Break", _isBreak,  color, text),
      ]),
    );
  }

  Widget _modeTab(
      String label, bool active, ColorScheme color, TextTheme text) {
    return Expanded(
      child: GestureDetector(
        onTap: () { if (!active) _switchMode(); },
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: Responsive.spacing(context) * 0.625),
          decoration: BoxDecoration(
            color: active ? color.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(
                Responsive.radius(context) * 1.25),
          ),
          child: Center(
            child: Text(label,
                style: text.labelLarge?.copyWith(
                    color: active
                        ? color.onPrimary
                        : color.onSurface.withValues(alpha: 0.4),
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  // for timer displaying
  Widget _buildTimerDisplay(ColorScheme color, TextTheme text) {
    final timerSize    = Responsive.isMobile(context)
        ? Responsive.width(context) * 0.72
        : 340.0;
    final progressSize = timerSize * 0.88;

    return Container(
      width: timerSize, height: timerSize,
      decoration: BoxDecoration(
        color:  color.surface.withValues(alpha: 0.4),
        shape:  BoxShape.circle,
        border: Border.all(color: color.surface, width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: progressSize, height: progressSize,
            child: CircularProgressIndicator(
              value: _totalSeconds > 0
                  ? _secondsRemaining / _totalSeconds
                  : 0,
              strokeWidth: 10,
              backgroundColor: color.primary.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color.primary),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_isBreak ? "BREAK" : "FOCUS",
                  style: text.labelLarge?.copyWith(
                      color: color.primary,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w900)),
              FittedBox(
                child: Text(_formatTime(_secondsRemaining),
                    style: text.displayLarge?.copyWith(
                        color: color.onSurface,
                        fontWeight: FontWeight.w300)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // this is adjust button
  Widget _buildAdjustBtn(ColorScheme color, TextTheme text) {
    return InkWell(
      onTap: () => _showDurationDialog(color, text),
      borderRadius:
      BorderRadius.circular(Responsive.radius(context) * 1.5),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: Responsive.spacing(context) * 1.25,
            vertical:   Responsive.spacing(context) * 0.75),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius:
          BorderRadius.circular(Responsive.radius(context) * 1.5),
          border: Border.all(
              color: color.primary.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined,
                size: Responsive.smallIcon(context), color: color.primary),
            SizedBox(width: Responsive.spacing(context) * 0.5),
            Text(_isBreak ? "set break duration" : "set study duration",
                style: text.labelLarge?.copyWith(
                    color: color.onSurface.withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }

  // it is duration dialog operation
  void _showDurationDialog(ColorScheme color, TextTheme text) {
    final ctrl = TextEditingController(
        text: (_isBreak ? _breakMinutes : _studyMinutes).toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: color.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(Responsive.radius(context)))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left:   Responsive.pagePadding(context),
          right:  Responsive.pagePadding(context),
          top:    Responsive.spacing(context) * 1.25,
          bottom: MediaQuery.of(ctx).viewInsets.bottom +
              Responsive.sectionSpacing(context) * 1.5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Adjust Duration",
                style: text.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: Responsive.spacing(context) * 1.25),
            TextField(
              controller:      ctrl,
              keyboardType:    TextInputType.number,
              textAlign:       TextAlign.center,
              autofocus:       true,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: text.displayMedium?.copyWith(color: color.primary),
              decoration: InputDecoration(
                suffixText: "min",
                filled:     true,
                fillColor:  color.primary.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        Responsive.cardRadius(context)),
                    borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: Responsive.sectionSpacing(context) * 1.5),
            SizedBox(
              width: double.infinity,
              height: Responsive.buttonHeight(context),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color.primary,
                  foregroundColor: color.onPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          Responsive.cardRadius(context))),
                ),
                onPressed: () {
                  final val = int.tryParse(ctrl.text) ?? 25;
                  setState(() {
                    if (_isBreak) {
                      _breakMinutes = val.clamp(1, 60);
                    } else {
                      _studyMinutes = val.clamp(1, 120);
                    }
                    _totalSeconds     =
                        (_isBreak ? _breakMinutes : _studyMinutes) * 60;
                    _secondsRemaining = _totalSeconds;
                    _isRunning        = false;
                    _studySecondsCompleted = 0;
                  });
                  _timer?.cancel();
                  Navigator.pop(context);
                },
                child: Text("SAVE",
                    style: text.labelLarge?.copyWith(
                        color: color.onPrimary,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // for control part
  Widget _buildControls(ColorScheme color) {
    final mainBtnSize = Responsive.buttonHeight(context) * 1.1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _miniBtn(Icons.refresh_rounded,   color, _resetTimer),
        SizedBox(width: Responsive.sectionSpacing(context)),
        GestureDetector(
          onTap: _toggleTimer,
          child: Container(
            width: mainBtnSize, height: mainBtnSize,
            decoration: BoxDecoration(
              color: color.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.primary.withValues(alpha: 0.3),
                  blurRadius: Responsive.spacing(context) * 1.25,
                  offset: Offset(0, Responsive.spacing(context) * 0.5),
                ),
              ],
            ),
            child: Icon(
              _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: color.onPrimary,
              size: mainBtnSize * 0.5,
            ),
          ),
        ),
        SizedBox(width: Responsive.sectionSpacing(context)),
        _miniBtn(Icons.skip_next_rounded, color, _switchMode),
      ],
    );
  }

  Widget _miniBtn(IconData icon, ColorScheme color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(Responsive.radius(context) * 2.5),
      child: Container(
        padding: EdgeInsets.all(Responsive.spacing(context) * 0.875),
        decoration: BoxDecoration(
          color: color.surface,
          shape: BoxShape.circle,
          border: Border.all(
              color: color.primary.withValues(alpha: 0.2)),
        ),
        child: Icon(icon,
            color: color.onSurface.withValues(alpha: 0.6),
            size: Responsive.icon(context)),
      ),
    );
  }

  // for helpers, it just shows how we can see
  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }
}