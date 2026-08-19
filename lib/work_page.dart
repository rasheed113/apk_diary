import 'package:flutter/material.dart' hide Icon;
import 'package:intl/intl.dart';
import 'modern_icons.dart';
import 'database_helper.dart';
import 'diary_entry.dart';
import 'i18n/app_localization.dart';

class WorkPage extends StatefulWidget {
  final DiaryEntry? entry;
  final bool embedded;
  const WorkPage({super.key, this.entry, this.embedded = false});
  @override State<WorkPage> createState() => _WorkPageState();
}

class _WorkPageState extends State<WorkPage> {
  late String selectedItem;
  late String selectedRateType;
  final customItemController = TextEditingController();
  final piecesController = TextEditingController();
  final rateController = TextEditingController();
  final notesController = TextEditingController();
  List<String> selectedSizes = [];
  DateTime selectedDate = DateTime.now();

  final itemList = ['Shirt', 'Pant', 'Kameez', 'Other'];
  final rateTypes = ['Per Piece', 'Per Dozen'];
  bool _saving = false;
  bool get isEditMode => widget.entry != null;
  AppLocalization get l10n => AppLocalization.english();

  double get total {
    final pieces = double.tryParse(piecesController.text) ?? 0;
    final rate = double.tryParse(rateController.text) ?? 0;
    return selectedRateType == 'Per Dozen' ? (pieces / 12) * rate : pieces * rate;
  }

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    selectedItem = e?.itemName ?? 'Shirt';
    selectedRateType = e?.rateType ?? 'Per Piece';
    if (e != null) {
      selectedSizes = e.sizes.split(',').map((x) => x.trim()).where((x) => x.isNotEmpty).toList();
      piecesController.text = '${e.pieces}';
      rateController.text = '${e.rate}';
      notesController.text = e.notes;
      final p = e.workDate.split('-');
      if (p.length == 3) selectedDate = DateTime.tryParse('${p[2]}-${p[1]}-${p[0]}') ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    customItemController.dispose();
    piecesController.dispose();
    rateController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void calculateTotal() { if (mounted) setState(() {}); }

  void _resetNewEntryForm() {
    customItemController.clear();
    piecesController.clear();
    rateController.clear();
    notesController.clear();
    selectedSizes = [];
    selectedItem = 'Shirt';
    selectedRateType = 'Per Piece';
    selectedDate = DateTime.now();
    _saving = false;
  }

  Future<void> selectSizes() async {
    final temp = List<String>.from(selectedSizes);
    final custom = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.selectSizes),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            ...['XS', 'S', 'M', 'L', 'XL', 'XXL'].map((size) => CheckboxListTile(value: temp.contains(size), title: Text(size), onChanged: (value) => setDialogState(() { if (value == true && !temp.contains(size)) temp.add(size); if (value != true) temp.remove(size); }))),
            TextField(controller: custom, decoration: const InputDecoration(labelText: 'Custom sizes', hintText: '14,16,18,20', border: OutlineInputBorder())),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.cancel)),
            ElevatedButton(onPressed: () { if (mounted) setState(() { selectedSizes = List<String>.from(temp); if (custom.text.trim().isNotEmpty) selectedSizes.add(custom.text.trim()); }); Navigator.pop(dialogContext); }, child: Text(l10n.done)),
          ],
        ),
      ),
    );
    custom.dispose();
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (picked != null && mounted) setState(() => selectedDate = picked);
  }

  Future<void> saveOrUpdateEntry() async {
    if (_saving || !mounted) return;
    final pieces = int.tryParse(piecesController.text);
    final rate = double.tryParse(rateController.text);
    if (pieces == null || pieces <= 0) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.piecesMustBeGreaterThanZero))); return; }
    if (rate == null || rate <= 0) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.rateMustBeGreaterThanZero))); return; }
    final item = selectedItem == 'Other' ? customItemController.text.trim() : selectedItem;
    if (item.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pleaseEnterAnItem))); return; }

    setState(() => _saving = true);
    final entry = DiaryEntry(id: widget.entry?.id, itemName: item, sizes: selectedSizes.join(', '), pieces: pieces, rate: rate, rateType: selectedRateType, total: total, machineType: widget.entry?.machineType ?? '', jobType: widget.entry?.jobType ?? '', notes: notesController.text, workDate: DateFormat('dd-MM-yyyy').format(selectedDate), createdTime: widget.entry?.createdTime ?? DateFormat('hh:mm a').format(DateTime.now()));

    try {
      if (isEditMode) { await DatabaseHelper.instance.updateEntry(entry); } else { await DatabaseHelper.instance.insertEntry(entry); }
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.entrySaveFailed}: $error')));
      return;
    }

    if (!mounted) return;

    if (widget.embedded) {
      if (!isEditMode) {
        setState(_resetNewEntryForm);
      } else {
        setState(() => _saving = false);
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditMode ? l10n.updateEntry : l10n.saveEntry)));
      return;
    }

    Navigator.of(context).pop<bool>(true);
  }

  InputDecoration fieldDecoration(String label, IconData icon) => InputDecoration(labelText: label, prefixIcon: Icon(icon), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), isDense: true);
  Widget field(Widget child) { final scheme = Theme.of(context).colorScheme; return Container(margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(14), border: Border.all(color: scheme.primary.withValues(alpha: .12)), boxShadow: [BoxShadow(color: scheme.shadow.withValues(alpha: .10), blurRadius: 8, offset: const Offset(0, 3))]), padding: const EdgeInsets.all(8), child: child); }
  Widget sectionHeader(String text, IconData icon) { final scheme = Theme.of(context).colorScheme; return Row(children: [Icon(icon, color: scheme.primary), const SizedBox(width: 8), Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: scheme.onSurface))]); }
  Widget itemOptionIcon(String item) { final emoji = switch (item) { 'Shirt' => '👕', 'Pant' => '👖', 'Kameez' => '👕', _ => '📦' }; return Text(emoji, style: const TextStyle(fontSize: 22)); }
  String localizedItemName(String item) { switch (item) { case 'Shirt': return l10n.itemShirt; case 'Pant': return l10n.itemPant; case 'Kameez': return l10n.itemKameez; default: return l10n.other; } }
  String localizedRateType(String rateType) => rateType == 'Per Dozen' ? l10n.perDozen : l10n.perPiece;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(title: Text(isEditMode ? l10n.editEntry : l10n.newEntry), backgroundColor: scheme.surface, elevation: 0),
      body: SingleChildScrollView(padding: const EdgeInsets.all(12), child: Column(children: [
        sectionHeader(l10n.workDetails, Icons.work), const SizedBox(height: 10),
        field(DropdownButtonFormField<String>(initialValue: selectedItem, decoration: fieldDecoration(l10n.itemName, Icons.checkroom), items: itemList.map((e) => DropdownMenuItem(value: e, child: Row(children: [itemOptionIcon(e), const SizedBox(width: 10), Text(localizedItemName(e))]))).toList(), onChanged: (value) { if (value != null) setState(() => selectedItem = value); })),
        if (selectedItem == 'Other') field(TextField(controller: customItemController, decoration: fieldDecoration(l10n.customItem, Icons.inventory_2))),
        field(Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: selectSizes, icon: const Icon(Icons.grid_view), label: Text(selectedSizes.isEmpty ? l10n.selectSizes : selectedSizes.join(', ')))),
        field(TextField(controller: piecesController, keyboardType: TextInputType.number, decoration: fieldDecoration(l10n.pieces, Icons.numbers), onChanged: (_) => calculateTotal())),
        field(TextField(controller: rateController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: fieldDecoration(l10n.rate, Icons.payments), onChanged: (_) => calculateTotal())),
        field(DropdownButtonFormField<String>(initialValue: selectedRateType, decoration: fieldDecoration(l10n.rateType, Icons.category), items: rateTypes.map((e) => DropdownMenuItem(value: e, child: Text(localizedRateType(e)))).toList(), onChanged: (value) { if (value != null) setState(() => selectedRateType = value); })),
        field(TextButton.icon(onPressed: pickDate, icon: const Icon(Icons.calendar_month), label: Text(DateFormat('dd-MM-yyyy').format(selectedDate)))),
        field(TextField(controller: notesController, maxLines: 3, decoration: fieldDecoration(l10n.notes, Icons.notes))),
        Container(width: double.infinity, padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16), border: Border.all(color: scheme.primary.withValues(alpha: .14)), boxShadow: [BoxShadow(color: scheme.shadow.withValues(alpha: .10), blurRadius: 10, offset: const Offset(0, 4))]), child: Column(children: [Text(l10n.total, style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text('Rs ${total.toStringAsFixed(0)}', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: scheme.onSurface))])),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _saving ? null : saveOrUpdateEntry, icon: const Icon(Icons.save_rounded), label: Text(_saving ? 'Saving...' : (isEditMode ? l10n.updateEntry : l10n.saveEntry)))),
      ])),
    );
  }
}
