import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
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
import 'i18n/app_localization.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) { sqfliteFfiInit(); databaseFactory = databaseFactoryFfi; }
  final savedTheme = await DatabaseHelper.instance.getTheme();
  AppThemeController.currentTheme.value = AppTheme.values.firstWhere((e) => e.name == savedTheme, orElse: () => AppTheme.classicLight);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override Widget build(BuildContext context) {
    final localization = AppLocalization.english();
    return ValueListenableBuilder<AppTheme>(valueListenable: AppThemeController.currentTheme, builder: (context, theme, child) => MaterialApp(debugShowCheckedModeBanner: false, title: localization.appName, theme: ThemeManager.getTheme(theme), home: const SplashScreen()));
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final ScrollController _creditsScroll = ScrollController();

  @override void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 6))..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_creditsScroll.hasClients && _creditsScroll.position.maxScrollExtent > 0) {
        _creditsScroll.animateTo(_creditsScroll.position.maxScrollExtent, duration: const Duration(seconds: 6), curve: Curves.linear);
      }
    });
    Timer(const Duration(seconds: 6), () { if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage())); });
  }

  @override void dispose() { _creditsScroll.dispose(); _controller.dispose(); super.dispose(); }

  Widget _text3D(String text, double size, {bool hero = false}) {
    final glow = hero ? const Color(0xFF42E8FF) : const Color(0xFF6BDFFF);
    final face = hero ? Colors.white : const Color(0xFFE9FAFF);
    return Stack(alignment: Alignment.center, children: [
      Transform.translate(offset: const Offset(6, 8), child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: size, fontWeight: FontWeight.w900, letterSpacing: hero ? 2.5 : .9, color: const Color(0xFF02070D), shadows: [Shadow(color: glow.withValues(alpha: .9), blurRadius: 14)]))),
      Transform.translate(offset: const Offset(3, 4), child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: size, fontWeight: FontWeight.w900, letterSpacing: hero ? 2.5 : .9, color: const Color(0xFF247C96)))),
      Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: size, fontWeight: FontWeight.w900, letterSpacing: hero ? 2.5 : .9, color: face, shadows: [Shadow(color: glow, blurRadius: 9), const Shadow(color: Colors.white, blurRadius: 1, offset: Offset(-1, -1))])),
    ]);
  }

  Widget _logo(double width) {
    final logoSize = math.min(width * .46, 190.0);
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: const Color(0xFF39D9FF).withValues(alpha: .35), blurRadius: 28, spreadRadius: 3)]), child: Image.asset('assets/branding/workearn_logo.png', width: logoSize, fit: BoxFit.contain));
  }

  Widget _ergsCreditLogo(double width) {
    final logoSize = math.min(width * .22, 92.0);
    return Padding(padding: const EdgeInsets.only(top: 4, bottom: 2), child: Image.asset('1787132674693.png', width: logoSize, height: logoSize, fit: BoxFit.contain));
  }

  Widget _credits(double width) {
    final titleSize = math.min(width * .105, 43.0); final bodySize = math.min(width * .047, 20.0); final companySize = math.min(width * .053, 22.0);
    return Padding(padding: EdgeInsets.symmetric(horizontal: width * .07), child: Column(mainAxisSize: MainAxisSize.min, children: [
      _logo(width), const SizedBox(height: 18), _text3D('WORK EARN APP', titleSize, hero: true), const SizedBox(height: 34),
      _text3D('Produced by', bodySize), const SizedBox(height: 5), _ergsCreditLogo(width), const SizedBox(height: 2), _text3D('ERGS Dynamics Foundation Technology', companySize, hero: true), const SizedBox(height: 34),
      _text3D('Founder', bodySize), const SizedBox(height: 7), _text3D('Rasheed Afridi', math.min(width * .068, 29.0), hero: true), const SizedBox(height: 38),
      _text3D('Thanks for using Work Earn App', bodySize, hero: true), const SizedBox(height: 14), _text3D('Track your jobs', bodySize), const SizedBox(height: 7), _text3D('Track your payments', bodySize), const SizedBox(height: 7), _text3D('Save your working journey', bodySize), const SizedBox(height: 55),
    ]));
  }

  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF01030A), body: LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final height = constraints.maxHeight;
      return ClipRect(child: Stack(fit: StackFit.expand, children: [
        const _FreshDarkSky(),
        Positioned(top: height * .32, left: width * .18, right: width * .18, child: Opacity(opacity: .16, child: Image.asset('1787132674693.png', fit: BoxFit.contain))),
        AnimatedBuilder(animation: _controller, builder: (context, child) => CustomPaint(painter: _FreshObjectsPainter(progress: _controller.value))),
        Positioned.fill(child: ClipRect(child: SingleChildScrollView(controller: _creditsScroll, physics: const NeverScrollableScrollPhysics(), child: Column(children: [SizedBox(height: height), _credits(width), SizedBox(height: height)])))),
        Positioned.fill(child: IgnorePointer(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withValues(alpha: .08), Colors.transparent, Colors.black.withValues(alpha: .22)]))))),
      ]));
    }));
  }
}

