import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edulearn/logic/providers/auth_provider.dart';
import 'package:edulearn/presentation/screens/auth_screen.dart';
import 'package:edulearn/presentation/screens/home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _dotController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );

    _fadeController.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 4000));

    if (!mounted) return;

    final isLoggedIn = context.read<AuthProvider>().isLoggedIn;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) =>
        isLoggedIn ? const HomeScreen() : const AuthScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;

    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final bool isTablet = size.width >= 700;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? size.width * 0.12 : 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // for image part as a logo
                    Flexible(
                      flex: 5,
                      child: Image.asset(
                        'assets/images/welcome.png',
                        width: isTablet
                            ? size.width * 0.38
                            : size.width * 0.72,
                        fit: BoxFit.contain,
                      ),
                    ),

                    SizedBox(height: isTablet ? 42 : 32),

                    // this is title part which is app name
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Edu",
                            style: (isTablet
                                ? text.displayMedium
                                : text.displaySmall)
                                ?.copyWith(
                              color: color.onSurface,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          TextSpan(
                            text: "Learn",
                            style: (isTablet
                                ? text.displayMedium
                                : text.displaySmall)
                                ?.copyWith(
                              color: color.primary,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // subtitle part (slogan)
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isTablet ? 500 : double.infinity,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 0 : 10,
                        ),
                        child: Text(
                          '"Track your courses, crush your deadlines,\nand focus like never before."',
                          textAlign: TextAlign.center,
                          style: (isTablet
                              ? text.titleMedium
                              : text.bodyMedium)
                              ?.copyWith(
                            color:
                            color.onSurface.withValues(alpha: 0.5),
                            fontStyle: FontStyle.italic,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 2),

                    // LOADER
                    _buildDotLoader(color.primary),

                    SizedBox(height: isTablet ? 70 : 50),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDotLoader(Color primaryColor) {
    return AnimatedBuilder(
      animation: _dotController,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index / 3;

            final value =
            ((_dotController.value - delay) % 1.0);

            final scale = value < 0.5
                ? 0.6 + (value / 0.5) * 0.6
                : 1.2 - ((value - 0.5) / 0.5) * 0.6;

            final opacity = value < 0.5
                ? 0.3 + (value / 0.5) * 0.7
                : 1.0 - ((value - 0.5) / 0.5) * 0.7;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                MediaQuery.of(context).size.width >= 700
                    ? 8
                    : 5,
              ),
              child: Transform.scale(
                scale: scale.clamp(0.6, 1.2),
                child: Opacity(
                  opacity: opacity.clamp(0.3, 1.0),
                  child: Container(
                    width:
                    MediaQuery.of(context).size.width >= 700
                        ? 10
                        : 8,
                    height:
                    MediaQuery.of(context).size.width >= 700
                        ? 10
                        : 8,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}