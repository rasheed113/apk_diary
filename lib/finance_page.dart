import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'database_helper.dart';
import 'finance_record.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  double currentBalance = 0;
  double salaryReceived = 0;
  double advanceReceived = 0;

  @override
  void initState() {
    super.initState();
    loadFinance();
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

  Future<void> confirmDelete(FinanceRecord record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Finance Record'),
        content: Text(
          'Delete ${record.type} (Rs ${record.amount.toStringAsFixed(0)}) ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await DatabaseHelper.instance.deleteFinanceRecord(record.id!);
    await loadFinance();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Finance Record Deleted Successfully ✅')),
    );
  }

  Future<void> editFinanceRecord(FinanceRecord record) async {
    String selectedType = record.type;
    final amountController = TextEditingController(text: record.amount.toString());
    final reasonController = TextEditingController(text: record.reason);

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Finance Record'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  items: const [
                    DropdownMenuItem(value: 'Salary Received', child: Text('Salary Received')),
                    DropdownMenuItem(value: 'Advance Received', child: Text('Advance Received')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    if (value != null) setDialogState(() => selectedType = value);
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
              onPressed: () => Navigator.pop(dialogContext, false),
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
                await DatabaseHelper.instance.updateFinanceRecord(updatedRecord);

                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );

    amountController.dispose();
    reasonController.dispose();

    if (result == true) {
      await loadFinance();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Finance Record Updated ✅')),
      );
    }
  }

  Future<void> addFinanceRecord() async {
    String selectedType = 'Salary Received';
    final amountController = TextEditingController();
    final reasonController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Finance Record'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  items: const [
                    DropdownMenuItem(value: 'Salary Received', child: Text('Salary Received')),
                    DropdownMenuItem(value: 'Advance Received', child: Text('Advance Received')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    if (value != null) setDialogState(() => selectedType = value);
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
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text) ?? 0;
                if (amount <= 0) return;

                final record = FinanceRecord(
                  type: selectedType,
                  amount: amount,
                  reason: reasonController.text,
                  recordDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
                  createdTime: DateFormat('hh:mm a').format(DateTime.now()),
                );
                await DatabaseHelper.instance.insertFinanceRecord(record);

                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    amountController.dispose();
    reasonController.dispose();

    if (result == true) {
      await loadFinance();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Finance Record Saved ✅')),
      );
    }
  }

  Widget _financeMiniCard(String title, double value, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).cardColor,
        border: Border.all(color: scheme.primary.withValues(alpha: 0.45)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: scheme.primary),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            'Rs ${value.toStringAsFixed(0)}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: scheme.primary),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Finance')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).cardColor,
                border: Border.all(color: scheme.primary.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  Icon(Icons.account_balance_wallet, color: scheme.primary, size: 34),
                  const SizedBox(height: 6),
                  const Text('Current Balance', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    'Rs ${currentBalance.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: currentBalance < 0 ? Colors.red : scheme.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _financeMiniCard('SALARY', salaryReceived, Icons.payments)),
                const SizedBox(width: 10),
                Expanded(child: _financeMiniCard('ADVANCE', advanceReceived, Icons.account_balance)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: addFinanceRecord,
                icon: const Icon(Icons.add),
                label: const Text('Add Finance Record'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder(
                future: DatabaseHelper.instance.getAllFinanceRecords(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final records = snapshot.data!;
                  if (records.isEmpty) return const Center(child: Text('No Finance Records'));

                  return ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return Card(
                        child: ListTile(
                          leading: Icon(Icons.account_balance_wallet, color: scheme.primary),
                          title: Text(record.type),
                          subtitle: Text('${record.reason}\n${record.recordDate}'),
                          trailing: SizedBox(
                            width: 150,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Rs ${record.amount.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => editFinanceRecord(record),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => confirmDelete(record),
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
