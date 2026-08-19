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
      builder: (context, theme, child) => MaterialApp(debugShowCheckedModeBanner: false, title: localization.appName, theme: ThemeManager.getTheme(theme), home: const SplashScreen()),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _creditsAnimation;

  @override
  void initState() {
    super.initState();
    // The visual animation lasts 3 seconds; the final frame is then held briefly
    // so the cinematic sequence is actually visible before entering the app.
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _fade = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.10, curve: Curves.easeOut));
    _creditsAnimation = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 1.0, curve: Curves.easeInOutCubic));
    _controller.forward();
    Timer(const Duration(seconds: 5), () {
      if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    });
  }

  @override void dispose() { _controller.dispose(); super.dispose(); }

  Widget _star(double size, double left, double top, double phase, Color color) {
    return AnimatedBuilder(animation: _controller, builder: (context, child) {
      final p = (_controller.value + phase) % 1.0;
      final x = left - p * 120;
      final y = top + p * 260;
      final twinkle = .65 + .35 * math.sin((p * math.pi * 2) + phase * 6).abs();
      return Positioned(left: x, top: y, child: Opacity(opacity: twinkle, child: Transform.rotate(angle: p * math.pi, child: child)));
    }, child: Text('✦', style: TextStyle(fontSize: size, color: color, shadows: [Shadow(color: color.withValues(alpha: .95), blurRadius: size * 1.1)])));
  }

  Widget _rocket() {
    return AnimatedBuilder(animation: _controller, builder: (context, child) {
      final p = Curves.easeInOutCubic.transform(_controller.value);
      final dx = -25 + p * 150;
      final dy = 430 - p * 500;
      return Positioned(left: dx, top: dy, child: Transform.rotate(angle: -.30, child: child));
    }, child: const Text('🚀', style: TextStyle(fontSize: 34, shadows: [Shadow(color: Colors.cyanAccent, blurRadius: 10)])));
  }

  Widget _threeDText(String text, {double size = 20, TextAlign align = TextAlign.center, bool hero = false}) {
    final face = hero ? Colors.white : const Color(0xFFEAF7FF);
    final glow = hero ? const Color(0xFF38D9FF) : const Color(0xFF66E6FF);
    return Stack(alignment: Alignment.center, children: [
      Text(text, textAlign: align, style: TextStyle(fontSize: size, fontWeight: FontWeight.w900, letterSpacing: hero ? 2.4 : .8, color: Colors.black87, shadows: [const Shadow(color: Colors.black, blurRadius: 1, offset: Offset(4, 5)), Shadow(color: glow.withValues(alpha: .8), blurRadius: 9)])),
      Text(text, textAlign: align, style: TextStyle(fontSize: size, fontWeight: FontWeight.w900, letterSpacing: hero ? 2.4 : .8, color: face, shadows: [Shadow(color: glow, blurRadius: 5), const Shadow(color: Colors.white54, blurRadius: 1, offset: Offset(-1, -1))])),
    ]);
  }

  Widget _credits(double height) {
    return AnimatedBuilder(animation: _creditsAnimation, builder: (context, child) {
      // Start just below the screen and finish just above it. The complete
      // credit stack therefore travels through the viewport instead of
      // starting halfway through and showing only the final line.
      const contentTravel = 980.0;
      final offset = height * .82 - _creditsAnimation.value * contentTravel;
      return Transform.translate(offset: Offset(0, offset), child: child);
    }, child: Column(mainAxisSize: MainAxisSize.min, children: [
      _threeDText('WORK EARN APP', size: 34, hero: true), const SizedBox(height: 55),
      _threeDText('Produced by', size: 18), const SizedBox(height: 8),
      _threeDText('ERGS Dynamics Foundation Technology', size: 21), const SizedBox(height: 48),
      _threeDText('Founder', size: 18), const SizedBox(height: 8),
      _threeDText('Rasheed Afridi', size: 27, hero: true), const SizedBox(height: 55),
      _threeDText('Keep track of your work.', size: 20), const SizedBox(height: 12),
      _threeDText('Keep track of your earnings.', size: 20), const SizedBox(height: 55),
      _threeDText('Thank you for using', size: 17), const SizedBox(height: 8),
      _threeDText('Work Earn App', size: 25, hero: true), const SizedBox(height: 80),
    ]));
  }

  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF02040A), body: LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth; final h = constraints.maxHeight;
      return ClipRect(child: Stack(children: [
        Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment(0, -.25), radius: 1.05, colors: [Color(0xFF111B35), Color(0xFF050810), Color(0xFF010205)])))),
        Positioned.fill(child: Opacity(opacity: .14, child: Image.asset('assets/branding/workearn_logo.png', fit: BoxFit.contain))),
        Positioned(top: 22, right: 24, child: Text('☾', style: TextStyle(fontSize: 58, color: const Color(0xFFEAF4FF), shadows: [Shadow(color: const Color(0xFF8EDCFF).withValues(alpha: .8), blurRadius: 24)]))),
        Positioned(top: h * .18, left: 0, right: 0, child: IgnorePointer(child: Opacity(opacity: .32, child: _threeDText('ERGS DYNAMICS', size: 31)))),
        Positioned(top: h * .235, left: 0, right: 0, child: IgnorePointer(child: Opacity(opacity: .22, child: _threeDText('FOUNDATION TECHNOLOGY', size: 18)))),
        _star(11, w * .82, -20, .03, const Color(0xFF8DEBFF)), _star(16, w * .58, 35, .21, const Color(0xFFFFE89A)), _star(9, w * .34, -10, .44, const Color(0xFFB8A7FF)), _star(14, w * .94, 170, .62, const Color(0xFF8DEBFF)), _star(8, w * .70, 260, .77, const Color(0xFFFFC8F2)), _star(12, w * .25, 180, .37, const Color(0xFFFFE89A)), _star(7, w * .50, 320, .89, const Color(0xFF8DEBFF)), _star(13, w * .08, 90, .56, const Color(0xFFB8A7FF)),
        _rocket(),
        Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: .18), Colors.black.withValues(alpha: .38)])))),
        FadeTransition(opacity: _fade, child: SizedBox(height: h, width: w, child: _credits(h))),
        Positioned.fill(child: IgnorePointer(child: DecoratedBox(decoration: BoxDecoration(border: Border.all(color: Colors.white.withValues(alpha: .04), width: 1))))),
      ]));
    }));
  }
}

