import 'package:flutter/material.dart' hide Icon;
import 'package:intl/intl.dart';
import 'modern_icons.dart';
import 'database_helper.dart';
import 'diary_entry.dart';
import 'work_page.dart';
import 'i18n/app_localization.dart';
import 'i18n/app_language_controller.dart';

class HistoryPage extends StatefulWidget {
  final String initialFilter;
  const HistoryPage({super.key, this.initialFilter = 'Today'});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<DiaryEntry>> entriesFuture;
  final searchController = TextEditingController();
  String searchText = '';
  late String selectedFilter;

  @override
  void initState() { super.initState(); selectedFilter = widget.initialFilter; refreshEntries(); }
  void refreshEntries() => entriesFuture = DatabaseHelper.instance.getAllEntries();

  DateTime? _parseDate(String v) { final p = v.split('-'); if (p.length != 3) return null; return DateTime.tryParse('${p[2]}-${p[1]}-${p[0]}'); }
  DateTime _startOfWeek(DateTime d) { final x = DateTime(d.year, d.month, d.day); return x.subtract(Duration(days: x.weekday - 1)); }
  DateTime _endOfWeek(DateTime d) => _startOfWeek(d).add(const Duration(days: 6));
  String _dateLabel(DateTime d) => DateFormat('d MMM').format(d);
  String _weekLabel(DateTime d) => '${_dateLabel(d)}–${_dateLabel(_endOfWeek(d))}';
  String _monthLabel(DateTime d) => DateFormat('MMMM yyyy').format(d);

  List<DateTime> _weeksForLastFourMonths() { final n = DateTime.now(); final c = DateTime(n.year, n.month - 3, 1); var x = _startOfWeek(n); final r = <DateTime>[]; while (!x.isBefore(c)) { r.add(x); x = x.subtract(const Duration(days: 7)); } return r; }
  List<DateTime> _recentMonths(int c) { final n = DateTime.now(); return List.generate(c, (i) => DateTime(n.year, n.month - i, 1)); }
  AppLocalization get _l => AppLocalization(AppLanguageController.currentLanguage.value);

