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
  Timer? dailyRefreshTimer;

  @override
  void initState() {
    super.initState();
    loadDashboard();
    _scheduleDailyRefresh();
  }

  void _scheduleDailyRefresh() {
    // Cancel any existing timer
    dailyRefreshTimer?.cancel();

    // Calculate time until 11:59:59 PM today
    final now = DateTime.now();
    final nextRefresh = DateTime(now.year, now.month, now.day, 23, 59, 59);

    // If 11:59 PM has already passed today, schedule for tomorrow
    final timeUntilRefresh = nextRefresh.isBefore(now)
        ? nextRefresh.add(const Duration(days: 1)).difference(now)
        : nextRefresh.difference(now);

    // Schedule the first refresh
    dailyRefreshTimer = Timer(timeUntilRefresh, () {
      if (mounted) {
        loadDashboard();
      }
      // Reschedule for the next day
      _scheduleDailyRefresh();
    });
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
    if (totalEarning == 0) {
      return "📝 Start your first work entry today";
    }

    if (todayEarning > 0) {
      return "🔥 Great! Today you earned Rs. ${todayEarning.toStringAsFixed(0)}";
    }

    if (totalPieces > 1000) {
      return "💪 Amazing! You completed $totalPieces pieces";
    }

    if (currentBalance < 0) {
      return "⚠️ Check your finance balance";
    }

    return "🚀 Keep working, your progress is improving";
  }

  double tickerPosition = 1.0;
  Timer? tickerTimer;
  @override
  void dispose() {
    tickerTimer?.cancel();
    dailyRefreshTimer?.cancel();
    super.dispose();
  }

  Widget buildCard({
    required String title,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE8E8E8), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: Colors.indigo),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('APK Diary Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadDashboard),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE8E8E8), width: 1),
              ),
              child: ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      profileImage != null && profileImage!.isNotEmpty
                      ? FileImage(File(profileImage!))
                      : null,
                  child: profileImage == null || profileImage!.isEmpty
                      ? const Icon(Icons.person, size: 20)
                      : null,
                ),
                title: Text(
                  'Welcome, $operatorName 👋',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(greeting, style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(
                      'ID: $userId',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.deepPurple, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.rocket_launch,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "APK DIARY BOOST 🚀",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),
                          SizedBox(
                            height: 18,
                            child: Marquee(
                              text: tickerMessage,
                              blankSpace: 80,
                              velocity: 50,
                              pauseAfterRound: const Duration(seconds: 1),
                              startPadding: 20,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE8E8E8), width: 1),
              ),
              child: SizedBox(
                height: 36,
                child: Marquee(
                  text: tickerMessage.isEmpty
                      ? "🚀 Welcome to APK Diary"
                      : tickerMessage,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  scrollAxis: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  blankSpace: 60,
                  velocity: 50,
                  pauseAfterRound: const Duration(seconds: 1),
                  startPadding: 20,
                ),
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WorkPage()),
                      );

                      if (result == true) {
                        loadDashboard();
                      }
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      'New Entry',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HistoryPage()),
                      );
                    },
                    icon: const Icon(Icons.history, size: 18),
                    label: const Text(
                      'History',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FinancePage()),
                      );
                    },
                    icon: const Icon(Icons.account_balance_wallet, size: 18),
                    label: const Text(
                      'Finance',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    },
                    icon: const Icon(Icons.settings, size: 18),
                    label: const Text(
                      'Settings',
                      style: TextStyle(fontSize: 12),
                    ),
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
    );
  }
}