class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState() => _HomePageState(); }
class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  final List<Widget> pages = [const DashboardPage(), const WorkPage(embedded: true), const HistoryPage(), const FinancePage(), const SettingsPage()];
  Widget nav3D(IconData icon) => Icon(icon, size: 20);
  @override Widget build(BuildContext context) {
    final t = Theme.of(context); final l = AppLocalization.english();
    return Scaffold(body: pages[selectedIndex], bottomNavigationBar: Container(margin: const EdgeInsets.only(left: 10, right: 10, bottom: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: t.cardColor, border: Border.all(color: t.colorScheme.primary.withValues(alpha: .20)), boxShadow: [BoxShadow(color: t.colorScheme.primary.withValues(alpha: .10), blurRadius: 9, offset: const Offset(0, 3))]), child: ClipRRect(borderRadius: BorderRadius.circular(24), child: NavigationBar(height: 64, elevation: 0, backgroundColor: t.cardColor, indicatorColor: t.colorScheme.primary.withValues(alpha: .12), labelBehavior: NavigationDestinationLabelBehavior.alwaysShow, selectedIndex: selectedIndex, destinations: [NavigationDestination(icon: nav3D(Icons.dashboard), label: l.dashboard), NavigationDestination(icon: nav3D(Icons.work), label: l.work), NavigationDestination(icon: nav3D(Icons.history), label: l.history), NavigationDestination(icon: nav3D(Icons.account_balance_wallet), label: l.finance), NavigationDestination(icon: nav3D(Icons.settings), label: l.settings)], onDestinationSelected: (index) => setState(() => selectedIndex = index))),));
  }
}
