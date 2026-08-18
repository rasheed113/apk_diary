import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dashboard_page.dart';
import 'finance_page.dart';
import 'history_page.dart';
import 'settings_page.dart';
import 'work_page.dart';
import 'theme_manager.dart';
import 'app_theme_controller.dart';
import 'database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  final savedTheme = await DatabaseHelper.instance.getTheme();
  AppThemeController.currentTheme.value = AppTheme.values.firstWhere(
    (e) => e.name == savedTheme,
    orElse: () => AppTheme.classicLight,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override Widget build(BuildContext context) {
    return ValueListenableBuilder<AppTheme>(
      valueListenable: AppThemeController.currentTheme,
      builder: (context, theme, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'WorkEarn',
        theme: ThemeManager.getTheme(theme),
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    Timer(const Duration(milliseconds: 2300), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      }
    });
  }

  @override void dispose() { _controller.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [s.surface, s.primary.withValues(alpha: .18)]),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(colors: [s.primary, s.secondary]),
                      border: Border.all(color: Colors.white.withValues(alpha: .35)),
                      boxShadow: [BoxShadow(color: s.primary.withValues(alpha: .42), blurRadius: 28, offset: const Offset(0, 10))],
                    ),
                    child: Image.asset('assets/branding/workearn_logo.png', width: 150, height: 150, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 22),
                  Text('WORK EARN', style: TextStyle(color: s.primary, fontSize: 25, fontWeight: FontWeight.w900, letterSpacing: 2.2, shadows: [Shadow(color: s.primary.withValues(alpha: .45), blurRadius: 7, offset: const Offset(2, 3)), const Shadow(color: Colors.white70, blurRadius: 2, offset: Offset(-1, -1))])),
                  const SizedBox(height: 10),
                  Text('by ERGS Dynamics Technology Foundation', textAlign: TextAlign.center, style: TextStyle(color: s.onSurface, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .65, shadows: const [Shadow(color: Colors.black38, blurRadius: 1.5, offset: Offset(1, 1.5))])),
                  const SizedBox(height: 3),
                  Text('(Founder Rasheed Afridi)', style: TextStyle(color: s.onSurface.withValues(alpha: .82), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: .35, shadows: const [Shadow(color: Colors.black26, blurRadius: 1, offset: Offset(.8, 1))])),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  final List<Widget> pages = const [DashboardPage(), WorkPage(), HistoryPage(), FinancePage(), SettingsPage()];

  Widget nav3D(IconData icon) {
    final c = Theme.of(context).colorScheme.primary;
    return Stack(alignment: Alignment.center, children: [
      Icon(icon, size: 24, color: Colors.black.withValues(alpha: .20)),
      Transform.translate(offset: const Offset(-.6, -.6), child: Icon(icon, size: 22, color: Colors.white.withValues(alpha: .75))),
      Transform.translate(offset: const Offset(.6, .8), child: Icon(icon, size: 22, color: c)),
    ]);
  }

  @override Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 14, right: 14, bottom: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), color: t.cardColor, border: Border.all(color: t.colorScheme.primary.withValues(alpha: .22)), boxShadow: [BoxShadow(color: t.colorScheme.primary.withValues(alpha: .12), blurRadius: 10, offset: const Offset(0, 4))]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: NavigationBar(
            height: 72,
            elevation: 0,
            backgroundColor: t.cardColor,
            indicatorColor: t.colorScheme.primary.withValues(alpha: .14),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            selectedIndex: selectedIndex,
            destinations: [
              NavigationDestination(icon: nav3D(Icons.dashboard), label: 'Dashboard'),
              NavigationDestination(icon: nav3D(Icons.work), label: 'Work'),
              NavigationDestination(icon: nav3D(Icons.history), label: 'History'),
              NavigationDestination(icon: nav3D(Icons.account_balance_wallet), label: 'Finance'),
              NavigationDestination(icon: nav3D(Icons.settings), label: 'Settings'),
            ],
            onDestinationSelected: (index) => setState(() => selectedIndex = index),
          ),
        ),
      ),
    );
  }
}
