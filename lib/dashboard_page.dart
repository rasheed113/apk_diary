import 'dart:async';

import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

import 'database_helper.dart';
import 'finance_page.dart';
import 'history_page.dart';
import 'profile_header_card.dart';
import 'settings_page.dart';
import 'work_page.dart';

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
  String? profileImage;
  String? coverImage;
  String tickerMessage = '';
  Timer? dailyRefreshTimer;

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  void initState() {
    super.initState();
    loadDashboard();
    _scheduleDailyRefresh();
  }

  void _scheduleDailyRefresh() {
    dailyRefreshTimer?.cancel();
    final now = DateTime.now();
    final nextRefresh = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final timeUntilRefresh = nextRefresh.isBefore(now)
        ? nextRefresh.add(const Duration(days: 1)).difference(now)
        : nextRefresh.difference(now);

    dailyRefreshTimer = Timer(timeUntilRefresh, () {
      if (mounted) loadDashboard();
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
      coverImage = profile?['cover_image'];
      greeting = getGreeting();
      tickerMessage = getTickerMessage();
    });
  }

  String getTickerMessage() {
    if (totalEarning <= 0) {
      return '🚀 Welcome to APK Diary Pro • Add your first work entry today';
    }
    if (todayEarning > 0) {
      return '💰 Today: Rs ${todayEarning.toStringAsFixed(0)} • 📅 Week: Rs ${weeklyEarning.toStringAsFixed(0)} • 🏆 Month: Rs ${monthlyEarning.toStringAsFixed(0)}';
    }
    if (currentBalance < 0) return '⚠️ Check your finance balance';
    return '📅 Week: Rs ${weeklyEarning.toStringAsFixed(0)} • 🏆 Month: Rs ${monthlyEarning.toStringAsFixed(0)} • 💼 Total: Rs ${totalEarning.toStringAsFixed(0)}';
  }

  @override
  void dispose() {
    dailyRefreshTimer?.cancel();
    super.dispose();
  }

  Widget buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
        backgroundColor: scheme.surface,
        foregroundColor: scheme.primary,
        shadowColor: Colors.transparent,
        side: BorderSide(color: scheme.primary.withValues(alpha: 0.18)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  Widget buildCard({
    required String title,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: scheme.surface,
          border: Border.all(color: scheme.primary.withValues(alpha: 0.16)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primary.withValues(alpha: 0.10),
              ),
              child: Icon(icon, size: 18, color: scheme.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.68),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    value,
                    style: TextStyle(
                      color: scheme.onSurface,
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        title: const Text(
          'APK DIARY PRO ⚡',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadDashboard),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.surface,
              scheme.primary.withValues(alpha: 0.035),
              scheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
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
              Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: scheme.primary.withValues(alpha: 0.14)),
                ),
                child: Marquee(
                  text: tickerMessage.isEmpty ? '🚀 Welcome to APK Diary' : tickerMessage,
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  scrollAxis: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  blankSpace: 60,
                  velocity: 30,
                  pauseAfterRound: const Duration(seconds: 1),
                  startPadding: 10,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: buildActionButton(
                      icon: Icons.add,
                      label: 'New Entry',
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const WorkPage()),
                        );
                        if (result == true) loadDashboard();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: buildActionButton(
                      icon: Icons.history,
                      label: 'History',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HistoryPage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: buildActionButton(
                      icon: Icons.account_balance_wallet,
                      label: 'Finance',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FinancePage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: buildActionButton(
                      icon: Icons.settings,
                      label: 'Settings',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsPage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              buildCard(
                title: 'Current Balance',
                value: 'Rs. ${currentBalance.toStringAsFixed(2)}',
                icon: Icons.account_balance_wallet,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FinancePage()),
                ),
              ),
              buildCard(
                title: 'Total Entries',
                value: totalEntries.toString(),
                icon: Icons.list_alt,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryPage()),
                ),
              ),
              buildCard(title: 'Total Pieces', value: totalPieces.toString(), icon: Icons.inventory_2),
              buildCard(title: 'Total Earnings', value: 'Rs. ${totalEarning.toStringAsFixed(2)}', icon: Icons.payments),
              buildCard(title: "Today's Earnings", value: 'Rs. ${todayEarning.toStringAsFixed(2)}', icon: Icons.today),
              buildCard(
                title: 'Weekly Earnings',
                value: 'Rs. ${weeklyEarning.toStringAsFixed(2)}',
                icon: Icons.calendar_view_week,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryPage()),
                ),
              ),
              buildCard(
                title: 'Monthly Earnings',
                value: 'Rs. ${monthlyEarning.toStringAsFixed(2)}',
                icon: Icons.calendar_month,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryPage()),
                ),
              ),
              const SizedBox(height: 4),
              buildCard(
                title: 'Grand Total',
                value: 'Rs. ${totalEarning.toStringAsFixed(2)}',
                icon: Icons.emoji_events,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryPage()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
