import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/language_service.dart';
import '../screens/auth_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _bgController;
  late AnimationController _slideController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _bgRotate;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
        vsync: this, duration: const Duration(seconds: 20))
      ..repeat();
    _bgRotate =
        Tween<double>(begin: 0, end: 2 * pi).animate(_bgController);

    _logoController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _logoController, curve: const Interval(0.0, 0.5)));

    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _slideUp = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _slideController, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 300), () {
      _logoController.forward();
      Future.delayed(const Duration(milliseconds: 600),
          () => _slideController.forward());
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _bgController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ls = Provider.of<LanguageService>(context);
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _bgRotate,
            builder: (_, __) => Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF002623), Color(0xFF054239), Color(0xFF002623)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: CustomPaint(
                  painter: _BgCirclePainter(_bgRotate.value)),
            ),
          ),

          // Language toggle top-right
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: ls.toggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                          color: AppTheme.primaryAccent.withOpacity(0.4)),
                    ),
                    child: Text(
                      ls.isArabic ? 'English' : 'العربية',
                      style: const TextStyle(
                          color: AppTheme.primaryAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo
                ScaleTransition(
                  scale: _logoScale,
                  child: FadeTransition(
                    opacity: _logoOpacity,
                    child: Column(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(colors: [
                              AppTheme.primaryAccent,
                              AppTheme.primaryDark,
                            ]),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryAccent.withOpacity(0.6),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.traffic_rounded,
                              size: 60, color: Colors.white),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          ls.t('city'),
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: AppTheme.primaryAccent.withOpacity(0.5),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color:
                                    AppTheme.primaryAccent.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            ls.t('system_name'),
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppTheme.textSecondary,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Status dots
                FadeTransition(
                  opacity: _logoOpacity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _dot(ls.t('clear'), AppTheme.normal),
                      const SizedBox(width: 20),
                      _dot(ls.t('moderate'), AppTheme.warning),
                      const SizedBox(width: 20),
                      _dot(ls.t('heavy'), AppTheme.danger),
                      const SizedBox(width: 20),
                      _dot(ls.t('closed'), AppTheme.closed),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                FadeTransition(
                  opacity: _logoOpacity,
                  child: Text(
                    ls.t('tagline'),
                    style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        letterSpacing: 0.5),
                  ),
                ),

                const Spacer(),

                // Buttons
                SlideTransition(
                  position: _slideUp,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _primaryButton(
                          label: ls.t('get_started'),
                          onTap: () => Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, a, __) =>
                                  const BottomNavBar(),
                              transitionsBuilder: (_, a, __, child) =>
                                  FadeTransition(opacity: a, child: child),
                              transitionDuration:
                                  const Duration(milliseconds: 400),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _secondaryButton(
                          label: ls.t('sign_in'),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AuthScreen()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(String label, Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)
              ],
            ),
          ),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 11)),
        ],
      );

  Widget _primaryButton({required String label, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppTheme.primaryAccent, AppTheme.primaryDark]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.primaryAccent.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8))
            ],
          ),
          child: Center(
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      );

  Widget _secondaryButton(
          {required String label, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppTheme.primaryAccent.withOpacity(0.4)),
          ),
          child: Center(
            child: Text(label,
                style: const TextStyle(
                    color: AppTheme.primaryAccent,
                    fontSize: 17,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      );
}

class _BgCirclePainter extends CustomPainter {
  final double angle;
  _BgCirclePainter(this.angle);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke;
    final cx = size.width / 2 + cos(angle) * 30;
    final cy = size.height / 2 + sin(angle) * 30;
    for (int i = 1; i <= 4; i++) {
      paint.color = AppTheme.primaryAccent.withOpacity(0.03 * i);
      paint.strokeWidth = 1.5;
      canvas.drawCircle(Offset(cx, cy), size.width * 0.3 * i, paint);
    }
    paint.color = AppTheme.primaryAccent.withOpacity(0.07);
    paint.strokeWidth = 1;
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(size.width * 0.15, size.height * 0.3),
          width: size.width * 0.7,
          height: size.width * 0.7),
      angle, pi, false, paint,
    );
  }

  @override
  bool shouldRepaint(_BgCirclePainter old) => old.angle != angle;
}