class _FreshDarkSky extends StatelessWidget {
  const _FreshDarkSky();
  @override Widget build(BuildContext context) => DecoratedBox(decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment(0, -.35), radius: 1.15, colors: [Color(0xFF0C1730), Color(0xFF030611), Color(0xFF000105)])), child: const SizedBox.expand());
}

class _FreshObjectsPainter extends CustomPainter {
  final double progress;
  _FreshObjectsPainter({required this.progress});
  @override void paint(Canvas canvas, Size size) { _moon(canvas, size); _stars(canvas, size); _rocket(canvas, size); _backgroundBrand(canvas, size); }
  void _moon(Canvas canvas, Size size) {
    final r = math.min(size.width, size.height) * .055; final centre = Offset(size.width * .84, size.height * .13);
    final glow = Paint()..shader = RadialGradient(colors: [const Color(0xFFBDEEFF).withValues(alpha: .38), Colors.transparent]).createShader(Rect.fromCircle(center: centre, radius: r * 2.8)); canvas.drawCircle(centre, r * 2.8, glow);
    final moon = Paint()..shader = RadialGradient(colors: [Colors.white, const Color(0xFFA6E3F7), const Color(0xFF426780)]).createShader(Rect.fromCircle(center: centre, radius: r)); canvas.drawCircle(centre, r, moon);
  }
  void _stars(Canvas canvas, Size size) {
    const data = <List<double>>[[.10,.16,7,.02],[.27,.09,5,.19],[.45,.22,8,.36],[.65,.12,6,.54],[.90,.25,8,.71],[.07,.40,5,.12],[.23,.56,7,.48],[.49,.46,5,.79],[.72,.58,8,.30],[.92,.70,5,.63],[.15,.80,6,.43],[.40,.74,8,.09],[.63,.84,5,.88],[.84,.89,7,.25]];
    for (final s in data) { final p = (progress + s[3]) % 1.0; final x = (s[0] * size.width - p * size.width * .08 + size.width) % size.width; final y = (s[1] * size.height + p * size.height * .09) % size.height; final c = Offset(x,y); final r = s[2] * .5; final glow = Paint()..shader = RadialGradient(colors: [Colors.white.withValues(alpha:.95), const Color(0xFF62E7FF).withValues(alpha:.55), Colors.transparent]).createShader(Rect.fromCircle(center:c,radius:r*4)); canvas.drawCircle(c,r*4,glow); canvas.drawCircle(c,r,Paint()..color=Colors.white); }
  }
  void _rocket(Canvas canvas, Size size) {
    final p = Curves.easeInOutCubic.transform(progress); final start = Offset(size.width*.07,size.height*.82); final end = Offset(size.width*.78,size.height*.18); final pos = Offset.lerp(start,end,p)!;
    canvas.save(); canvas.translate(pos.dx,pos.dy); canvas.rotate(-.72);
    final trail = Paint()..shader = LinearGradient(colors:[const Color(0xFFFFE76B),const Color(0xFFFF7A3D).withValues(alpha:.55),Colors.transparent]).createShader(const Rect.fromLTWH(-90,-12,100,24)); canvas.drawOval(const Rect.fromLTWH(-88,-8,90,16),trail);
    final body = Paint()..shader = LinearGradient(colors:[Colors.white,const Color(0xFF9DEBFF),const Color(0xFF35668E)]).createShader(const Rect.fromLTWH(-25,-12,50,24)); canvas.drawOval(const Rect.fromLTWH(-25,-12,48,24),body);
    final nose = Path()..moveTo(23,0)..quadraticBezierTo(9,-11,3,-10)..quadraticBezierTo(12,0,3,10)..quadraticBezierTo(9,11,23,0)..close(); canvas.drawPath(nose,body);
    final windowRect = Rect.fromCircle(center: const Offset(5,-2), radius: 6);
    final window = Paint()..shader = RadialGradient(colors:[Colors.white,const Color(0xFF39D9FF),const Color(0xFF2450A0)]).createShader(windowRect); canvas.drawCircle(const Offset(5,-2),6,window);
    canvas.drawPath(Path()..moveTo(-9,8)..lineTo(-18,17)..lineTo(2,10)..close(),Paint()..color=const Color(0xFFB84BFF)); canvas.restore();
  }
  void _backgroundBrand(Canvas canvas, Size size) { final painter=TextPainter(textDirection:TextDirection.ltr,text:const TextSpan(text:'ERGS DYNAMICS FOUNDATION TECHNOLOGY',style:TextStyle(fontSize:24,fontWeight:FontWeight.w900,letterSpacing:2.2,color:Color(0xFF18314A))))..layout(maxWidth:size.width*.92); painter.paint(canvas,Offset((size.width-painter.width)/2,size.height*.42)); }
  @override bool shouldRepaint(covariant _FreshObjectsPainter oldDelegate) => oldDelegate.progress != progress;
}

