import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'dashboard_page.dart';
import 'finance_page.dart';
import 'history_page.dart';
import 'settings_page.dart';
import 'work_page.dart';
import 'theme_manager.dart';

void main() {
  if (Platform.isLinux ||
      Platform.isWindows ||
      Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final ValueNotifier<AppTheme> currentTheme =
      ValueNotifier(AppTheme.shadowDark);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppTheme>(
      valueListenable: MyApp.currentTheme,
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
  State<HomePage> createState() =>
      _HomePageState();
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

        selectedIndex: selectedIndex,

        destinations: const [

          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),

          NavigationDestination(
            icon: Icon(Icons.work),
            label: 'Work',
          ),

          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),

          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Finance',
          ),

          NavigationDestination(
            icon: Icon(Icons.settings),
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
