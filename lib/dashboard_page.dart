import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart' hide Icon;
import 'package:marquee/marquee.dart';
import 'modern_icons.dart';
import 'database_helper.dart';
import 'finance_page.dart';
import 'history_page.dart';
import 'settings_page.dart';
import 'work_page.dart';
import 'i18n/app_localization.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int totalEntries = 0, totalPieces = 0;
  double currentBalance = 0, totalEarning = 0, todayEarning = 0, weeklyEarning = 0, monthlyEarning = 0;
  String tickerMessage = '';
  DateTime currentTime = DateTime.now();
  Timer? clockTimer;
  bool _loading = false;
  String profileName = '';
  String companyName = '';
  String? profileImagePath;
  String? coverImagePath;

  AppLocalization get l => AppLocalization.english();

  @override
  void initState() {
    super.initState();
    clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => currentTime = DateTime.now());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) loadDashboard();
    });
  }

  Future<void> loadDashboard() async {
    if (_loading) return;
    _loading = true;
    try {
      final b = await DatabaseHelper.instance.getBalance();
      final e = await DatabaseHelper.instance.getTotalEntries();
      final p = await DatabaseHelper.instance.getTotalPieces();
      final t = await DatabaseHelper.instance.getTotalEarning();
      final d = await DatabaseHelper.instance.getTodayEarning();
      final w = await DatabaseHelper.instance.getWeeklyEarning();
      final m = await DatabaseHelper.instance.getMonthlyEarning();
      final profile = await DatabaseHelper.instance.getProfile();
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
        profileName = profile?['operator_name']?.toString().trim() ?? '';
        companyName = profile?['company_name']?.toString().trim() ?? '';
        final profilePath = profile?['profile_image']?.toString().trim() ?? '';
        final coverPath = profile?['cover_image']?.toString().trim() ?? '';
        profileImagePath = profilePath.isNotEmpty ? profilePath : null;
        coverImagePath = coverPath.isNotEmpty ? coverPath : null;
      });
    } catch (_) {
      if (mounted && tickerMessage.isEmpty) {
        setState(() => tickerMessage = getTickerMessage());
      }
    } finally {
      _loading = false;
    }
  }

  String getTickerMessage() {
    if (totalEarning <= 0) return '✨ ${l.welcomeToWorkEarn}  •  ${l.turnEveryStitchIntoProgress}  •  ${l.addYourFirstEntry}';
    return '💎 ${l.today} Rs ${todayEarning.toStringAsFixed(0)}   •   📅 ${l.week} Rs ${weeklyEarning.toStringAsFixed(0)}   •   🏆 ${l.month} Rs ${monthlyEarning.toStringAsFixed(0)}   •   💼 ${l.totalEarnings} Rs ${totalEarning.toStringAsFixed(0)}   •   ${l.keepEarningKeepGrowing}';
  }

  String get digitalTime {
    final h = currentTime.hour % 12 == 0 ? 12 : currentTime.hour % 12;
    return '${h.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}:${currentTime.second.toString().padLeft(2, '0')}';
  }
  String get period => currentTime.hour >= 12 ? 'PM' : 'AM';
  String get dateLabel => '${currentTime.day.toString().padLeft(2, '0')} / ${currentTime.month.toString().padLeft(2, '0')} / ${currentTime.year}';
  Widget build3DIcon(IconData icon, {double size = 22, Color? color}) => Icon(icon, size: size, color: color);

  Widget buildDigitalClock() {
    final s = Theme.of(context).colorScheme;
    return Container(
      width: 220, height: 96, padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, s.primary.withValues(alpha: .045)]), border: Border.all(color: s.primary.withValues(alpha: .16), width: 1.2), boxShadow: [BoxShadow(color: s.primary.withValues(alpha: .09), blurRadius: 18, offset: const Offset(0, 7))]),
      child: Row(children: [
        Container(width: 58, height: 72, decoration: BoxDecoration(borderRadius: BorderRadius.circular(19), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [s.secondary, s.primary]), border: Border.all(color: Colors.white.withValues(alpha: .7)), boxShadow: [BoxShadow(color: s.primary.withValues(alpha: .14), blurRadius: 10, offset: const Offset(0, 4))]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.schedule_rounded, color: Colors.white, size: 28), const SizedBox(height: 3), Text(period, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))])),
        const SizedBox(width: 12),
        Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _build3DText(digitalTime, color: s.primary, fontSize: 20, letterSpacing: 1.1),
          const SizedBox(height: 5),
          _build3DText(dateLabel, color: s.primary.withValues(alpha: .56), fontSize: 9, letterSpacing: .45),
          const SizedBox(height: 5),
          Container(height: 3, width: 72, decoration: BoxDecoration(borderRadius: BorderRadius.circular(99), gradient: LinearGradient(colors: [s.secondary, s.primary])))
        ])),
      ]),
    );
  }

  Widget _build3DText(String text, {required Color color, required double fontSize, double letterSpacing = 0}) {
    return Stack(children: [
      Text(text, maxLines: 1, overflow: TextOverflow.clip, style: TextStyle(color: color.withValues(alpha: .28), fontSize: fontSize, fontWeight: FontWeight.w900, letterSpacing: letterSpacing, shadows: [Shadow(color: Colors.black.withValues(alpha: .20), offset: const Offset(1.2, 1.5), blurRadius: 1)])),
      Transform.translate(offset: const Offset(0, -1), child: Text(text, maxLines: 1, overflow: TextOverflow.clip, style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.w900, letterSpacing: letterSpacing, shadows: [Shadow(color: Colors.white.withValues(alpha: .62), offset: const Offset(-.6, -.7), blurRadius: .4), Shadow(color: Colors.black.withValues(alpha: .24), offset: const Offset(1.0, 1.2), blurRadius: 1)]))),
    ]);
  }

  Widget _buildTicker3DText(String text) {
    return Stack(alignment: Alignment.centerLeft, children: [
      Transform.translate(offset: const Offset(1.5, 2.2), child: Text(text, maxLines: 1, overflow: TextOverflow.clip, style: const TextStyle(color: Color(0xAA061018), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .18))),
      Transform.translate(offset: const Offset(.8, 1.1), child: Text(text, maxLines: 1, overflow: TextOverflow.clip, style: const TextStyle(color: Color(0xCC7EEBFF), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .18))),
      Text(text, maxLines: 1, overflow: TextOverflow.clip, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .18, shadows: [Shadow(color: Color(0xFFFFFFFF), offset: Offset(-.35, -.45), blurRadius: .5), Shadow(color: Color(0x88000000), offset: Offset(1.1, 1.2), blurRadius: 1.2)])),
    ]);
  }

  Widget buildGlowButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    final s = Theme.of(context).colorScheme;
    return Container(
      height: 64,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, s.primary.withValues(alpha: .045)]), border: Border.all(color: s.primary.withValues(alpha: .14)), boxShadow: [BoxShadow(color: s.primary.withValues(alpha: .07), blurRadius: 10, offset: const Offset(0, 4))]),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        onPressed: onPressed,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [build3DIcon(icon, size: 20), const SizedBox(width: 8), Text(label, style: TextStyle(color: s.primary, fontSize: 14, fontWeight: FontWeight.w900))]),
      ),
    );
  }

  Widget buildCard({required String title, required String value, required IconData icon, VoidCallback? onTap}) {
    final s = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(20), onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 2), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, s.primary.withValues(alpha: .035)]), border: Border.all(color: s.primary.withValues(alpha: .12)), boxShadow: [BoxShadow(color: s.primary.withValues(alpha: .055), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(borderRadius: BorderRadius.circular(13), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [s.primary.withValues(alpha: .10), s.secondary.withValues(alpha: .06)]), border: Border.all(color: s.primary.withValues(alpha: .12)), boxShadow: [BoxShadow(color: s.primary.withValues(alpha: .07), blurRadius: 7, offset: const Offset(0, 3))]), child: Center(child: build3DIcon(icon, size: 19, color: s.primary))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text(title, style: TextStyle(color: s.primary.withValues(alpha: .60), fontSize: 12, fontWeight: FontWeight.w700)), const SizedBox(height: 2), Text(value, style: TextStyle(color: s.primary, fontSize: 16, fontWeight: FontWeight.w900))])),
        ]),
      ),
    );
  }

  Widget buildHeader() {
    final s = Theme.of(context).colorScheme;
    final hasCover = coverImagePath != null && File(coverImagePath!).existsSync();
    final hasProfile = profileImagePath != null && File(profileImagePath!).existsSync();
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: hasCover ? null : LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [s.primary, s.secondary]),
        image: hasCover ? DecorationImage(image: FileImage(File(coverImagePath!)), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: .18), BlendMode.darken)) : null,
        border: Border.all(color: Colors.white.withValues(alpha: .62)),
        boxShadow: [BoxShadow(color: s.primary.withValues(alpha: .10), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        CircleAvatar(radius: 19, backgroundColor: Colors.white.withValues(alpha: .18), backgroundImage: hasProfile ? FileImage(File(profileImagePath!)) : null, child: hasProfile ? null : const Icon(Icons.person_rounded, color: Colors.white, size: 22)),
        const SizedBox(width: 9),
        Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(clipBehavior: Clip.none, children: [
            Transform.translate(offset: const Offset(1.2, 1.8), child: Text(profileName.isEmpty ? l.workEarn : profileName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xAA061018), fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: .25))),
            Transform.translate(offset: const Offset(.55, .85), child: Text(profileName.isEmpty ? l.workEarn : profileName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xCC7EEBFF), fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: .25))),
            Transform.translate(offset: const Offset(0, -.55), child: Text(profileName.isEmpty ? l.workEarn : profileName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: .25, shadows: [Shadow(color: Color(0xFFFFFFFF), offset: Offset(-.35, -.45), blurRadius: .5), Shadow(color: Color(0x88000000), offset: Offset(1, 1.2), blurRadius: 1.1)]))),
          ]),
          if (companyName.isNotEmpty) ...[
            const SizedBox(height: 1),
            Stack(clipBehavior: Clip.none, children: [
              Transform.translate(offset: const Offset(.9, 1.3), child: Text(companyName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0x99061018), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .18))),
              Transform.translate(offset: const Offset(.4, .6), child: Text(companyName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xBB7EEBFF), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .18))),
              Text(companyName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xEFFFFFFF), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .18, shadows: [Shadow(color: Color(0xCCFFFFFF), offset: Offset(-.25, -.3), blurRadius: .35), Shadow(color: Color(0x77000000), offset: Offset(.7, .8), blurRadius: .8)])),
            ]),
          ],
        ])),
        Container(width: 42, height: 40, padding: const EdgeInsets.all(3), decoration: BoxDecoration(borderRadius: BorderRadius.circular(11), color: Colors.white.withValues(alpha: .16), border: Border.all(color: Colors.white.withValues(alpha: .55)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .18), blurRadius: 5, offset: const Offset(2, 3)), BoxShadow(color: Colors.white.withValues(alpha: .22), blurRadius: 3, offset: const Offset(-1, -1))]), child: Stack(children: [Transform.translate(offset: const Offset(1.2, 1.8), child: Opacity(opacity: .28, child: Image.asset('assets/branding/workearn_logo.png', fit: BoxFit.contain))), Transform.translate(offset: const Offset(0, -1), child: Image.asset('assets/branding/workearn_logo.png', fit: BoxFit.contain))])),
      ]),
    );
  }

  @override
  void dispose() { clockTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final weekFilter = 'Week:${now.toIso8601String()}';
    final monthFilter = 'Month:${now.year}-${now.month.toString().padLeft(2, '0')}';
    return Scaffold(
      appBar: AppBar(toolbarHeight: 38, titleSpacing: 10, title: Stack(clipBehavior: Clip.none, children: [
        Transform.translate(offset: const Offset(1.2, 1.8), child: Text(l.dashboard, style: const TextStyle(color: Color(0xAA061018), fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: .3))),
        Transform.translate(offset: const Offset(.55, .85), child: Text(l.dashboard, style: const TextStyle(color: Color(0xCC7EEBFF), fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: .3))),
        Transform.translate(offset: const Offset(0, -.55), child: Text(l.dashboard, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: .3, shadows: [Shadow(color: Color(0xFFFFFFFF), offset: Offset(-.3, -.4), blurRadius: .5), Shadow(color: Color(0x88000000), offset: Offset(1, 1), blurRadius: 1)]))),
      ]), actions: [IconButton(icon: const Icon(Icons.refresh_rounded, size: 18), onPressed: loadDashboard)]),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [s.surface, Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 18),
          child: Column(children: [
            buildHeader(), const SizedBox(height: 7), Align(alignment: Alignment.centerRight, child: buildDigitalClock()), const SizedBox(height: 7),
            Container(height: 42, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [s.primary, s.secondary]), border: Border.all(color: Colors.white.withValues(alpha: .35)), boxShadow: [BoxShadow(color: s.primary.withValues(alpha: .07), blurRadius: 8, offset: const Offset(0, 3))]), child: ClipRRect(borderRadius: BorderRadius.circular(14), child: Row(children: [Padding(padding: const EdgeInsets.only(left: 8), child: build3DIcon(Icons.auto_awesome_rounded, size: 17)), const SizedBox(width: 7), Expanded(child: Marquee(text: tickerMessage.isEmpty ? '✨ ${l.welcomeToWorkEarn}  •  ${l.turnEveryStitchIntoProgress}' : tickerMessage, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .18), scrollAxis: Axis.horizontal, crossAxisAlignment: CrossAxisAlignment.center, blankSpace: 50, velocity: 24, pauseAfterRound: const Duration(seconds: 2), startPadding: 6, ))]))),
            const SizedBox(height: 7),
            Row(children: [Expanded(child: buildGlowButton(icon: Icons.add_circle_outline_rounded, label: l.newEntry, onPressed: () async { final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkPage())); if (r == true && mounted) await loadDashboard(); })), const SizedBox(width: 8), Expanded(child: buildGlowButton(icon: Icons.history_rounded, label: l.history, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryPage(initialFilter: 'Today')))))]),
            const SizedBox(height: 8),
            Row(children: [Expanded(child: buildGlowButton(icon: Icons.account_balance_wallet_rounded, label: l.finance, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinancePage())))), const SizedBox(width: 8), Expanded(child: buildGlowButton(icon: Icons.settings_rounded, label: l.settings, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()))))]),
            const SizedBox(height: 8),
            buildCard(title: l.todaysEarnings, value: 'Rs. ${todayEarning.toStringAsFixed(2)}', icon: Icons.today_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryPage(initialFilter: 'Today')))),
            buildCard(title: l.weeklyEarnings, value: 'Rs. ${weeklyEarning.toStringAsFixed(2)}', icon: Icons.calendar_view_week_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryPage(initialFilter: weekFilter)))),
            buildCard(title: l.monthlyEarnings, value: 'Rs. ${monthlyEarning.toStringAsFixed(2)}', icon: Icons.calendar_month_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryPage(initialFilter: monthFilter)))),
            buildCard(title: l.currentBalance, value: 'Rs. ${currentBalance.toStringAsFixed(2)}', icon: Icons.account_balance_wallet_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinancePage()))),
            buildCard(title: l.totalEntries, value: totalEntries.toString(), icon: Icons.format_list_numbered_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryPage(initialFilter: 'All')))),
            buildCard(title: l.totalEarnings, value: 'Rs. ${totalEarning.toStringAsFixed(2)}', icon: Icons.payments_rounded),
            buildCard(title: l.totalPieces, value: totalPieces.toString(), icon: Icons.inventory_2_rounded),
          ]),
        ),
      ),
    );
  }
}