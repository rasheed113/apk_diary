import 'package:flutter/material.dart' hide Icon;
import 'package:intl/intl.dart';
import 'modern_icons.dart';
import 'database_helper.dart';
import 'finance_record.dart';
import 'i18n/app_localization.dart';
import 'i18n/app_language_controller.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});
  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  double currentBalance = 0, salaryReceived = 0, advanceReceived = 0;

  AppLocalization get _l => AppLocalization(AppLanguageController.currentLanguage.value);

  String _localisedFinanceType(String type) {
    final l = _l;
    switch (type) {
      case 'Salary Received':
        return l.salaryReceived;
      case 'Advance Received':
        return l.advanceReceived;
      case 'Other':
        return l.other;
      default:
        return type;
    }
  }

  @override
  void initState() { super.initState(); loadFinance(); }

  Future<void> loadFinance() async {
    final b = await DatabaseHelper.instance.getBalance();
    final s = await DatabaseHelper.instance.getSalaryReceived();
    final a = await DatabaseHelper.instance.getAdvanceReceived();
    if (!mounted) return;
    setState(() { currentBalance = b; salaryReceived = s; advanceReceived = a; });
  }

  Future<void> confirmDelete(FinanceRecord record) async {
    final l = _l;
    final c = await showDialog<bool>(context: context, builder: (d) => AlertDialog(
      title: Text(l.deleteFinanceRecord),
      content: Text('${l.deleteFinanceRecordConfirmation}\n\n${_localisedFinanceType(record.type)} (Rs ${record.amount.toStringAsFixed(0)})'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d, false), child: Text(l.cancel)),
        TextButton.icon(onPressed: () => Navigator.pop(d, true), icon: icon3D(Icons.delete_forever, size: 20), label: Text(l.delete)),
      ],
    ));
    if (c != true) return;
    await DatabaseHelper.instance.deleteFinanceRecord(record.id!);
    await loadFinance();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.financeRecordDeletedSuccessfully)));
  }

  Future<void> editFinanceRecord(FinanceRecord record) async {
    String type = record.type;
    final l = _l;
    final ac = TextEditingController(text: record.amount.toString());
    final rc = TextEditingController(text: record.reason);
    final r = await showDialog<bool>(context: context, builder: (d) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Row(children: [icon3D(Icons.edit, size: 24), const SizedBox(width: 8), Text(l.editFinanceRecord)]),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(initialValue: type, decoration: InputDecoration(prefixIcon: icon3D(Icons.receipt, size: 22), labelText: l.financeType), items: [DropdownMenuItem(value: 'Salary Received', child: Text(l.salaryReceived)), DropdownMenuItem(value: 'Advance Received', child: Text(l.advanceReceived)), DropdownMenuItem(value: 'Other', child: Text(l.other))], onChanged: (v) { if (v != null) setDialogState(() => type = v); }),
          const SizedBox(height: 12),
          TextField(controller: ac, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l.amount, prefixIcon: icon3D(Icons.payments, size: 22))),
          const SizedBox(height: 12),
          TextField(controller: rc, decoration: InputDecoration(labelText: l.reason, prefixIcon: icon3D(Icons.receipt, size: 22))),
        ])),
        actions: [TextButton(onPressed: () => Navigator.pop(d, false), child: Text(l.cancel)), ElevatedButton.icon(onPressed: () async { final amount = double.tryParse(ac.text) ?? 0; if (amount <= 0) return; await DatabaseHelper.instance.updateFinanceRecord(FinanceRecord(id: record.id, type: type, amount: amount, reason: rc.text, recordDate: record.recordDate, createdTime: record.createdTime)); if (!d.mounted) return; Navigator.pop(d, true); }, icon: icon3D(Icons.save, size: 20), label: Text(l.update))],
      ),
    ));
    ac.dispose(); rc.dispose();
    if (r == true) { await loadFinance(); if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.financeRecordUpdated))); }
  }

  Future<void> addFinanceRecord() async {
    String type = 'Salary Received';
    final l = _l;
    final ac = TextEditingController();
    final rc = TextEditingController();
    final r = await showDialog<bool>(context: context, builder: (d) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Row(children: [icon3D(Icons.add, size: 24), const SizedBox(width: 8), Text(l.addFinanceRecord)]),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(initialValue: type, decoration: InputDecoration(prefixIcon: icon3D(Icons.receipt, size: 22), labelText: l.financeType), items: [DropdownMenuItem(value: 'Salary Received', child: Text(l.salaryReceived)), DropdownMenuItem(value: 'Advance Received', child: Text(l.advanceReceived)), DropdownMenuItem(value: 'Other', child: Text(l.other))], onChanged: (v) { if (v != null) setDialogState(() => type = v); }),
          const SizedBox(height: 12),
          TextField(controller: ac, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l.amount, prefixIcon: icon3D(Icons.payments, size: 22))),
          const SizedBox(height: 12),
          TextField(controller: rc, decoration: InputDecoration(labelText: l.reason, prefixIcon: icon3D(Icons.receipt, size: 22))),
        ])),
        actions: [TextButton(onPressed: () => Navigator.pop(d, false), child: Text(l.cancel)), ElevatedButton.icon(onPressed: () async { final amount = double.tryParse(ac.text) ?? 0; if (amount <= 0) return; await DatabaseHelper.instance.insertFinanceRecord(FinanceRecord(type: type, amount: amount, reason: rc.text, recordDate: DateFormat('dd-MM-yyyy').format(DateTime.now()), createdTime: DateFormat('hh:mm a').format(DateTime.now()))); if (!d.mounted) return; Navigator.pop(d, true); }, icon: icon3D(Icons.save, size: 20), label: Text(l.save))],
      ),
    ));
    ac.dispose(); rc.dispose();
    if (r == true) { await loadFinance(); if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.financeRecordSaved))); }
  }

  Widget icon3D(IconData icon, {double size = 26, Color? color}) => Icon(icon, size: size);
  Widget financeCard({required Widget child, EdgeInsetsGeometry margin = const EdgeInsets.symmetric(vertical: 5), EdgeInsetsGeometry padding = const EdgeInsets.all(12)}) { final s = Theme.of(context).colorScheme; return Card(margin: margin, elevation: 2, color: s.surfaceContainerHighest, shadowColor: s.primary.withValues(alpha: .10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: s.primary.withValues(alpha: .14))), child: Padding(padding: padding, child: child)); }
  Widget _financeMiniCard(String title, double value, IconData icon) { final s = Theme.of(context).colorScheme; return financeCard(margin: EdgeInsets.zero, padding: const EdgeInsets.all(12), child: Column(mainAxisSize: MainAxisSize.min, children: [icon3D(icon, size: 28), const SizedBox(height: 6), Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: s.onSurface)), const SizedBox(height: 4), Text('Rs ${value.toStringAsFixed(0)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: s.primary))])); }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final l = _l;
    return Scaffold(backgroundColor: s.surface, appBar: AppBar(title: Text(l.finance), backgroundColor: s.surface, elevation: 0), body: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
      financeCard(margin: EdgeInsets.zero, padding: const EdgeInsets.all(14), child: Column(children: [icon3D(Icons.account_balance_wallet, size: 34), const SizedBox(height: 6), Text(l.currentBalance, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: s.onSurfaceVariant)), const SizedBox(height: 4), Text('Rs ${currentBalance.toStringAsFixed(0)}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: currentBalance < 0 ? s.error : s.primary))])),
      const SizedBox(height: 10),
      Row(children: [Expanded(child: _financeMiniCard(l.salary, salaryReceived, Icons.payments)), const SizedBox(width: 10), Expanded(child: _financeMiniCard(l.advance, advanceReceived, Icons.account_balance))]),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: addFinanceRecord, icon: icon3D(Icons.add, size: 20), label: Text(l.addFinanceRecord))),
      const SizedBox(height: 12),
      Expanded(child: FutureBuilder(future: DatabaseHelper.instance.getAllFinanceRecords(), builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final records = snapshot.data!;
        if (records.isEmpty) return Center(child: Text(l.noFinanceRecords, style: TextStyle(color: s.onSurfaceVariant)));
        return ListView.builder(itemCount: records.length, itemBuilder: (context, index) {
          final record = records[index];
          return financeCard(child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), leading: icon3D(Icons.receipt, size: 25), title: Text(_localisedFinanceType(record.type), style: TextStyle(fontWeight: FontWeight.w700, color: s.onSurface)), subtitle: Text('${record.reason}\n${record.recordDate}', style: TextStyle(color: s.onSurfaceVariant)), trailing: SizedBox(width: 132, child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [Flexible(child: Text('Rs ${record.amount.toStringAsFixed(0)}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: s.tertiary), overflow: TextOverflow.ellipsis)), IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 36, minHeight: 36), tooltip: l.edit, icon: icon3D(Icons.edit, size: 21), onPressed: () => editFinanceRecord(record)), IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 36, minHeight: 36), tooltip: l.delete, icon: icon3D(Icons.delete_forever, size: 22), onPressed: () => confirmDelete(record))]))));
        });
      }))
    ])));
  }
}
