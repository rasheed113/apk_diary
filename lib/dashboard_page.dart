import 'dart:async';

import 'package:flutter/material.dart' hide Icon;
import 'package:marquee/marquee.dart';

import 'modern_icons.dart';
import 'database_helper.dart';
import 'finance_page.dart';
import 'history_page.dart';
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
  String tickerMessage = '';
  DateTime currentTime = DateTime.now();
  Timer? clockTimer;

  @override
  void initState() {
    super.initState();
    clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => currentTime = DateTime.now());
    });
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    final b = await DatabaseHelper.instance.getBalance();
    final e = await DatabaseHelper.instance.getTotalEntries();
    final p = await DatabaseHelper.instance.getTotalPieces();
    final t = await DatabaseHelper.instance.getTotalEarning();
    final d = await DatabaseHelper.instance.getTodayEarning();
    final w = await DatabaseHelper.instance.getWeeklyEarning();
    final m = await DatabaseHelper.instance.getMonthlyEarning();
    await DatabaseHelper.instance.getProfile();
    if (!mounted) return;
    setState(() {
      currentBalance = b;
      totalEntries = e;
      totalPieces = p;
      totalEarning = t;
      todayEarning = d;
      weeklyEarning = w;
      monthlyEarning = m;
      tickerMessage = getTickerMessage();
    });
  }

  String getTickerMessage() {
    if (totalEarning <= 0) return '✨ Welcome to WorkEarn  •  Turn every stitch into progress  •  Add your first entry';
    return '💎 Today Rs ${todayEarning.toStringAsFixed(0)}   •   📅 Week Rs ${weeklyEarning.toStringAsFixed(0)}   •   🏆 Month Rs ${monthlyEarning.toStringAsFixed(0)}   •   💼 Total Rs ${totalEarning.toStringAsFixed(0)}   •   Keep earning, keep growing';
  }

  String get digitalTime {
    final h = currentTime.hour % 12 == 0 ? 12 : currentTime.hour % 12;
    return '${h.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}:${currentTime.second.toString().padLeft(2, '0')}';
  }

  String get period => currentTime.hour >= 12 ? 'PM' : 'AM';
  String get dateLabel => '${currentTime.day.toString().padLeft(2, '0')} / ${currentTime.month.toString().padLeft(2, '0')} / ${currentTime.year}';

  Widget build3DIcon(IconData icon, {double size = 22, Color? color}) => Icon(icon, size: size);

  Widget buildDigitalClock() {
    final s = Theme.of(context).colorScheme;
    return Container(
      width: 220, height: 96, padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, s.primary.withValues(alpha: .045)]), border: Border.all(color: s.primary.withValues(alpha: .16), width: 1.2), boxShadow: [BoxShadow(color: s.primary.withValues(alpha: .09), blurRadius: 18, offset: const Offset(0, 7))]),
      child: Row(children: [
        Container(width: 58, height: 72, decoration: BoxDecoration(borderRadius: BorderRadius.circular(19), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [s.secondary, s.primary]), border: Border.all(color: Colors.white.withValues(alpha: .7)), boxShadow: [BoxShadow(color: s.primary.withValues(alpha: .14), blurRadius: 10, offset: const Offset(0, 4))]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.schedule_rounded, color: Colors.white, size: 28), const SizedBox(height: 3), Text(period, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))])),
        const SizedBox(width: 12), Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(digitalTime, maxLines: 1, style: TextStyle(color: s.primary, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.1)), const SizedBox(height: 5), Text(dateLabel, maxLines: 1, style: TextStyle(color: s.primary.withValues(alpha: .56), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .45)), const SizedBox(height: 5), Container(height: 3, width: 72, decoration: BoxDecoration(borderRadius: BorderRadius.circular(99), gradient: LinearGradient(colors: [s.secondary, s.primary]))) ])),
      ]),
    );
  }

  Widget buildGlowButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    final s = Theme.of(context).colorScheme;
    return Container(height: 64, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, s.primary.withValues(alpha: .045)]), border: Border.all(color: s.primary.withValues(alpha: .14)), boxShadow: [BoxShadow(color: s.primary.withValues(alpha: .07), blurRadius: 10, offset: const Offset(0, 4))]), child: ElevatedButton(style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), onPressed: onPressed, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [build3DIcon(icon, size: 18), const SizedBox(width: 8), Text(label, style: TextStyle(color: s.primary, fontSize: 14, fontWeight: FontWeight.w900))])));
  }

  Widget buildCard({required String title, required String value, required IconData icon, VoidCallback? onTap}) {
    final s = Theme.of(context).colorScheme;
    return InkWell(borderRadius: BorderRadius.circular(20), onTap: onTap, child: Container(margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 2), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, s.primary.withValues(alpha: .035)]), border: Border.all(color: s.primary.withValues(alpha: .12)), boxShadow: [BoxShadow(color: s.primary.withValues(alpha: .055), blurRadius: 10, offset: const Offset(0, 4))]), child: Row(children: [build3DIcon(icon, size: 19), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text(title, style: TextStyle(color: s.primary.withValues(alpha: .60), fontSize: 12, fontWeight: FontWeight.w700)), const SizedBox(height: 2), Text(value, style: TextStyle(color: s.primary, fontSize: 16, fontWeight: FontWeight.w900))]))])));
  }

  Widget buildHeader() {
    final s = Theme.of(context).colorScheme;
    return Container(height: 82, padding: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [s.primary, s.secondary]), border: Border.all(color: Colors.white.withValues(alpha: .62)), boxShadow: [BoxShadow(color: s.primary.withValues(alpha: .10), blurRadius: 14, offset: const Offset(0, 5))]), child: Row(children: [Stack(children: [Text('WORK EARN', style: TextStyle(color: Colors.white.withValues(alpha: .28), fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: 1.2)), Transform.translate(offset: const Offset(-1.2, -1.2), child: const Text('WORK EARN', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: 1.2))), Transform.translate(offset: const Offset(1.6, 2), child: Text('WORK EARN', style: TextStyle(color: Colors.white.withValues(alpha: .22), fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: 1.2))) ]), const Spacer(), Container(width: 72, height: 64, padding: const EdgeInsets.all(5), decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: Colors.white.withValues(alpha: .13), border: Border.all(color: Colors.white.withValues(alpha: .45))), child: Image.asset('assets/branding/workearn_logo.png', fit: BoxFit.contain))]));
  }

  @override
  void dispose() { clockTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.w900)), actions: [IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: loadDashboard)]),
      body: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [s.surface, Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter)), child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(18, 6, 18, 18), child: Column(children: [
        buildHeader(), const SizedBox(height: 12), Align(alignment: Alignment.centerRight, child: buildDigitalClock()), const SizedBox(height: 12),
        Container(height: 78, decoration: BoxDecoration(borderRadius: BorderRadius.circular(23), gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [s.primary, s.secondary]), border: Border.all(color: Colors.white.withValues(alpha: .35)), boxShadow: [BoxShadow(color: s.primary.withValues(alpha: .09), blurRadius: 14, offset: const Offset(0, 5))]), child: ClipRRect(borderRadius: BorderRadius.circular(23), child: Row(children: [Padding(padding: const EdgeInsets.only(left: 10), child: build3DIcon(Icons.auto_awesome_rounded, size: 23)), const SizedBox(width: 10), Expanded(child: Marquee(text: tickerMessage.isEmpty ? '✨ Welcome to WorkEarn  •  Turn every stitch into progress' : tickerMessage, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: .25), scrollAxis: Axis.horizontal, crossAxisAlignment: CrossAxisAlignment.center, blankSpace: 80, velocity: 28, pauseAfterRound: const Duration(seconds: 2), startPadding: 8))]))),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: buildGlowButton(icon: Icons.checkroom_rounded, label: 'New Entry', onPressed: () async { final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkPage())); if (r == true) loadDashboard(); })), const SizedBox(width: 8), Expanded(child: buildGlowButton(icon: Icons.history_rounded, label: 'History', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()))))]),
        const SizedBox(height: 8),
        Row(children: [Expanded(child: buildGlowButton(icon: Icons.account_balance_wallet_rounded, label: 'Finance', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinancePage())))), const SizedBox(width: 8), Expanded(child: buildGlowButton(icon: Icons.build_rounded, label: 'Settings', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()))))]),
        const SizedBox(height: 8),
        buildCard(title: 'Current Balance', value: 'Rs. ${currentBalance.toStringAsFixed(2)}', icon: Icons.account_balance_wallet_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinancePage()))),
        buildCard(title: 'Total Entries', value: totalEntries.toString(), icon: Icons.receipt_long_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()))),
        buildCard(title: 'Total Pieces', value: totalPieces.toString(), icon: Icons.inventory_2_rounded),
        buildCard(title: "Today's Earnings", value: 'Rs. ${todayEarning.toStringAsFixed(2)}', icon: Icons.today_rounded),
        buildCard(title: 'Weekly Earnings', value: 'Rs. ${weeklyEarning.toStringAsFixed(2)}', icon: Icons.calendar_view_week_rounded),
        buildCard(title: 'Monthly Earnings', value: 'Rs. ${monthlyEarning.toStringAsFixed(2)}', icon: Icons.calendar_month_rounded),
        buildCard(title: 'Total Earnings', value: 'Rs. ${totalEarning.toStringAsFixed(2)}', icon: Icons.payments_rounded),
      ]))));
  }
}
