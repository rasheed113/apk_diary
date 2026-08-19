import 'dart:async';
import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/material.dart' hide Icon;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'modern_icons.dart';
import 'dashboard_page.dart';
import 'finance_page.dart';
import 'history_page.dart';
import 'settings_page.dart';
import 'work_page.dart';
import 'theme_manager.dart';
import 'app_theme_controller.dart';
import 'database_helper.dart';
import 'i18n/app_localization.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  final savedTheme = await DatabaseHelper.instance.getTheme();
  AppThemeController.currentTheme.value = AppTheme.values.firstWhere((e) => e.name == savedTheme, orElse: () => AppTheme.classicLight);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.english();
    return ValueListenableBuilder<AppTheme>(
      valueListenable: AppThemeController.currentTheme,
      builder: (context, theme, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: localization.appName,
        theme: ThemeManager.getTheme(theme),
        home: const SplashScreen(),
      ),
    );
  }
}

/// Fresh cinematic startup. This intentionally does not reuse the previous
/// logo-first splash, fixed-pixel credit travel, or old star/rocket animation.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animation;
  late final Animation<double> _credits;
  late final Animation<double> _objects;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _credits = CurvedAnimation(parent: _animation, curve: Curves.easeInOutCubic);
    _objects = CurvedAnimation(parent: _animation, curve: Curves.easeInOut);
    _animation.forward();
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      }
    });
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  Widget _depthText(String text, {double size = 20, bool hero = false}) {
    final face = hero ? const Color(0xFFF7FDFF) : const Color(0xFFE8F8FF);
    final glow = hero ? const Color(0xFF45E8FF) : const Color(0xFF79DFFF);
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: const Offset(5, 7),
          child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: size, fontWeight: FontWeight.w900, letterSpacing: hero ? 2.8 : 1.0, color: const Color(0xFF06101A), shadows: [Shadow(color: glow.withValues(alpha: .85), blurRadius: 12)])),
        ),
        Transform.translate(
          offset: const Offset(2.5, 3.5),
          child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: size, fontWeight: FontWeight.w900, letterSpacing: hero ? 2.8 : 1.0, color: const Color(0xFF1D7188))),
        ),
        Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: size, fontWeight: FontWeight.w900, letterSpacing: hero ? 2.8 : 1.0, color: face, shadows: [Shadow(color: glow, blurRadius: 8), const Shadow(color: Colors.white, blurRadius: 1, offset: Offset(-1, -1))])),
      ],
    );
  }

  Widget _scrollingCredits(double h) {
    const contentHeight = 1030.0;
    final travel = h + contentHeight;
    return AnimatedBuilder(
      animation: _credits,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _depthText('WORK EARN', size: 42, hero: true),
          const SizedBox(height: 3),
          _depthText('APP', size: 30, hero: true),
          const SizedBox(height: 48),
          _depthText('Produced by', size: 18),
          const SizedBox(height: 8),
          _depthText('ERGS Dynamics Foundation Technology', size: 22, hero: true),
          const SizedBox(height: 52),
          _depthText('Founder', size: 18),
          const SizedBox(height: 8),
          _depthText('Rasheed Afridi', size: 29, hero: true),
          const SizedBox(height: 54),
          _depthText('Thanks for using', size: 18),
          const SizedBox(height: 8),
          _depthText('Work Earn App', size: 28, hero: true),
          const SizedBox(height: 38),
          _depthText('Track your jobs.', size: 20),
          const SizedBox(height: 10),
          _depthText('Track your payments.', size: 20),
          const SizedBox(height: 10),
          _depthText('Save your working journey.', size: 20),
          const SizedBox(height: 70),
        ],
      ),
      builder: (context, child) {
        final y = h - _credits.value * travel;
        return Transform.translate(offset: Offset(0, y), child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01030A),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          return ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                const _DarkSky(),
                AnimatedBuilder(
                  animation: _objects,
                  builder: (context, child) => CustomPaint(painter: _CinematicObjectsPainter(progress: _objects.value, width: w, height: h)),
                ),
                Positioned.fill(child: _scrollingCredits(h)),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withValues(alpha: .08), Colors.transparent, Colors.black.withValues(alpha: .25)]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DarkSky extends StatelessWidget {
  const _DarkSky();
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(center: Alignment(0, -.35), radius: 1.15, colors: [Color(0xFF0D1730), Color(0xFF040711), Color(0xFF000105)]),
      ),
      child: CustomPaint(painter: _AtmospherePainter()),
    );
  }
}

