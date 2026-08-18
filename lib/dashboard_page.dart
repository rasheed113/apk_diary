<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'dart:io';
=======
import 'dart:ui';
import 'package:flutter/material.dart';
>>>>>>> b33fc891b41294cee9c240ffee4426ebc16fdd0f
import 'dart:async';
import 'database_helper.dart';
import 'work_page.dart';
import 'history_page.dart';
import 'finance_page.dart';
import 'settings_page.dart';
import 'package:marquee/marquee.dart';
<<<<<<< HEAD
=======
import 'profile_header_card.dart';
>>>>>>> b33fc891b41294cee9c240ffee4426ebc16fdd0f

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
<<<<<<< HEAD
  String tickerMessage = '';
  Timer? dailyRefreshTimer;
=======
  String? coverImage;
  String tickerMessage = '';
>>>>>>> b33fc891b41294cee9c240ffee4426ebc16fdd0f

  @override
  void initState() {
    super.initState();
    loadDashboard();
<<<<<<< HEAD
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
=======
>>>>>>> b33fc891b41294cee9c240ffee4426ebc16fdd0f
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
<<<<<<< HEAD
=======
      coverImage = profile?['cover_image'];
>>>>>>> b33fc891b41294cee9c240ffee4426ebc16fdd0f
      greeting = getGreeting();
      tickerMessage = getTickerMessage();
    });
  }

  String getTickerMessage() {
<<<<<<< HEAD
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
=======
    if (totalEarning <= 0) {
      return "🚀 Welcome to APK Diary Pro • Add your first work entry today";
    }

    if (todayEarning > 0) {
      return "💰 Today: Rs ${todayEarning.toStringAsFixed(0)} • 📅 Week: Rs ${weeklyEarning.toStringAsFixed(0)} • 🏆 Month: Rs ${monthlyEarning.toStringAsFixed(0)}";
    }

    return "📅 Week: Rs ${weeklyEarning.toStringAsFixed(0)} • 🏆 Month: Rs ${monthlyEarning.toStringAsFixed(0)} • 💼 Total: Rs ${totalEarning.toStringAsFixed(0)}";
>>>>>>> b33fc891b41294cee9c240ffee4426ebc16fdd0f
  }

  double tickerPosition = 1.0;
  Timer? tickerTimer;
  @override
  void dispose() {
    tickerTimer?.cancel();
<<<<<<< HEAD
    dailyRefreshTimer?.cancel();
    super.dispose();
  }

=======
    super.dispose();
  }

  Widget buildGlowButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(double.infinity, 60),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),

        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
      ),

      onPressed: onPressed,

      icon: Icon(icon),

      label: Text(label),
    );
  }


>>>>>>> b33fc891b41294cee9c240ffee4426ebc16fdd0f
  Widget buildCard({
    required String title,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
<<<<<<< HEAD
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
=======
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Theme.of(context).cardColor.withValues(alpha: 0.5),
          border: Border.all(
            color: primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Chota aur Clean Soft Icon Background
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withValues(alpha: 0.15),
              ),
              child: Icon(
                icon,
                size: 18,
                color: primary,
              ),
            ),
            const SizedBox(width: 12),
            // Text values ekdam perfectly aligned
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: secondary.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    value,
                    style: TextStyle(
                      color: primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            fontWeight: FontWeight.w600,
            fontSize: 18,
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

              ProfileHeaderCard(
                operatorName: operatorName,
                userId: userId,
                greeting: greeting,
                profileImage: profileImage,
                coverImage: coverImage,
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
                      fontWeight: FontWeight.w600,
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
                    child: buildGlowButton(
                      icon: Icons.add,
                      label: 'New Entry',
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const WorkPage()),
                        );

                        if (result == true) {
                          loadDashboard();
                        }
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: buildGlowButton(
                      icon: Icons.history,
                      label: 'History',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HistoryPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: buildGlowButton(
                      icon: Icons.account_balance_wallet,
                      label: 'Finance',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FinancePage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: buildGlowButton(
                      icon: Icons.settings,
                      label: 'Settings',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              /*

                      style: ElevatedButton.styleFrom(
                        elevation: 20,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
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
                          fontWeight: FontWeight.w600,
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

*/
              
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
>>>>>>> b33fc891b41294cee9c240ffee4426ebc16fdd0f
              ),
            ],
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD

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
=======
>>>>>>> b33fc891b41294cee9c240ffee4426ebc16fdd0f
}
