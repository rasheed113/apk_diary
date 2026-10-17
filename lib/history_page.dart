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
  @override State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<DiaryEntry>> entriesFuture;
  final searchController = TextEditingController();
  String searchText = '';
  late String selectedFilter;

  @override
  void initState() { super.initState(); selectedFilter = widget.initialFilter; refreshEntries(); }
  void refreshEntries() { entriesFuture = DatabaseHelper.instance.getAllEntries(); }

  DateTime? _parseDate(String v) { final p = v.split('-'); if (p.length != 3) return null; return DateTime.tryParse('${p[2]}-${p[1]}-${p[0]}'); }
  DateTime _startOfWeek(DateTime d) { final x = DateTime(d.year, d.month, d.day); return x.subtract(Duration(days: x.weekday - 1)); }
  DateTime _endOfWeek(DateTime d) => _startOfWeek(d).add(const Duration(days: 6));
  String _dateLabel(DateTime d) => DateFormat('d MMM').format(d);
  String _weekLabel(DateTime d) => '${_dateLabel(d)}–${_dateLabel(_endOfWeek(d))}';
  String _monthLabel(DateTime d) => DateFormat('MMMM yyyy').format(d);

  List<DateTime> _recentDays(int count) {
    final n = DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    return List.generate(count, (i) => today.subtract(Duration(days: i)));
  }

  String _dayLabel(DateTime d) => DateFormat('d MMMM yyyy').format(d);

  List<DateTime> _weeksForLastFourMonths() { final n = DateTime.now(); final c = DateTime(n.year, n.month - 3, 1); var x = _startOfWeek(n); final r = <DateTime>[]; while (!_endOfWeek(x).isBefore(c)) { r.add(x); x = x.subtract(const Duration(days: 7)); } return r; }
  List<DateTime> _recentMonths(int c) { final n = DateTime.now(); return List.generate(c, (i) => DateTime(n.year, n.month - i, 1)); }
  AppLocalization get _l => AppLocalization(AppLanguageController.currentLanguage.value);

  Widget _shortcutButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    final s = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        height: 52,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [s.surface, s.primary.withValues(alpha: .08)]), border: Border.all(color: s.primary.withValues(alpha: .16)), boxShadow: [BoxShadow(color: s.primary.withValues(alpha: .10), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Material(color: Colors.transparent, child: InkWell(
          borderRadius: BorderRadius.circular(14), onTap: onPressed,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 27, height: 27, decoration: BoxDecoration(borderRadius: BorderRadius.circular(9), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [s.primary.withValues(alpha: .14), s.secondary.withValues(alpha: .08)]), border: Border.all(color: s.primary.withValues(alpha: .14)), boxShadow: [BoxShadow(color: s.primary.withValues(alpha: .08), blurRadius: 6, offset: const Offset(0, 3))]), child: Icon(icon, size: 19, color: s.primary)),
            const SizedBox(width: 5), Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: s.primary))),
          ]),
        )),
      ),
    );
  }

  DateTime _selectedPeriodDate() {
    if (selectedFilter.startsWith('Day:')) return DateTime.parse(selectedFilter.substring(4));
    if (selectedFilter.startsWith('Week:')) return DateTime.parse(selectedFilter.substring(5));
    if (selectedFilter.startsWith('Month:')) {
      final p = selectedFilter.substring(6).split('-');
      return DateTime(int.parse(p[0]), int.parse(p[1]), 1);
    }
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  void _selectPeriod(String type) {
    final n = DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    setState(() {
      if (type == 'Day') selectedFilter = 'Day:${today.toIso8601String()}';
      if (type == 'Week') selectedFilter = 'Week:${_startOfWeek(today).toIso8601String()}';
      if (type == 'Month') selectedFilter = 'Month:${today.year}-${today.month.toString().padLeft(2, '0')}';
    });
  }

  void _navigatePeriod(int direction) {
    final current = _selectedPeriodDate();
    setState(() {
      if (selectedFilter == 'Today' || selectedFilter.startsWith('Day:')) {
        final d = current.add(Duration(days: direction));
        selectedFilter = 'Day:${DateTime(d.year, d.month, d.day).toIso8601String()}';
      } else if (selectedFilter.startsWith('Week:')) {
        final d = current.add(Duration(days: 7 * direction));
        selectedFilter = 'Week:${_startOfWeek(d).toIso8601String()}';
      } else if (selectedFilter.startsWith('Month:')) {
        final d = DateTime(current.year, current.month + direction, 1);
        selectedFilter = 'Month:${d.year}-${d.month.toString().padLeft(2, '0')}';
      }
    });
  }

  Widget _periodNavigator(ColorScheme s, AppLocalization l) {
    final isDay = selectedFilter == 'Today' || selectedFilter.startsWith('Day:');
    final isWeek = selectedFilter.startsWith('Week:');
    final isMonth = selectedFilter.startsWith('Month:');
    final d = _selectedPeriodDate();
    final label = isDay ? _dayLabel(d) : isWeek ? _weekLabel(_startOfWeek(d)) : isMonth ? _monthLabel(d) : _dayLabel(d);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: s.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: s.primary.withValues(alpha: .16)),
        ),
        child: Row(children: [
          IconButton(
            tooltip: 'Previous',
            onPressed: () => _navigatePeriod(-1),
            icon: Icon(Icons.chevron_left_rounded, color: s.primary, size: 30),
          ),
          Expanded(child: Column(children: [
            Text(isDay ? l.dailyHistory : isWeek ? l.weeklyHistory : l.monthlyHistory,
              style: TextStyle(fontSize: 11, color: s.onSurfaceVariant, fontWeight: FontWeight.w600)),
            Text(label, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: s.onSurface, fontWeight: FontWeight.w800)),
          ])),
          IconButton(
            tooltip: 'Next',
            onPressed: () => _navigatePeriod(1),
            icon: Icon(Icons.chevron_right_rounded, color: s.primary, size: 30),
          ),
        ]),
      ),
    );
  }

  Future<void> _searchByMonth() async { final n = DateTime.now(); final l = _l; final p = await showDatePicker(context: context, initialDate: n, firstDate: DateTime(2000), lastDate: DateTime(n.year + 1, 12, 31), helpText: l.selectAnyDateInMonth, fieldLabelText: l.monthLabel); if (p == null || !mounted) return; setState(() => selectedFilter = 'Month:${p.year}-${p.month.toString().padLeft(2, '0')}'); }
  Future<void> deleteEntry(int id) async { await DatabaseHelper.instance.deleteEntry(id); setState(refreshEntries); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_l.entryDeletedSuccessfully))); }
  Future<void> confirmDelete(DiaryEntry entry) async { final l = _l; final confirm = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: Text(l.deleteEntry), content: Text('${l.deleteEntryConfirmation}\n\n${entry.itemName}'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.cancel)), TextButton(onPressed: () => Navigator.pop(c, true), child: Text(l.delete))])); if (confirm == true) await deleteEntry(entry.id!); }

  Widget themedCard({required Widget child, EdgeInsetsGeometry margin = const EdgeInsets.all(8), EdgeInsetsGeometry padding = const EdgeInsets.all(12)}) { final s = Theme.of(context).colorScheme; return Card(margin: margin, elevation: 2, color: s.surfaceContainerHighest, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: s.primary.withValues(alpha: .12))), shadowColor: s.primary.withValues(alpha: .10), child: Padding(padding: padding, child: child)); }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme; final l = _l;
    return Scaffold(
      backgroundColor: s.surface,
      appBar: AppBar(title: Text(l.history), backgroundColor: s.surface, elevation: 0),
      body: FutureBuilder<List<DiaryEntry>>(
        future: entriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('${l.errorPrefix}: ${snapshot.error}'));
          final entries = snapshot.data ?? [];
          final filtered = entries.where((entry) {
            final q = searchText.trim().toLowerCase();
            final d = _parseDate(entry.workDate); if (d == null) return false;
            final searchableDate = '${entry.workDate.toLowerCase()} ${DateFormat('d MMMM yyyy').format(d).toLowerCase()} ${DateFormat('d MMM yyyy').format(d).toLowerCase()}';
            if (!entry.itemName.toLowerCase().contains(q) && !searchableDate.contains(q)) return false;
            final x = DateTime(d.year, d.month, d.day);
            if (selectedFilter == 'Today') { final n = DateTime.now(); return x == DateTime(n.year, n.month, n.day); }
            if (selectedFilter.startsWith('Day:')) { final selected = DateTime.tryParse(selectedFilter.substring(4)); return selected != null && x == DateTime(selected.year, selected.month, selected.day); }
            if (selectedFilter.startsWith('Week:')) { final w = DateTime.tryParse(selectedFilter.substring(5)); if (w == null) return false; return !x.isBefore(_startOfWeek(w)) && !x.isAfter(_endOfWeek(w)); }
            if (selectedFilter.startsWith('Month:')) { final p = selectedFilter.substring(6).split('-'); final y = int.tryParse(p[0]); final m = int.tryParse(p[1]); return y != null && m != null && d.year == y && d.month == m; }
            return true;
          }).toList();
          filtered.sort((a, b) {
            final aDate = _parseDate(a.workDate)!;
            final bDate = _parseDate(b.workDate)!;
            final dateOrder = DateTime(bDate.year, bDate.month, bDate.day).compareTo(DateTime(aDate.year, aDate.month, aDate.day));
            if (dateOrder != 0) return dateOrder;
            return (b.id ?? 0).compareTo(a.id ?? 0);
          });
          final totalPieces = filtered.fold<int>(0, (sum, e) => sum + e.pieces);
          final totalEarnings = filtered.fold<double>(0, (sum, e) => sum + e.total);
          return Column(children: [
            Padding(padding: const EdgeInsets.all(8), child: TextField(controller: searchController, style: TextStyle(color: s.onSurface), decoration: InputDecoration(hintText: l.searchItemOrDate, hintStyle: TextStyle(color: s.onSurfaceVariant), prefixIcon: Icon(Icons.search, color: s.primary), filled: true, fillColor: s.surfaceContainerHighest, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: s.primary.withValues(alpha: .14))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: s.primary.withValues(alpha: .14)))), onChanged: (v) => setState(() => searchText = v))),
            Padding(padding: const EdgeInsets.fromLTRB(8, 8, 8, 0), child: Row(children: [
              _shortcutButton(icon: Icons.today_rounded, label: l.daily, onPressed: () => _selectPeriod('Day')),
              const SizedBox(width: 6),
              _shortcutButton(icon: Icons.calendar_view_week_rounded, label: l.weekly, onPressed: () => _selectPeriod('Week')),
              const SizedBox(width: 6),
              _shortcutButton(icon: Icons.calendar_month_rounded, label: l.monthly, onPressed: () => _selectPeriod('Month')),
            ])),
            _periodNavigator(s, l),
            const SizedBox(height: 8),
            themedCard(child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Column(children: [Icon(Icons.list_alt_rounded, color: s.primary), const SizedBox(height: 2), Text(l.entries, style: TextStyle(fontWeight: FontWeight.bold, color: s.onSurfaceVariant)), Text(filtered.length.toString(), style: TextStyle(color: s.onSurface, fontWeight: FontWeight.w800))]), Column(children: [Icon(Icons.numbers, color: s.primary), const SizedBox(height: 2), Text(l.pieces, style: TextStyle(fontWeight: FontWeight.bold, color: s.onSurfaceVariant)), Text(totalPieces.toString(), style: TextStyle(color: s.onSurface, fontWeight: FontWeight.w800))]), Column(children: [Icon(Icons.payments, color: s.primary), const SizedBox(height: 2), Text(l.earnings, style: TextStyle(fontWeight: FontWeight.bold, color: s.onSurfaceVariant)), Text(totalEarnings.toStringAsFixed(0), style: TextStyle(color: s.onSurface, fontWeight: FontWeight.w800))])])),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Text(l.noEntriesYet, style: TextStyle(color: s.onSurfaceVariant)))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final entry = filtered[index];
                        final date = _parseDate(entry.workDate);
                        final dayName = date == null ? '' : DateFormat('EEEE').format(date);
                        return themedCard(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            leading: Icon(Icons.receipt_long_rounded, color: s.primary, size: 25),
                            title: Text(entry.itemName, style: TextStyle(fontWeight: FontWeight.bold, color: s.onSurface)),
                            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${l.item}: ${entry.itemName}', style: TextStyle(color: s.onSurfaceVariant)), if (entry.sizes.trim().isNotEmpty) Text('${l.size}: ${entry.sizes}', style: TextStyle(color: s.onSurfaceVariant)), Text('${l.pieces}: ${entry.pieces}', style: TextStyle(color: s.onSurfaceVariant)), Text('${l.total}: Rs ${entry.total.toStringAsFixed(0)}', style: TextStyle(color: s.onSurfaceVariant, fontWeight: FontWeight.w700)), Text('$dayName, ${entry.workDate}', style: TextStyle(color: s.onSurfaceVariant))]),
                            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 38, minHeight: 38), tooltip: l.edit, icon: Icon(Icons.edit_rounded, size: 21, color: s.primary), onPressed: () async { final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => WorkPage(entry: entry))); if (r == true && mounted) setState(refreshEntries); }),
                              IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 38, minHeight: 38), tooltip: l.delete, icon: Icon(Icons.delete_outline_rounded, size: 23, color: s.error), onPressed: () => confirmDelete(entry)),
                            ]),
                          ),
                        );
                      },
                    ),
            ),
          ]);
        },
      ),
    );
  }
  @override void dispose() { searchController.dispose(); super.dispose(); }
}
