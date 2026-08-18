import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'diary_entry.dart';
import 'work_page.dart';

class HistoryPage extends StatefulWidget {
  final String initialFilter;

  const HistoryPage({super.key, this.initialFilter = 'All'});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<DiaryEntry>> entriesFuture;
  final TextEditingController searchController = TextEditingController();

  String searchText = '';
  late String selectedFilter;

  @override
  void initState() {
    super.initState();
    selectedFilter = widget.initialFilter;
    refreshEntries();
  }

  void refreshEntries() {
    entriesFuture = DatabaseHelper.instance.getAllEntries();
  }

  DateTime? _parseDate(String value) {
    final parts = value.split('-');
    if (parts.length != 3) return null;
    return DateTime.tryParse('${parts[2]}-${parts[1]}-${parts[0]}');
  }

  DateTime _startOfWeek(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  DateTime _endOfWeek(DateTime date) => _startOfWeek(date).add(const Duration(days: 6));

  String _dateLabel(DateTime date) => DateFormat('d MMM').format(date);

  String _weekLabel(DateTime start) {
    final end = _endOfWeek(start);
    return '${_dateLabel(start)}–${_dateLabel(end)}';
  }

  String _monthLabel(DateTime date) => DateFormat('MMMM yyyy').format(date);

  List<DateTime> _recentWeeks(int count) {
    final current = _startOfWeek(DateTime.now());
    return List.generate(count, (index) => current.subtract(Duration(days: 7 * index)));
  }

  List<DateTime> _weeksForLastFourMonths() {
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month - 3, 1);
    final current = _startOfWeek(now);
    final weeks = <DateTime>[];
    var cursor = current;
    while (!cursor.isBefore(cutoff)) {
      weeks.add(cursor);
      cursor = cursor.subtract(const Duration(days: 7));
    }
    return weeks;
  }

  List<DateTime> _recentMonths(int count) {
    final now = DateTime.now();
    return List.generate(count, (index) => DateTime(now.year, now.month - index, 1));
  }

