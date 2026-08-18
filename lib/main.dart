import 'dart:async';
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
import 'i18n/app_strings.dart';
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // English remains the safe default until the language-selection UI is wired.
  static const AppLanguage _language = AppLanguage.english;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<AppTheme>(
    valueListenable: AppThemeController.currentTheme,
    builder: (context, theme, child) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      locale: _language.locale,
      supportedLocales: AppLanguage.values.map((language) => language.locale).toList(growable: false),
      theme: ThemeManager.getTheme(theme),
      builder: (context, child) => Directionality(
        textDirection: _language.textDirection,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const SplashScreen(),
    ),
  );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    Timer(const Duration(milliseconds: 2300), () {
      if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    });
  }

  @override void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [s.surface, s.primary.withValues(alpha: .12)])),
        child: Center(child: FadeTransition(opacity: _fade, child: ScaleTransition(scale: _scale, child: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.asset('assets/branding/workearn_logo.png', width: 170, height: 170, fit: BoxFit.contain),
          const SizedBox(height: 22),
          Text(AppStrings.workEarn, style: TextStyle(color: s.primary, fontSize: 25, fontWeight: FontWeight.w900, letterSpacing: 2.2, shadows: [Shadow(color: s.primary.withValues(alpha: .28), blurRadius: 5, offset: const Offset(1, 2)), const Shadow(color: Colors.white70, blurRadius: 2, offset: Offset(-1, -1))])),
          const SizedBox(height: 10),
          Text(AppStrings.foundation, textAlign: TextAlign.center, style: TextStyle(color: s.onSurface, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .65)),
          const SizedBox(height: 3),
          Text(AppStrings.founder, style: TextStyle(color: s.onSurface.withValues(alpha: .82), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: .35)),
        ]))))),
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
  Widget nav3D(IconData icon) => Icon(icon, size: 20);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: t.cardColor, border: Border.all(color: t.colorScheme.primary.withValues(alpha: .20)), boxShadow: [BoxShadow(color: t.colorScheme.primary.withValues(alpha: .10), blurRadius: 9, offset: const Offset(0, 3))]),
        child: ClipRRect(borderRadius: BorderRadius.circular(24), child: NavigationBar(
          height: 64, elevation: 0, backgroundColor: t.cardColor, indicatorColor: t.colorScheme.primary.withValues(alpha: .12), labelBehavior: NavigationDestinationLabelBehavior.alwaysShow, selectedIndex: selectedIndex,
          destinations: [
            NavigationDestination(icon: nav3D(Icons.dashboard), label: AppStrings.dashboard),
            NavigationDestination(icon: nav3D(Icons.work), label: AppStrings.work),
            NavigationDestination(icon: nav3D(Icons.history), label: AppStrings.history),
            NavigationDestination(icon: nav3D(Icons.account_balance_wallet), label: AppStrings.finance),
            NavigationDestination(icon: nav3D(Icons.settings), label: AppStrings.settings),
          ],
          onDestinationSelected: (index) => setState(() => selectedIndex = index),
        )),
      ),
    );
  }
}
