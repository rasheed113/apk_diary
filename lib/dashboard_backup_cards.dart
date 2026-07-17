import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'database_helper.dart';
import 'work_page.dart';
import 'history_page.dart';
import 'finance_page.dart';
import 'settings_page.dart';
import 'package:marquee/marquee.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int totalEntries = 0;
  int totalPieces = 0;
  double currentBalance = 0;
  double totalEarning = 0;
  double todayEarning = 0;
  double weeklyEarning = 0;
  double monthlyEarning = 0;
  String operatorName = 'Operator';
  String userId = 'APK-LOCAL-001';
  String greeting = '';
  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  String? profileImage;
  String tickerMessage = '';

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    final balance = await DatabaseHelper.instance.getBalance();
    final entries = await DatabaseHelper.instance.getTotalEntries();
    final pieces = await DatabaseHelper.instance.getTotalPieces();
    final earning = await DatabaseHelper.instance.getTotalEarning();
    final today = await DatabaseHelper.instance.getTodayEarning();
    final weekly = await DatabaseHelper.instance.getWeeklyEarning();
    final monthly = await DatabaseHelper.instance.getMonthlyEarning();
    final profile = await DatabaseHelper.instance.getProfile();

    if (!mounted) return;
    setState(() {
      currentBalance = balance;
      totalEntries = entries;
      totalPieces = pieces;
      totalEarning = earning;
      todayEarning = today;
      weeklyEarning = weekly;
      monthlyEarning = monthly;
      operatorName = profile?['operator_name'] ?? 'Operator';
      userId = profile?['user_id'] ?? 'APK-LOCAL-001';
      profileImage = profile?['profile_image'];
      greeting = getGreeting();
      tickerMessage = getTickerMessage();
    });
  }

  String getTickerMessage() {
    if (totalEarning <= 0) {
      return "🚀 Welcome to APK Diary Pro • Add your first work entry today";
    }

    if (todayEarning > 0) {
      return "💰 Today: Rs ${todayEarning.toStringAsFixed(0)} • 📅 Week: Rs ${weeklyEarning.toStringAsFixed(0)} • 🏆 Month: Rs ${monthlyEarning.toStringAsFixed(0)}";
    }

    return "📅 Week: Rs ${weeklyEarning.toStringAsFixed(0)} • 🏆 Month: Rs ${monthlyEarning.toStringAsFixed(0)} • 💼 Total: Rs ${totalEarning.toStringAsFixed(0)}";
  }

  double tickerPosition = 1.0;
  Timer? tickerTimer;
  @override
  void dispose() {
    tickerTimer?.cancel();
    super.dispose();
  }

  Widget buildCard({
    required String title,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.85, end: 1),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Card(
        elevation: 20,
        color: Theme.of(context).cardColor,
        shadowColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.35),
            width: 3,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: Icon(icon, size: 36, color: Colors.black),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        value,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 20,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.5),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
        ),
        title: const Text(
          "APK DIARY PRO ⚡",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 28,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: loadDashboard,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 38,
                    backgroundImage:
                        profileImage != null && profileImage!.isNotEmpty
                        ? FileImage(File(profileImage!))
                        : null,
                    child: profileImage == null || profileImage!.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(
                    'Welcome, $operatorName 👋',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        'ID: $userId',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Card(
                elevation: 20,
                shadowColor: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.9),
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Marquee(
                    text: tickerMessage.isEmpty
                        ? "🚀 Welcome to APK Diary"
                        : tickerMessage,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                    scrollAxis: Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    blankSpace: 60,
                    velocity: 32,
                    pauseAfterRound: const Duration(seconds: 1),
                    startPadding: 20,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        elevation: 20,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const WorkPage()),
                        );

                        if (result == true) {
                          loadDashboard();
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('New Entry'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        elevation: 20,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HistoryPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.history),
                      label: const Text('History'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        elevation: 20,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FinancePage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.account_balance_wallet),
                      label: const Text('Finance'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        elevation: 20,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings),
                      label: const Text('Settings'),
                    ),
                  ),
                ],
              ),

              buildCard(
                title: 'Current Balance',
                value: 'Rs. ${currentBalance.toStringAsFixed(2)}',
                icon: Icons.account_balance_wallet,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FinancePage()),
                  );
                },
              ),
              buildCard(
                title: 'Total Entries',
                value: totalEntries.toString(),
                icon: Icons.list_alt,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryPage()),
                  );
                },
              ),
              buildCard(
                title: 'Total Pieces',
                value: totalPieces.toString(),
                icon: Icons.inventory_2,
              ),
              buildCard(
                title: 'Total Earnings',
                value: 'Rs. ${totalEarning.toStringAsFixed(2)}',
                icon: Icons.payments,
              ),
              buildCard(
                title: "Today's Earnings",
                value: 'Rs. ${todayEarning.toStringAsFixed(2)}',
                icon: Icons.today,
              ),
              buildCard(
                title: 'Weekly Earnings',
                value: 'Rs. ${weeklyEarning.toStringAsFixed(2)}',
                icon: Icons.calendar_view_week,
              ),

              buildCard(
                title: 'Monthly Earnings',
                value: 'Rs. ${monthlyEarning.toStringAsFixed(2)}',
                icon: Icons.calendar_month,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
