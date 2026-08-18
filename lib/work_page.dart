import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'diary_entry.dart';

class WorkPage extends StatefulWidget {
  final DiaryEntry? entry;
  const WorkPage({super.key, this.entry});
  @override State<WorkPage> createState() => _WorkPageState();
}

class _WorkPageState extends State<WorkPage> {
  final piecesController = TextEditingController();
  final rateController = TextEditingController();
  final notesController = TextEditingController();
  final customItemController = TextEditingController();
  final customSizeController = TextEditingController();

  final itemList = const ['Shirt', 'Short', 'Trouser', 'Back Top', 'Hoodie', 'Jacket', 'Other'];
  final rateTypes = const ['Per Piece', 'Per Dozen', 'Per 100 Pieces'];
  final sizes = const ['S', 'M', 'L', 'XL', 'XXL'];
  String selectedItem = 'Shirt';
  String selectedRateType = 'Per Piece';
  List<String> selectedSizes = [];
  bool isEditMode = false;
  DateTime selectedDate = DateTime.now();
  double total = 0;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    if (entry != null) {
      isEditMode = true;
      selectedItem = itemList.contains(entry.itemName) ? entry.itemName : 'Other';
      if (selectedItem == 'Other') customItemController.text = entry.itemName;
      selectedSizes = entry.sizes.trim().isEmpty ? [] : entry.sizes.split(',').map((s) => s.trim()).toList();
      piecesController.text = entry.pieces.toString();
      rateController.text = entry.rate.toString();
      selectedRateType = rateTypes.contains(entry.rateType) ? entry.rateType : 'Per Piece';
      notesController.text = entry.notes;
      total = entry.total;
      try { selectedDate = DateFormat('dd-MM-yyyy').parse(entry.workDate); } catch (_) {}
    }
  }

  @override
  void dispose() {
    piecesController.dispose();
    rateController.dispose();
    notesController.dispose();
    customItemController.dispose();
    customSizeController.dispose();
    super.dispose();
  }

  void calculateTotal() {
    final pieces = int.tryParse(piecesController.text) ?? 0;
    final rate = double.tryParse(rateController.text) ?? 0;
    final value = selectedRateType == 'Per Dozen'
        ? (pieces / 12) * rate
        : selectedRateType == 'Per 100 Pieces'
            ? (pieces / 100) * rate
            : pieces * rate;
    setState(() => total = value);
  }

  Future<void> selectSizes() async {
    final temp = List<String>.from(selectedSizes);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select Sizes'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ...sizes.map((size) => CheckboxListTile(
                title: Text(size),
                value: temp.contains(size),
                onChanged: (value) => setDialogState(() {
                  if (value == true && !temp.contains(size)) temp.add(size);
                  if (value != true) temp.remove(size);
                }),
              )),
              TextField(controller: customSizeController, decoration: const InputDecoration(labelText: 'Custom Sizes', hintText: '14,16,18,20', border: OutlineInputBorder())),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            ElevatedButton(onPressed: () {
              setState(() {
                selectedSizes = List<String>.from(temp);
                final custom = customSizeController.text.trim();
                if (custom.isNotEmpty) selectedSizes.add(custom);
              });
              Navigator.pop(dialogContext);
            }, child: const Text('Done')),
          ],
        ),
      ),
    );
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> saveOrUpdateEntry() async {
    final pieces = int.tryParse(piecesController.text);
    final rate = double.tryParse(rateController.text);
    if (pieces == null || pieces <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pieces must be greater than 0')));
      return;
    }
    if (rate == null || rate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rate must be greater than 0')));
      return;
    }
    final item = selectedItem == 'Other' ? customItemController.text.trim() : selectedItem;
    if (item.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter an item')));
      return;
    }
    final entry = DiaryEntry(
      id: widget.entry?.id,
      itemName: item,
      sizes: selectedSizes.join(', '),
      pieces: pieces,
      rate: rate,
      rateType: selectedRateType,
      total: total,
      machineType: widget.entry?.machineType ?? '',
      jobType: widget.entry?.jobType ?? '',
      notes: notesController.text,
      workDate: DateFormat('dd-MM-yyyy').format(selectedDate),
      createdTime: widget.entry?.createdTime ?? DateFormat('hh:mm a').format(DateTime.now()),
    );
    if (isEditMode) {
      await DatabaseHelper.instance.updateEntry(entry);
    } else {
      await DatabaseHelper.instance.insertEntry(entry);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditMode ? 'Entry Updated Successfully ✅' : 'Entry Saved Successfully ✅')));
    Navigator.pop(context, true);
  }

  InputDecoration fieldDecoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    isDense: true,
  );

  Widget field(Widget child) {
    final scheme = Theme.of(context).colorScheme;
    final surface = Theme.of(context).cardColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [surface, scheme.primary.withValues(alpha: .035)],
        ),
        border: Border.all(color: scheme.primary.withValues(alpha: .16)),
        boxShadow: [BoxShadow(color: scheme.primary.withValues(alpha: .07), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Padding(padding: const EdgeInsets.all(10), child: child),
    );
  }

  Widget sectionHeader(String title, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary.withValues(alpha: .15), scheme.secondary.withValues(alpha: .08)],
        ),
        border: Border.all(color: scheme.primary.withValues(alpha: .18)),
      ),
      child: Row(children: [Icon(icon, color: scheme.primary), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final card = Theme.of(context).cardColor;
    return Scaffold(
      appBar: AppBar(title: Text(isEditMode ? 'Edit Work' : 'New Work Entry'), elevation: 0),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [scheme.surface, scheme.primary.withValues(alpha: .035)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            sectionHeader('Work Details', Icons.work),
            const SizedBox(height: 10),
            field(DropdownButtonFormField<String>(
              initialValue: selectedItem,
              decoration: fieldDecoration('Item Name', Icons.checkroom),
              items: itemList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) => setState(() => selectedItem = value ?? 'Shirt'),
            )),
            if (selectedItem == 'Other') field(TextField(controller: customItemController, decoration: fieldDecoration('Custom Item', Icons.inventory_2))),
            field(Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: selectSizes, icon: Icon(Icons.grid_view, color: scheme.primary), label: Text(selectedSizes.isEmpty ? 'Select Sizes' : selectedSizes.join(', ')))),
            field(TextField(controller: piecesController, keyboardType: TextInputType.number, decoration: fieldDecoration('Pieces', Icons.numbers), onChanged: (_) => calculateTotal())),
            field(TextField(controller: rateController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: fieldDecoration('Rate', Icons.payments), onChanged: (_) => calculateTotal())),
            field(DropdownButtonFormField<String>(
              initialValue: selectedRateType,
              decoration: fieldDecoration('Rate Type', Icons.category),
              items: rateTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) { setState(() => selectedRateType = value ?? 'Per Piece'); calculateTotal(); },
            )),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [scheme.primary.withValues(alpha: .16), scheme.secondary.withValues(alpha: .08)]),
                border: Border.all(color: scheme.primary.withValues(alpha: .22)),
                boxShadow: [BoxShadow(color: scheme.primary.withValues(alpha: .08), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: ListTile(leading: Icon(Icons.payments, color: scheme.primary), title: const Text('Total'), trailing: Text('Rs ${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: scheme.primary))),
            ),
            field(TextField(controller: notesController, maxLines: 3, decoration: fieldDecoration('Notes', Icons.note_alt))),
            field(ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.calendar_month, color: scheme.primary), title: const Text('Work Date'), subtitle: Text(DateFormat('dd MMM yyyy').format(selectedDate)), trailing: Icon(Icons.chevron_right, color: scheme.primary), onTap: pickDate)),
            const SizedBox(height: 2),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(onPressed: saveOrUpdateEntry, icon: Icon(isEditMode ? Icons.edit : Icons.save), label: Text(isEditMode ? 'Update Entry' : 'Save Entry'))),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }
}