  Widget _shortcutButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    final s = Theme.of(context).colorScheme;
    return Expanded(child: Container(height: 58, decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [s.surface, s.primary.withValues(alpha: .08)]), border: Border.all(color: s.primary.withValues(alpha: .16)), boxShadow: [BoxShadow(color: s.primary.withValues(alpha: .10), blurRadius: 10, offset: const Offset(0, 4))]), child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(18), onTap: onPressed, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 34, height: 34, decoration: BoxDecoration(borderRadius: BorderRadius.circular(11), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [s.primary.withValues(alpha: .14), s.secondary.withValues(alpha: .08)]), border: Border.all(color: s.primary.withValues(alpha: .14)), boxShadow: [BoxShadow(color: s.primary.withValues(alpha: .08), blurRadius: 6, offset: const Offset(0, 3))]), child: Icon(icon, size: 19, color: s.primary)), const SizedBox(width: 8), Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w900, color: s.primary)))]))));
  }

  Future<void> _showWeeklyHistory() async { final weeks = _weeksForLastFourMonths(); await showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (sc) { final s = Theme.of(sc).colorScheme; final l = _l; return SafeArea(child: SizedBox(height: MediaQuery.of(sc).size.height * .78, child: Column(children: [Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 12), child: Text(l.weeklyHistory, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: s.onSurface))), Expanded(child: ListView.builder(itemCount: weeks.length, itemBuilder: (c, i) { final w = weeks[i]; return ListTile(leading: Icon(Icons.calendar_view_week, color: s.primary), title: Text(i == 0 ? l.thisWeek : '$i ${l.week}', style: TextStyle(fontWeight: FontWeight.w700, color: s.onSurface)), subtitle: Text(_weekLabel(w), style: TextStyle(color: s.onSurfaceVariant)), trailing: Icon(Icons.chevron_right, color: s.primary), onTap: () { Navigator.pop(sc); setState(() => selectedFilter = 'Week:${w.toIso8601String()}'); }); }))])); }); }

  Future<void> _showMonthlyHistory() async { final months = _recentMonths(12); await showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (sc) { final s = Theme.of(sc).colorScheme; final l = _l; return SafeArea(child: SizedBox(height: MediaQuery.of(sc).size.height * .78, child: Column(children: [Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 12), child: Text(l.monthlyHistory, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: s.onSurface))), Expanded(child: ListView.builder(itemCount: months.length, itemBuilder: (c, i) { final m = months[i]; return ListTile(leading: Icon(Icons.calendar_month, color: s.primary), title: Text(i == 0 ? l.thisMonth : '$i ${l.month}', style: TextStyle(fontWeight: FontWeight.w700, color: s.onSurface)), subtitle: Text(_monthLabel(m), style: TextStyle(color: s.onSurfaceVariant)), trailing: Icon(Icons.chevron_right, color: s.primary), onTap: () { Navigator.pop(sc); setState(() => selectedFilter = 'Month:${m.year}-${m.month.toString().padLeft(2, '0')}'); }); }))])); }); }

  Future<void> _searchByMonth() async { final n = DateTime.now(); final l = _l; final p = await showDatePicker(context: context, initialDate: n, firstDate: DateTime(2000), lastDate: DateTime(n.year + 1, 12, 31), helpText: l.selectAnyDateInMonth, fieldLabelText: l.monthLabel); if (p == null || !mounted) return; setState(() => selectedFilter = 'Month:${p.year}-${p.month.toString().padLeft(2, '0')}'); }
  Future<void> deleteEntry(int id) async { await DatabaseHelper.instance.deleteEntry(id); setState(refreshEntries); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_l.entryDeletedSuccessfully))); }
  Future<void> confirmDelete(DiaryEntry entry) async { final l = _l; final confirm = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: Text(l.deleteEntry), content: Text('${l.deleteEntryConfirmation}\n\n${entry.itemName}'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.cancel)), TextButton(onPressed: () => Navigator.pop(c, true), child: Text(l.delete))])); if (confirm == true) await deleteEntry(entry.id!); }

  Widget themedCard({required Widget child, EdgeInsetsGeometry margin = const EdgeInsets.all(8), EdgeInsetsGeometry padding = const EdgeInsets.all(12)}) { final s = Theme.of(context).colorScheme; return Card(margin: margin, elevation: 2, color: s.surfaceContainerHighest, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: s.primary.withValues(alpha: .12))), shadowColor: s.primary.withValues(alpha: .10), child: Padding(padding: padding, child: child)); }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme; final l = _l;
    return Scaffold(backgroundColor: s.surface, appBar: AppBar(title: Text(l.history), backgroundColor: s.surface, elevation: 0), body: FutureBuilder<List<DiaryEntry>>(future: entriesFuture, builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
      if (snapshot.hasError) return Center(child: Text('${l.errorPrefix}: ${snapshot.error}'));
      final entries = snapshot.data ?? [];
      final filtered = entries.where((entry) {
        final q = searchText.toLowerCase(); if (!entry.itemName.toLowerCase().contains(q) && !entry.workDate.toLowerCase().contains(q)) return false;
        final d = _parseDate(entry.workDate); if (d == null) return false; final x = DateTime(d.year, d.month, d.day);
        if (selectedFilter == 'Today') { final n = DateTime.now(); return x == DateTime(n.year, n.month, n.day); }
        if (selectedFilter.startsWith('Week:')) { final w = DateTime.tryParse(selectedFilter.substring(5)); if (w == null) return false; return !x.isBefore(_startOfWeek(w)) && !x.isAfter(_endOfWeek(w)); }
        if (selectedFilter.startsWith('Month:')) { final p = selectedFilter.substring(6).split('-'); final y = int.tryParse(p[0]); final m = int.tryParse(p[1]); return y != null && m != null && d.year == y && d.month == m; }
        return true;
      }).toList();
      final totalPieces = filtered.fold<int>(0, (sum, e) => sum + e.pieces); final totalEarnings = filtered.fold<double>(0, (sum, e) => sum + e.total);
      return Column(children: [
        Padding(padding: const EdgeInsets.all(8), child: TextField(controller: searchController, style: TextStyle(color: s.onSurface), decoration: InputDecoration(hintText: l.searchItemOrDate, hintStyle: TextStyle(color: s.onSurfaceVariant), prefixIcon: Icon(Icons.search, color: s.primary), filled: true, fillColor: s.surfaceContainerHighest, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: s.primary.withValues(alpha: .14))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: s.primary.withValues(alpha: .14)))), onChanged: (v) => setState(() => searchText = v))),
        Padding(padding: const EdgeInsets.fromLTRB(8, 8, 8, 0), child: Row(children: [_shortcutButton(icon: Icons.calendar_view_week_rounded, label: l.weeklyHistory, onPressed: _showWeeklyHistory), const SizedBox(width: 8), _shortcutButton(icon: Icons.calendar_month_rounded, label: l.monthlyHistory, onPressed: _showMonthlyHistory)])),
        if (selectedFilter == 'Today') Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 0), child: Align(alignment: Alignment.centerLeft, child: Text('${l.today}: ${DateFormat('d MMMM yyyy').format(DateTime.now())}', style: TextStyle(fontWeight: FontWeight.w700, color: s.onSurfaceVariant))),
        if (selectedFilter.startsWith('Week:') || selectedFilter.startsWith('Month:')) Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 0), child: Row(children: [Expanded(child: Text(selectedFilter.startsWith('Week:') ? '${l.selectedWeek}: ${_weekLabel(DateTime.parse(selectedFilter.substring(5)))}' : '${l.selectedMonth}: ${_monthLabel(DateTime.parse('${selectedFilter.substring(6)}-01'))}', style: TextStyle(fontWeight: FontWeight.w700, color: s.onSurface))), TextButton(onPressed: () => setState(() => selectedFilter = 'Today'), child: Text(l.clear))])),
        const SizedBox(height: 8),
        themedCard(child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Column(children: [Icon(Icons.list_alt_rounded, color: s.primary), const SizedBox(height: 2), Text(l.entries, style: TextStyle(fontWeight: FontWeight.bold, color: s.onSurfaceVariant)), Text(filtered.length.toString(), style: TextStyle(color: s.onSurface, fontWeight: FontWeight.w800))]), Column(children: [Icon(Icons.numbers, color: s.primary), const SizedBox(height: 2), Text(l.pieces, style: TextStyle(fontWeight: FontWeight.bold, color: s.onSurfaceVariant)), Text(totalPieces.toString(), style: TextStyle(color: s.onSurface, fontWeight: FontWeight.w800))]), Column(children: [Icon(Icons.payments, color: s.primary), const SizedBox(height: 2), Text(l.earnings, style: TextStyle(fontWeight: FontWeight.bold, color: s.onSurfaceVariant)), Text(totalEarnings.toStringAsFixed(0), style: TextStyle(color: s.onSurface, fontWeight: FontWeight.w800))])])),
        const SizedBox(height: 8),
        Expanded(child: filtered.isEmpty ? Center(child: Text(l.noEntriesYet, style: TextStyle(color: s.onSurfaceVariant))) : ListView.builder(itemCount: filtered.length, itemBuilder: (context, index) { final entry = filtered[index]; final date = _parseDate(entry.workDate); final dayName = date == null ? '' : DateFormat('EEEE').format(date); return themedCard(margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), leading: Icon(Icons.receipt_long_rounded, color: s.primary, size: 25), title: Text(entry.itemName, style: TextStyle(fontWeight: FontWeight.bold, color: s.onSurface)), subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${l.item}: ${entry.itemName}', style: TextStyle(color: s.onSurfaceVariant)), if (entry.sizes.trim().isNotEmpty) Text('${l.size}: ${entry.sizes}', style: TextStyle(color: s.onSurfaceVariant)), Text('${l.pieces}: ${entry.pieces}', style: TextStyle(color: s.onSurfaceVariant)), Text('${l.total}: Rs ${entry.total.toStringAsFixed(0)}', style: TextStyle(color: s.onSurfaceVariant, fontWeight: FontWeight.w700)), Text('$dayName, ${entry.workDate}', style: TextStyle(color: s.onSurfaceVariant))]), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 38, minHeight: 38), tooltip: l.edit, icon: Icon(Icons.edit_rounded, size: 21, color: s.primary), onPressed: () async { final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => WorkPage(entry: entry))); if (r == true && mounted) setState(refreshEntries); }), IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 38, minHeight: 38), tooltip: l.delete, icon: Icon(Icons.delete_outline_rounded, size: 23, color: s.error), onPressed: () => confirmDelete(entry))])); }))));
    });
  }
  @override void dispose() { searchController.dispose(); super.dispose(); }
}
