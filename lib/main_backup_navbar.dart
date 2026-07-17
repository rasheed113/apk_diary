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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final savedTheme = await DatabaseHelper.instance.getTheme();

  AppThemeController.currentTheme.value = AppTheme.values.firstWhere(
    (e) => e.name == savedTheme,
    orElse: () => AppTheme.shadowDark,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppTheme>(
      valueListenable: AppThemeController.currentTheme,
      builder: (context, theme, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'APK Diary',

          theme: ThemeManager.getTheme(theme),

          home: const HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    DashboardPage(),
    WorkPage(),
    HistoryPage(),
    FinancePage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],

      bottomNavigationBar: NavigationBar(
        height: 75,
        elevation: 20,
        backgroundColor: Theme.of(context).cardColor,
        indicatorColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.25),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: selectedIndex,

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard, size: 30),
            label: 'Dashboard',
          ),

          NavigationDestination(
            icon: Icon(Icons.work, size: 30),
            label: 'Work',
          ),

          NavigationDestination(
            icon: Icon(Icons.history, size: 30),
            label: 'History',
          ),

          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet, size: 30),
            label: 'Finance',
          ),

          NavigationDestination(
            icon: Icon(Icons.settings, size: 30),
            label: 'Settings',
          ),
        ],

        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}