  Future<void> _showWeeklyHistory() async {
    final weeks = _weeksForLastFourMonths();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final scheme = Theme.of(sheetContext).colorScheme;
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.78,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_view_week, color: scheme.primary),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text('Weekly History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: weeks.length,
                    itemBuilder: (context, index) {
                      final week = weeks[index];
                      final label = index == 0 ? 'This Week' : '${index} Week';
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: scheme.primary.withValues(alpha: 0.10),
                          child: Icon(Icons.calendar_view_week, color: scheme.primary, size: 20),
                        ),
                        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(_weekLabel(week)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          setState(() => selectedFilter = 'Week:${week.toIso8601String()}');
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showMonthlyHistory() async {
    final months = _recentMonths(12);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final scheme = Theme.of(sheetContext).colorScheme;
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.78,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month, color: scheme.primary),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text('Monthly History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      ),
                      IconButton(
                        tooltip: 'Search by Month',
                        icon: const Icon(Icons.search),
                        onPressed: () async {
                          Navigator.pop(sheetContext);
                          await _searchByMonth();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: months.length,
                    itemBuilder: (context, index) {
                      final month = months[index];
                      final label = index == 0 ? 'This Month' : '${index} Month';
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: scheme.primary.withValues(alpha: 0.10),
                          child: Icon(Icons.calendar_month, color: scheme.primary, size: 20),
                        ),
                        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(_monthLabel(month)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          setState(() => selectedFilter = 'Month:${month.year}-${month.month.toString().padLeft(2, '0')}');
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _searchByMonth() async {
    final initial = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(initial.year + 1, 12, 31),
      helpText: 'Select any date in the month',
      fieldLabelText: 'Month',
    );
    if (picked == null || !mounted) return;
    setState(() {
      selectedFilter = 'Month:${picked.year}-${picked.month.toString().padLeft(2, '0')}';
    });
  }

  Future<void> deleteEntry(int id) async {
    await DatabaseHelper.instance.deleteEntry(id);
    setState(refreshEntries);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entry Deleted Successfully')),
    );
  }

  Future<void> confirmDelete(DiaryEntry entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Delete "${entry.itemName}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) await deleteEntry(entry.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: FutureBuilder<List<DiaryEntry>>(
        future: entriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final entries = snapshot.data ?? [];
          final today = DateTime.now();
          final startOfWeek = _startOfWeek(today);
          final endOfWeek = _endOfWeek(today);
          final filteredEntries = entries.where((entry) {
            final query = searchText.toLowerCase();
            final matchesSearch = entry.itemName.toLowerCase().contains(query) ||
                entry.workDate.toLowerCase().contains(query);
            if (!matchesSearch) return false;

            final entryDate = _parseDate(entry.workDate);
            if (entryDate == null) return false;
            final dateOnly = DateTime(entryDate.year, entryDate.month, entryDate.day);

            if (selectedFilter == 'Today') {
              final todayOnly = DateTime(today.year, today.month, today.day);
              return dateOnly == todayOnly;
            }
            if (selectedFilter == 'This Week') {
              return !dateOnly.isBefore(startOfWeek) && !dateOnly.isAfter(endOfWeek);
            }
            if (selectedFilter == 'This Month') {
              return entryDate.year == today.year && entryDate.month == today.month;
            }
            if (selectedFilter.startsWith('Week:')) {
              final raw = selectedFilter.substring(5);
              final selectedWeek = DateTime.tryParse(raw);
              if (selectedWeek == null) return false;
              final selectedStart = _startOfWeek(selectedWeek);
              final selectedEnd = _endOfWeek(selectedWeek);
              return !dateOnly.isBefore(selectedStart) && !dateOnly.isAfter(selectedEnd);
            }
            if (selectedFilter.startsWith('Month:')) {
              final raw = selectedFilter.substring(6).split('-');
              if (raw.length != 2) return false;
              final year = int.tryParse(raw[0]);
              final month = int.tryParse(raw[1]);
              if (year == null || month == null) return false;
              return entryDate.year == year && entryDate.month == month;
            }
            return true;
          }).toList();

          final totalPieces = filteredEntries.fold<int>(0, (sum, e) => sum + e.pieces);
          final totalEarnings = filteredEntries.fold<double>(0, (sum, e) => sum + e.total);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search Item or Date...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => searchText = value),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: selectedFilter == 'All',
                        onSelected: (_) => setState(() => selectedFilter = 'All'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Today'),
                        selected: selectedFilter == 'Today',
                        onSelected: (_) => setState(() => selectedFilter = 'Today'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('This Week'),
                        selected: selectedFilter == 'This Week',
                        onSelected: (_) => setState(() => selectedFilter = 'This Week'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('This Month'),
                        selected: selectedFilter == 'This Month',
                        onSelected: (_) => setState(() => selectedFilter = 'This Month'),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showWeeklyHistory,
                        icon: const Icon(Icons.calendar_view_week),
                        label: const Text('Weekly History'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showMonthlyHistory,
                        icon: const Icon(Icons.calendar_month),
                        label: const Text('Monthly History'),
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedFilter.startsWith('Week:') || selectedFilter.startsWith('Month:'))
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedFilter.startsWith('Week:')
                              ? 'Selected Week: ${_weekLabel(DateTime.parse(selectedFilter.substring(5)))}'
                              : 'Selected Month: ${_monthLabel(DateTime.parse('${selectedFilter.substring(6)}-01'))}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => selectedFilter = 'All'),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Entries', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(filteredEntries.length.toString()),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Pieces', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(totalPieces.toString()),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Earnings', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Rs ${totalEarnings.toStringAsFixed(0)}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filteredEntries.isEmpty
                    ? const Center(child: Text('No Entries Yet'))
                    : ListView.builder(
                        itemCount: filteredEntries.length,
                        itemBuilder: (context, index) {
                          final entry = filteredEntries[index];
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: ListTile(
                                title: Text(entry.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Builder(
                                  builder: (context) {
                                    final date = _parseDate(entry.workDate);
                                    final dayName = date == null ? '' : DateFormat('EEEE').format(date);
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Item: ${entry.itemName}'),
                                        if (entry.sizes.trim().isNotEmpty) Text('Size: ${entry.sizes}'),
                                        Text('Pieces: ${entry.pieces}'),
                                        Text('$dayName, ${entry.workDate}'),
                                      ],
                                    );
                                  },
                                ),
                                trailing: SizedBox(
                                  width: 150,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Rs ${entry.total.toStringAsFixed(0)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => WorkPage(entry: entry)),
                                          );
                                          if (result == true && mounted) setState(refreshEntries);
                                        },
                                      ),
                                      SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: IconButton(
                                          splashRadius: 26,
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(Icons.delete_forever, color: Colors.red, size: 28),
                                          onPressed: () => confirmDelete(entry),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
