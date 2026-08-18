import 'dart:async';
import 'package:flutter/material.dart' hide Icon;
import 'package:marquee/marquee.dart';
import 'modern_icons.dart';
import 'database_helper.dart';
import 'finance_page.dart';
import 'history_page.dart';
import 'settings_page.dart';
import 'work_page.dart';
import 'i18n/app_localization.dart';
import 'i18n/app_language_controller.dart';

class DashboardPage extends StatefulWidget { const DashboardPage({super.key}); @override State<DashboardPage> createState()=>_DashboardPageState(); }
class _DashboardPageState extends State<DashboardPage>{
  int totalEntries=0,totalPieces=0; double currentBalance=0,totalEarning=0,todayEarning=0,weeklyEarning=0,monthlyEarning=0; Timer? clockTimer;
  @override void initState(){super.initState();clockTimer=Timer.periodic(const Duration(seconds:1),(_){if(mounted)setState((){});});loadDashboard();}
  Future<void> loadDashboard()async{final b=await DatabaseHelper.instance.getBalance();final e=await DatabaseHelper.instance.getTotalEntries();final p=await DatabaseHelper.instance.getTotalPieces();final t=await DatabaseHelper.instance.getTotalEarning();final d=await DatabaseHelper.instance.getTodayEarning();final w=await DatabaseHelper.instance.getWeeklyEarning();final m=await DatabaseHelper.instance.getMonthlyEarning();if(!mounted)return;setState((){currentBalance=b;totalEntries=e;totalPieces=p;totalEarning=t;todayEarning=d;weeklyEarning=w;monthlyEarning=m;});}
  Widget buildIcon(IconData icon,{double size=22})=>Icon(icon,size:size);
  Widget action({required IconData icon,required String label,required VoidCallback onPressed})=>Expanded(child:ElevatedButton.icon(onPressed:onPressed,icon:buildIcon(icon,size:20),label:Text(label),style:ElevatedButton.styleFrom(minimumSize:const Size(0,58),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18)),elevation:5)));
  Widget buildCard({required String title,required String value,required IconData icon}){
    final s=Theme.of(context).colorScheme;
    return Card(elevation:4,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(20)),child:Padding(padding:const EdgeInsets.all(14),child:Row(children:[
      Container(width:40,height:40,decoration:BoxDecoration(borderRadius:BorderRadius.circular(13),color:s.primary.withValues(alpha:.10)),child:Center(child:buildIcon(icon,size:19))),
      const SizedBox(width:12),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title),const SizedBox(height:2),Text(value,style:const TextStyle(fontWeight:FontWeight.w900))])),
    ])));
  }
  @override Widget build(BuildContext context){return ValueListenableBuilder<AppLanguage>(valueListenable:AppLanguageController.currentLanguage,builder:(context,language,_){final l=AppLocalization(language);return Scaffold(appBar:AppBar(title:Text(l.dashboard),actions:[IconButton(icon:buildIcon(Icons.refresh_rounded),onPressed:loadDashboard)]),body:SingleChildScrollView(padding:const EdgeInsets.all(18),child:Column(children:[Text(l.workEarn,style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900)),const SizedBox(height:12),Row(children:[action(icon:Icons.add_circle_outline_rounded,label:l.newEntry,onPressed:()async{final r=await Navigator.push(context,MaterialPageRoute(builder:(_)=>const WorkPage()));if(r==true)loadDashboard();}),const SizedBox(width:8),action(icon:Icons.history_rounded,label:l.history,onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const HistoryPage())))]),const SizedBox(height:8),Row(children:[action(icon:Icons.account_balance_wallet_rounded,label:l.finance,onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const FinancePage()))),const SizedBox(width:8),action(icon:Icons.settings_rounded,label:l.settings,onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const SettingsPage())))]),const SizedBox(height:8),buildCard(title:l.currentBalance,value:'Rs. ${currentBalance.toStringAsFixed(2)}',icon:Icons.account_balance_wallet_rounded),buildCard(title:l.totalPieces,value:'$totalPieces',icon:Icons.inventory_2_rounded),buildCard(title:l.todaysEarnings,value:'Rs. ${todayEarning.toStringAsFixed(2)}',icon:Icons.today_rounded),buildCard(title:l.weeklyEarnings,value:'Rs. ${weeklyEarning.toStringAsFixed(2)}',icon:Icons.calendar_view_week_rounded),buildCard(title:l.monthlyEarnings,value:'Rs. ${monthlyEarning.toStringAsFixed(2)}',icon:Icons.calendar_month_rounded),buildCard(title:l.totalEntries,value:'$totalEntries',icon:Icons.format_list_numbered_rounded),buildCard(title:l.totalEarnings,value:'Rs. ${totalEarning.toStringAsFixed(2)}',icon:Icons.payments_rounded)])));});}
  @override void dispose(){clockTimer?.cancel();super.dispose();}
}