class _AtmospherePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()..shader = RadialGradient(colors: [const Color(0xFF123A66).withValues(alpha: .22), Colors.transparent]).createShader(Rect.fromCircle(center: Offset(size.width * .5, size.height * .32), radius: size.width * .72));
    canvas.drawRect(Offset.zero & size, glow);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CinematicObjectsPainter extends CustomPainter {
  final double progress;
  final double width;
  final double height;
  _CinematicObjectsPainter({required this.progress, required this.width, required this.height});

  @override
  void paint(Canvas canvas, Size size) {
    _paintMoon(canvas, size);
    _paintStars(canvas, size);
    _paintRocket(canvas, size);
    _paintBackgroundBrand(canvas, size);
  }

  void _paintMoon(Canvas canvas, Size size) {
    final centre = Offset(size.width * .84, size.height * .13);
    final r = math.min(size.width, size.height) * .055;
    final glow = Paint()..shader = RadialGradient(colors: [const Color(0xFFBEEFFF).withValues(alpha: .34), Colors.transparent]).createShader(Rect.fromCircle(center: centre, radius: r * 2.5));
    canvas.drawCircle(centre, r * 2.5, glow);
    final moon = Paint()..shader = RadialGradient(center: const Alignment(-.35, -.4), colors: [Colors.white, const Color(0xFF9BD8F2), const Color(0xFF4D718A)]).createShader(Rect.fromCircle(center: centre, radius: r));
    canvas.drawCircle(centre, r, moon);
    final shade = Paint()..color = const Color(0xFF20364A).withValues(alpha: .22);
    canvas.drawCircle(centre.translate(r * .28, -r * .08), r * .72, shade);
  }

  void _paintStars(Canvas canvas, Size size) {
    final stars = <List<double>>[
      [.12, .18, 8, .03], [.28, .10, 5, .22], [.46, .20, 7, .41], [.67, .12, 6, .63], [.92, .25, 8, .76],
      [.08, .42, 5, .15], [.23, .55, 7, .53], [.48, .46, 5, .82], [.72, .58, 8, .35], [.91, .70, 5, .68],
      [.16, .80, 6, .48], [.40, .74, 8, .12], [.62, .84, 5, .91], [.84, .88, 7, .27],
    ];
    for (final s in stars) {
      final phase = (progress + s[3]) % 1.0;
      final x = (s[0] * size.width - phase * size.width * .10 + size.width) % size.width;
      final y = (s[1] * size.height + phase * size.height * .12) % size.height;
      final radius = s[2] * .5;
      final glow = Paint()..shader = RadialGradient(colors: [Colors.white.withValues(alpha: .95), const Color(0xFF69E8FF).withValues(alpha: .55), Colors.transparent]).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius * 3.5));
      canvas.drawCircle(Offset(x, y), radius * 3.5, glow);
      final core = Paint()..shader = RadialGradient(colors: [Colors.white, const Color(0xFF8CEEFF), const Color(0xFF5B6EFF)]).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius));
      canvas.drawCircle(Offset(x, y), radius, core);
    }
  }

  void _paintRocket(Canvas canvas, Size size) {
    final p = Curves.easeInOutCubic.transform(progress);
    final start = Offset(size.width * .08, size.height * .78);
    final end = Offset(size.width * .78, size.height * .18);
    final pos = Offset(Offset.lerp(start, end, p)!.dx, Offset.lerp(start, end, p)!.dy);
    final angle = -.72;
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);
    final trail = Paint()..shader = LinearGradient(colors: [const Color(0xFFFFE76B).withValues(alpha: .9), const Color(0xFFFF7A3D).withValues(alpha: .55), Colors.transparent]).createShader(const Rect.fromLTWH(-80, -12, 90, 24));
    canvas.drawOval(const Rect.fromLTWH(-78, -8, 82, 16), trail);
    final body = Paint()..shader = LinearGradient(colors: [Colors.white, const Color(0xFF9DEBFF), const Color(0xFF3A6A93)]).createShader(const Rect.fromLTWH(-24, -12, 48, 24));
    canvas.drawOval(const Rect.fromLTWH(-25, -12, 48, 24), body);
    final nose = Path()..moveTo(23, 0)..quadraticBezierTo(8, -11, 4, -10)..quadraticBezierTo(12, 0, 4, 10)..quadraticBezierTo(8, 11, 23, 0)..close();
    canvas.drawPath(nose, body);
    final window = Paint()..shader = RadialGradient(colors: [Colors.white, const Color(0xFF39D9FF), const Color(0xFF2450A0)]).createShader(const Rect.fromCircle(center: Offset(5, -2), radius: 6));
    canvas.drawCircle(const Offset(5, -2), 6, window);
    final fin = Paint()..color = const Color(0xFFB84BFF);
    canvas.drawPath(Path()..moveTo(-9, 8)..lineTo(-18, 17)..lineTo(2, 10)..close(), fin);
    canvas.restore();
  }

  void _paintBackgroundBrand(Canvas canvas, Size size) {
    final painter = TextPainter(textDirection: TextDirection.ltr, text: const TextSpan(text: 'ERGS DYNAMICS FOUNDATION TECHNOLOGY', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2.2, color: Color(0xFF18314A))));
    painter.layout(maxWidth: size.width * .92);
    painter.paint(canvas, Offset((size.width - painter.width) / 2, size.height * .42));
  }

  @override
  bool shouldRepaint(covariant _CinematicObjectsPainter oldDelegate) => oldDelegate.progress != progress || oldDelegate.width != width || oldDelegate.height != height;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  final List<Widget> pages = [const DashboardPage(), const WorkPage(embedded: true), const HistoryPage(), const FinancePage(), const SettingsPage()];
  Widget nav3D(IconData icon) => Icon(icon, size: 20);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l = AppLocalization.english();
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: t.cardColor, border: Border.all(color: t.colorScheme.primary.withValues(alpha: .20)), boxShadow: [BoxShadow(color: t.colorScheme.primary.withValues(alpha: .10), blurRadius: 9, offset: const Offset(0, 3))]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBar(
            height: 64,
            elevation: 0,
            backgroundColor: t.cardColor,
            indicatorColor: t.colorScheme.primary.withValues(alpha: .12),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            selectedIndex: selectedIndex,
            destinations: [
              NavigationDestination(icon: nav3D(Icons.dashboard), label: l.dashboard),
              NavigationDestination(icon: nav3D(Icons.work), label: l.work),
              NavigationDestination(icon: nav3D(Icons.history), label: l.history),
              NavigationDestination(icon: nav3D(Icons.account_balance_wallet), label: l.finance),
              NavigationDestination(icon: nav3D(Icons.settings), label: l.settings),
            ],
            onDestinationSelected: (index) => setState(() => selectedIndex = index),
          ),
        ),
      ),
    );
  }
}
