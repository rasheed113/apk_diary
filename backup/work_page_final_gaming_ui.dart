import 'dart:ui';
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
      backgroundColor: const Color(0xff080812),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isEditMode ? "✏️ Edit Work" : "🎮 New Work Entry",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            _glowCard(
              child: Row(
                children: const [
                  Icon(Icons.work, size: 35),
                  SizedBox(width: 12),
                  Text(
                    "Work Details",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            _fieldCard(
              DropdownButtonFormField<String>(
                initialValue: selectedItem,
                decoration: _input("Item Name", Icons.checkroom),
                items: itemList.map(
                  (e)=>DropdownMenuItem(
                    value:e,
                    child:Text(e),
                  ),
                ).toList(),
                onChanged:(v){
                  setState(()=>selectedItem=v!);
                },
              ),
            ),

            if(selectedItem=="Other")
              _fieldCard(
                TextField(
                  controller: customItemController,
                  decoration:_input("Custom Item", Icons.inventory),
                ),
              ),

            _fieldCard(
              TextButton.icon(
                onPressed:selectSizes,
                icon:const Icon(Icons.grid_view),
                label:Text(
                  selectedSizes.isEmpty
                  ? "Select Sizes"
                  : selectedSizes.join(", "),
                ),
              ),
            ),

            _fieldCard(
              TextField(
                controller: piecesController,
                keyboardType:TextInputType.number,
                decoration:_input("Pieces", Icons.numbers),
                onChanged:(_)=>calculateTotal(),
              ),
            ),

            _fieldCard(
              TextField(
                controller:rateController,
                keyboardType:const TextInputType.numberWithOptions(decimal:true),
                decoration:_input("Rate", Icons.payments),
                onChanged:(_)=>calculateTotal(),
              ),
            ),

            _fieldCard(
              DropdownButtonFormField<String>(
                initialValue:selectedRateType,
                decoration:_input("Rate Type", Icons.category),
                items:rateTypes.map(
                  (e)=>DropdownMenuItem(
                    value:e,
                    child:Text(e),
                  ),
                ).toList(),
                onChanged:(v){
                  setState(()=>selectedRateType=v!);
                  calculateTotal();
                },
              ),
            ),

            _glowCard(
              child:Column(
                children:[
                  const Icon(
                    Icons.workspace_premium,
                    size:42,
                  ),
                  const SizedBox(height:8),
                  const Text(
                    "🏆 TOTAL REWARD",
                    style:TextStyle(
                      fontSize:18,
                      fontWeight:FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height:10),
                  Text(
                    "Rs ${total.toStringAsFixed(2)}",
                    style:const TextStyle(
                      fontSize:36,
                      fontWeight:FontWeight.w900,
                      shadows:[
                        Shadow(
                          blurRadius:15,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height:6),
                  const Text(
                    "Your work earning preview",
                    style:TextStyle(
                      fontSize:14,
                    ),
                  ),
                ],
              ),
            ),

            _fieldCard(
              TextField(
                controller:notesController,
                maxLines:3,
                decoration:_input("Notes", Icons.note_alt),
              ),
            ),

            _glowCard(
              child:ListTile(
                contentPadding: const EdgeInsets.all(8),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors:[
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.calendar_month,
                    color: Colors.black,
                  ),
                ),
                title: const Text(
                  "WORK DATE",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                subtitle: Text(
                  DateFormat('dd MMM yyyy').format(selectedDate),
                  style: const TextStyle(
                    fontSize:16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size:18,
                ),
                onTap:pickDate,
              ),
            ),

            const SizedBox(height:20),

            Container(
              width: double.infinity,
              height: 65,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.6),
                    blurRadius: 25,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                icon: const Icon(
                  Icons.save,
                  size: 30,
                ),
                onPressed: saveOrUpdateEntry,
                label: Text(
                  isEditMode
                      ? "UPDATE ENTRY"
                      : "SAVE ENTRY",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _input(String text, IconData icon){
    return InputDecoration(
      labelText:text,
      prefixIcon: Icon(icon),
      border:const OutlineInputBorder(),
    );
  }


  Widget _fieldCard(Widget child){
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha:0.35),
            blurRadius: 25,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12,
            sigmaY: 12,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .cardColor
                  .withValues(alpha:0.75),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: primary.withValues(alpha:0.8),
                width: 2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }


  Widget _glowCard({required Widget child}){
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds:500),
      tween: Tween(begin:0.85,end:1),
      curve: Curves.easeOutBack,
      builder:(context,scale,child){
        return Transform.scale(
          scale:scale,
          child:child,
        );
      },
      child: _fieldCard(
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:[
                primary.withValues(alpha:0.15),
                secondary.withValues(alpha:0.15),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }

}