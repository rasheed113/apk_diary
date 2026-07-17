import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'diary_entry.dart';
import 'work_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<DiaryEntry>> entriesFuture;
  final TextEditingController searchController = TextEditingController();

  String searchText = '';
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    refreshEntries();
  }

  void refreshEntries() {
    entriesFuture = DatabaseHelper.instance.getAllEntries();
  }

  Future<void> deleteEntry(int id) async {
    await DatabaseHelper.instance.deleteEntry(id);

    setState(() {
      refreshEntries();
    });

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Entry Deleted Successfully')));
  }

  Future<void> confirmDelete(DiaryEntry entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Entry'),
          content: Text('Delete "${entry.itemName}" ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await deleteEntry(entry.id!);
    }
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

          final filteredEntries = entries.where((entry) {
            final query = searchText.toLowerCase();

            bool matchesSearch =
                entry.itemName.toLowerCase().contains(query) ||
                entry.workDate.toLowerCase().contains(query);

            if (!matchesSearch) return false;

            if (selectedFilter == 'Today') {
              final todayStr =
                  '${today.day.toString().padLeft(2, '0')}-${today.month.toString().padLeft(2, '0')}-${today.year}';

              return entry.workDate == todayStr;
            }

            if (selectedFilter == 'This Month') {
              final monthStr =
                  '-${today.month.toString().padLeft(2, '0')}-${today.year}';

              return entry.workDate.contains(monthStr);
            }

            return true;
          }).toList();

          if (filteredEntries.isEmpty) {
            return const Center(child: Text('No Entries Yet'));
          }
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
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
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
                        onSelected: (_) {
                          setState(() {
                            selectedFilter = 'All';
                          });
                        },
                      ),

                      const SizedBox(width: 8),

                      ChoiceChip(
                        label: const Text('Today'),
                        selected: selectedFilter == 'Today',
                        onSelected: (_) {
                          setState(() {
                            selectedFilter = 'Today';
                          });
                        },
                      ),

                      const SizedBox(width: 8),

                      ChoiceChip(
                        label: const Text('This Month'),
                        selected: selectedFilter == 'This Month',
                        onSelected: (_) {
                          setState(() {
                            selectedFilter = 'This Month';
                          });
                        },
                      ),
                    ],
                  ),
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
                          const Text(
                            'Entries',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(filteredEntries.length.toString()),
                        ],
                      ),

                      Column(
                        children: [
                          const Text(
                            'Pieces',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            filteredEntries
                                .fold<int>(0, (sum, e) => sum + e.pieces)
                                .toString(),
                          ),
                        ],
                      ),

                      Column(
                        children: [
                          const Text(
                            'Earnings',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Rs ${filteredEntries.fold<double>(0, (sum, e) => sum + e.total).toStringAsFixed(0)}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: ListView.builder(
                  itemCount: filteredEntries.length,
                  itemBuilder: (context, index) {
                    final entry = filteredEntries[index];

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(
                            entry.itemName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Builder(
                            builder: (context) {
                              final parts = entry.workDate.split('-');

                              final date = DateTime(
                                int.parse(parts[2]),
                                int.parse(parts[1]),
                                int.parse(parts[0]),
                              );

                              final dayName = DateFormat('EEEE').format(date);

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Item: ${entry.itemName}'),

                                  if (entry.sizes.trim().isNotEmpty)
                                    Text('Size: ${entry.sizes}'),

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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.green,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => WorkPage(entry: entry),
                                      ),
                                    );
                                    if (result == true) {
                                      refreshEntries();
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    confirmDelete(entry);
                                  },
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
}
