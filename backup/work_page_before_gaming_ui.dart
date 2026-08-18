import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'database_helper.dart';
import 'diary_entry.dart';

class WorkPage extends StatefulWidget {
  final DiaryEntry? entry;

  const WorkPage({super.key, this.entry});

  @override
  State<WorkPage> createState() => _WorkPageState();
}

class _WorkPageState extends State<WorkPage> {
  final TextEditingController piecesController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController customItemController = TextEditingController();
  final TextEditingController customSizeController = TextEditingController();

  String selectedItem = 'Shirt';
  String selectedRateType = 'Per Piece';

  List<String> selectedSizes = [];

  bool isEditMode = false;

  DateTime selectedDate = DateTime.now();

  double total = 0;

  final List<String> itemList = [
    'Shirt',
    'Short',
    'Trouser',
    'Back Top',
    'Hoodie',
    'Jacket',
    'Other',
  ];

  final List<String> rateTypes = ['Per Piece', 'Per Dozen', 'Per 100 Pieces'];

  final List<String> sizes = ['S', 'M', 'L', 'XL', 'XXL'];

  void calculateTotal() {
    final pieces = int.tryParse(piecesController.text) ?? 0;

    final rate = double.tryParse(rateController.text) ?? 0;

    double result = 0;

    if (selectedRateType == 'Per Piece') {
      result = pieces * rate;
    } else if (selectedRateType == 'Per Dozen') {
      result = (pieces / 12) * rate;
    } else if (selectedRateType == 'Per 100 Pieces') {
      result = (pieces / 100) * rate;
    }

    setState(() {
      total = result;
    });
  }

  Future<void> selectSizes() async {
    List<String> tempSelected = List.from(selectedSizes);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Sizes'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    ...sizes.map((size) {
                      return CheckboxListTile(
                        title: Text(size),
                        value: tempSelected.contains(size),
                        onChanged: (value) {
                          setDialogState(() {
                            if (value == true) {
                              tempSelected.add(size);
                            } else {
                              tempSelected.remove(size);
                            }
                          });
                        },
                      );
                    }),

                    const SizedBox(height: 10),

                    TextField(
                      controller: customSizeController,
                      decoration: const InputDecoration(
                        labelText: 'Custom Sizes',
                        hintText: '14,16,18,20',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedSizes = tempSelected;
                      if (customSizeController.text.trim().isNotEmpty) {
                        selectedSizes.add(customSizeController.text.trim());
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> saveOrUpdateEntry() async {
    if (piecesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter pieces')));
      return;
    }

    if (rateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter rate')));
      return;
    }

    if ((int.tryParse(piecesController.text) ?? 0) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pieces must be greater than 0')),
      );
      return;
    }

    if ((double.tryParse(rateController.text) ?? 0) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rate must be greater than 0')),
      );
      return;
    }
    String item = selectedItem;

    if (selectedItem == 'Other') {
      item = customItemController.text;
    }

    final entry = DiaryEntry(
      itemName: item,
      sizes: selectedSizes.join(', '),
      pieces: int.tryParse(piecesController.text) ?? 0,
      rate: double.tryParse(rateController.text) ?? 0,
      rateType: selectedRateType,
      total: total,
      machineType: '',
      jobType: '',
      notes: notesController.text,
      workDate: DateFormat('dd-MM-yyyy').format(selectedDate),
      createdTime: DateFormat('hh:mm a').format(DateTime.now()),
    );

    if (isEditMode) {
      await DatabaseHelper.instance.updateEntry(
        entry.copyWith(id: widget.entry!.id),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry Updated Successfully ✅')),
      );
    } else {
      await DatabaseHelper.instance.insertEntry(entry);
      piecesController.clear();
      rateController.clear();
      notesController.clear();
      customItemController.clear();
      customSizeController.clear();

      setState(() {
        selectedItem = 'Shirt';
        selectedRateType = 'Per Piece';
        selectedSizes = [];
        selectedDate = DateTime.now();
        total = 0;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry Saved Successfully ✅')),
      );
    }

    if (Navigator.canPop(context)) {
      Navigator.pop(context, true);
    }
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.entry != null) {
      isEditMode = true;

      final entry = widget.entry!;

      selectedItem = itemList.contains(entry.itemName)
          ? entry.itemName
          : 'Other';

      if (selectedItem == 'Other') {
        customItemController.text = entry.itemName;
      }

      // parse sizes stored as comma separated string
      selectedSizes = entry.sizes.trim().isEmpty
          ? []
          : entry.sizes.split(',').map((s) => s.trim()).toList();

      if (selectedSizes.contains('Other')) {
        customSizeController.text = entry.sizes;
      }
      piecesController.text = entry.pieces.toString();

      rateController.text = entry.rate.toString();

      selectedRateType = entry.rateType;

      notesController.text = entry.notes;

      total = entry.total;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Work Entry')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: const [
                    Icon(Icons.work),
                    SizedBox(width: 8),
                    Text(
                      'Work Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: selectedItem,

              decoration: const InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
              ),

              items: itemList.map((e) {
                return DropdownMenuItem(value: e, child: Text(e));
              }).toList(),

              onChanged: (v) {
                setState(() {
                  selectedItem = v!;
                });
              },
            ),

            const SizedBox(height: 12),

            if (selectedItem == 'Other')
              TextField(
                controller: customItemController,
                decoration: const InputDecoration(
                  labelText: 'Custom Item',
                  border: OutlineInputBorder(),
                ),
              ),

            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: selectSizes,
                icon: const Icon(Icons.grid_view),
                label: Text(
                  selectedSizes.isEmpty
                      ? 'Select Sizes'
                      : selectedSizes.join(', '),
                ),
              ),
            ),

            if (selectedSizes.contains('Other'))
              TextField(
                controller: customSizeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Custom Size',
                  hintText: '14, 16, 18...',
                  border: OutlineInputBorder(),
                ),
              ),

            const SizedBox(height: 12),

            TextField(
              controller: piecesController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                labelText: 'Pieces',

                border: OutlineInputBorder(),
              ),

              onChanged: (_) => calculateTotal(),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: rateController,

              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),

              decoration: const InputDecoration(
                labelText: 'Rate',

                border: OutlineInputBorder(),
              ),

              onChanged: (_) => calculateTotal(),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: selectedRateType,

              decoration: const InputDecoration(
                labelText: 'Rate Type',

                border: OutlineInputBorder(),
              ),

              items: rateTypes.map((e) {
                return DropdownMenuItem(value: e, child: Text(e));
              }).toList(),

              onChanged: (v) {
                setState(() {
                  selectedRateType = v!;
                });

                calculateTotal();
              },
            ),

            const SizedBox(height: 12),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Text(
                  'Total: Rs ${total.toStringAsFixed(2)}',

                  style: const TextStyle(
                    fontSize: 24,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: const [
                    Icon(Icons.note_alt),
                    SizedBox(width: 8),
                    Text(
                      'Notes & Date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: notesController,

              maxLines: 3,

              decoration: const InputDecoration(
                labelText: 'Notes',

                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_month),

                title: const Text('Work Date'),

                subtitle: Text(DateFormat('dd MMM yyyy').format(selectedDate)),

                trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                onTap: pickDate,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              height: 55,

              child: ElevatedButton(
                onPressed: saveOrUpdateEntry,

                child: Text(isEditMode ? '✏️ Update Entry' : '💾 Save Entry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
