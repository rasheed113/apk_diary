import 'dart:ui';
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
  String? coverImage;
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
      coverImage = profile?['cover_image'];
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

  Widget buildGlowButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

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

  Widget buildCard({
    required String title,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.85, end: 1),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.45),
                blurRadius: 25,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  color: Theme.of(context).cardColor.withValues(alpha: 0.75),
                  border: Border.all(
                    color: primary.withValues(alpha: 0.8),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [primary, secondary]),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.8),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: Icon(icon, size: 36, color: Colors.black),
                    ),

                    const SizedBox(width: 18),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: secondary,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            value,
                            style: TextStyle(
                              color: primary,
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                  color: primary.withValues(alpha: 0.8),
                                  blurRadius: 12,
                                ),
                              ],
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
              Container(
                margin: const EdgeInsets.only(bottom: 10),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),

                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.35),
                      blurRadius: 25,
                      spreadRadius: 2,
                    ),
                  ],
                ),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),

                  child: Container(
                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),

                      image: coverImage != null && coverImage!.isNotEmpty
                          ? DecorationImage(
                              image: FileImage(File(coverImage!)),
                              fit: BoxFit.cover,
                            )
                          : null,

                      color: coverImage == null || coverImage!.isEmpty
                          ? Theme.of(context).cardColor.withValues(alpha: 0.80)
                          : Colors.black.withValues(alpha: 0.25),

                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.8),
                        width: 2,
                      ),
                    ),


                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const SizedBox(height: 45),

                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.8),
                                    blurRadius: 18,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 42,
                                backgroundImage:
                                    profileImage != null &&
                                            profileImage!.isNotEmpty
                                        ? FileImage(File(profileImage!))
                                        : null,
                                child: profileImage == null ||
                                        profileImage!.isEmpty
                                    ? const Icon(Icons.person, size: 42)
                                    : null,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Center(
                            child: Text(
                              operatorName,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary,
                              ),
                            ),
                          ),

                          const SizedBox(height: 4),

                          Center(
                            child: Text(
                              greeting,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.15),
                              ),
                              child: Text(
                                'ID: $userId',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