class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState()=>_HomePageState(); }
class _HomePageState extends State<HomePage> {
  int selectedIndex=0; final List<Widget> pages=[const DashboardPage(),const WorkPage(embedded:true),const HistoryPage(),const FinancePage(),const SettingsPage()]; Widget nav3D(IconData icon)=>Icon(icon,size:20);
  @override Widget build(BuildContext context) {
    final t=Theme.of(context); final l=AppLocalization.english();
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left:10,right:10,bottom:8),
        decoration: BoxDecoration(borderRadius:BorderRadius.circular(24),color:t.cardColor,border:Border.all(color:t.colorScheme.primary.withValues(alpha:.20)),boxShadow:[BoxShadow(color:t.colorScheme.primary.withValues(alpha:.10),blurRadius:9,offset:const Offset(0,3))]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBar(
            height:64,elevation:0,backgroundColor:t.cardColor,indicatorColor:t.colorScheme.primary.withValues(alpha:.12),labelBehavior:NavigationDestinationLabelBehavior.alwaysShow,selectedIndex:selectedIndex,
            destinations:[NavigationDestination(icon:nav3D(Icons.dashboard),label:l.dashboard),NavigationDestination(icon:nav3D(Icons.work),label:l.work),NavigationDestination(icon:nav3D(Icons.history),label:l.history),NavigationDestination(icon:nav3D(Icons.account_balance_wallet),label:l.finance),NavigationDestination(icon:nav3D(Icons.settings),label:l.settings)],
            onDestinationSelected:(index)=>setState(()=>selectedIndex=index),
          ),
        ),
      ),
    );
  }
}