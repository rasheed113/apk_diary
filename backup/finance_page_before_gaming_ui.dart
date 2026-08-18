import 'package:flutter/material.dart';

import 'database_helper.dart';
import 'finance_record.dart';
import 'package:intl/intl.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  double currentBalance = 0;
  double salaryReceived = 0;
  double advanceReceived = 0;
  Future<void> confirmDelete(FinanceRecord record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Finance Record'),
          content: Text(
            'Delete ${record.type} (Rs ${record.amount.toStringAsFixed(0)}) ?',
          ),
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
        );
      },
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteFinanceRecord(record.id!);

      await loadFinance();

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Finance Record Deleted Successfully ✅')),
      );
    }
  }

  Future<void> editFinanceRecord(FinanceRecord record) async {
    if (!mounted) return;

    String selectedType = record.type;

    final amountController = TextEditingController(
      text: record.amount.toString(),
    );

    final reasonController = TextEditingController(text: record.reason);
    final dialogContext = context;

    final result = await showDialog<bool>(
      context: dialogContext,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Finance Record'),

              content: SingleChildScrollView(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,

                      items: const [
                        DropdownMenuItem(
                          value: 'Salary Received',
                          child: Text('Salary Received'),
                        ),
                        DropdownMenuItem(
                          value: 'Advance Received',
                          child: Text('Advance Received'),
                        ),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],

                      onChanged: (value) {
                        setDialogState(() {
                          selectedType = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Amount'),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: reasonController,
                      decoration: const InputDecoration(labelText: 'Reason'),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text) ?? 0;

                    if (amount <= 0) return;

                    final updatedRecord = FinanceRecord(
                      id: record.id,
                      type: selectedType,
                      amount: amount,
                      reason: reasonController.text,
                      recordDate: record.recordDate,
                      createdTime: record.createdTime,
                    );

                    await DatabaseHelper.instance.updateFinanceRecord(
                      updatedRecord,
                    );

                    if (!mounted) return;

                    Navigator.of(dialogContext).pop(true);
                  },

                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      await loadFinance();

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Finance Record Updated ✅')));
    }
  }

  @override
  void initState() {
    super.initState();
    loadFinance();
  }

  Future<void> addFinanceRecord() async {
    String selectedType = 'Salary Received';

    final amountController = TextEditingController();
    final reasonController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Finance Record'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      items: const [
                        DropdownMenuItem(
                          value: 'Salary Received',
                          child: Text('Salary Received'),
                        ),
                        DropdownMenuItem(
                          value: 'Advance Received',
                          child: Text('Advance Received'),
                        ),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedType = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Amount'),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: reasonController,
                      decoration: const InputDecoration(labelText: 'Reason'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text) ?? 0;

                    if (amount <= 0) {
                      return;
                    }

                    final record = FinanceRecord(
                      type: selectedType,
                      amount: amount,
                      reason: reasonController.text,
                      recordDate: DateFormat(
                        'dd-MM-yyyy',
                      ).format(DateTime.now()),
                      createdTime: DateFormat('hh:mm a').format(DateTime.now()),
                    );
                    await DatabaseHelper.instance.insertFinanceRecord(record);

                    if (!context.mounted) return;

                    Navigator.pop(context, true);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      await loadFinance();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Finance Record Saved ✅')));
    }
  }

  Future<void> loadFinance() async {
    final balance = await DatabaseHelper.instance.getBalance();
    final salary = await DatabaseHelper.instance.getSalaryReceived();
    final advance = await DatabaseHelper.instance.getAdvanceReceived();

    if (!mounted) return;

    setState(() {
      currentBalance = balance;
      salaryReceived = salary;
      advanceReceived = advance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finance')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.green.shade100,
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.green,
                        size: 30,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Current Balance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Rs ${currentBalance.toStringAsFixed(0)}',
                      style: TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  color: currentBalance < 0
      ? Colors.red
      : Colors.green,
),
                    ),
                  ],
                ),
              ),
            ),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Salary',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Rs ${salaryReceived.toStringAsFixed(0)}'),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          'Advance',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Rs ${advanceReceived.toStringAsFixed(0)}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: addFinanceRecord,
                icon: const Icon(Icons.add),
                label: const Text('Add Finance Record'),
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: FutureBuilder(
                future: DatabaseHelper.instance.getAllFinanceRecords(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final records = snapshot.data!;

                  if (records.isEmpty) {
                    return const Center(child: Text('No Finance Records'));
                  }

                  return ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];

                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.account_balance_wallet),
                          title: Text(record.type),
                          subtitle: Text(
                            '${record.reason}\n${record.recordDate}',
                          ),
                          trailing: SizedBox(
                            width: 150,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Rs ${record.amount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),

                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () async {
                                    await editFinanceRecord(record);
                                  },
                                ),

                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    confirmDelete(record);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
