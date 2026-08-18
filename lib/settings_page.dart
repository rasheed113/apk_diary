import 'dart:io';

import 'package:flutter/material.dart' hide Icon;
import 'package:image_picker/image_picker.dart';

import 'modern_icons.dart';
import 'app_theme_controller.dart';
import 'database_helper.dart';
import 'theme_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  File? profileImage;
  File? coverImage;
  final ImagePicker picker = ImagePicker();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final companyController = TextEditingController();

  String machineType = 'Single Needle';
  String jobType = 'Full Piece';
  String currency = 'PKR';
  String selectedTheme = 'classicLight';

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final profile = await DatabaseHelper.instance.getProfile();
    if (profile == null) return;

    setState(() {
      nameController.text = profile['operator_name'] ?? '';
      mobileController.text = profile['mobile_number'] ?? '';
      companyController.text = profile['company_name'] ?? '';
      machineType = profile['default_machine_type'] ?? 'Single Needle';
      jobType = profile['default_job_type'] ?? 'Full Piece';
      currency = profile['currency'] ?? 'PKR';
      selectedTheme = profile['selected_theme'] ?? 'classicLight';

      final profilePath = profile['profile_image']?.toString() ?? '';
      if (profilePath.isNotEmpty) profileImage = File(profilePath);

      final coverPath = profile['cover_image']?.toString() ?? '';
      if (coverPath.isNotEmpty) coverImage = File(coverPath);
    });
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => profileImage = File(picked.path));
    }
  }

  Future<void> pickCoverImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => coverImage = File(picked.path));
    }
  }

  Future<void> saveProfile() async {
    await DatabaseHelper.instance.saveProfile({
      'operator_name': nameController.text.trim(),
      'mobile_number': mobileController.text.trim(),
      'company_name': companyController.text.trim(),
      'default_machine_type': machineType,
      'default_job_type': jobType,
      'currency': currency,
      'profile_image': profileImage?.path ?? '',
      'cover_image': coverImage?.path ?? '',
      'selected_theme': selectedTheme,
    });

    final theme = AppTheme.values.firstWhere(
      (e) => e.name == selectedTheme,
      orElse: () => AppTheme.classicLight,
    );
    AppThemeController.currentTheme.value = theme;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile Saved Successfully')),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    companyController.dispose();
    super.dispose();
  }

  Widget sectionCard(BuildContext context, {required Widget child}) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: colors.surfaceContainerHighest,
      shadowColor: colors.primary.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.primary.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: child,
      ),
    );
  }

  InputDecoration themedInput(BuildContext context, String label) {
    final colors = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: colors.onSurfaceVariant),
      filled: true,
      fillColor: colors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.primary.withValues(alpha: 0.14)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.primary.withValues(alpha: 0.14)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: colors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            sectionCard(
              context,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: colors.primary.withValues(alpha: 0.10),
                      backgroundImage: profileImage != null ? FileImage(profileImage!) : null,
                      child: profileImage == null ? Icon(Icons.person, size: 50) : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Profile & Cover', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: colors.onSurface)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: pickCoverImage,
                    child: Container(
                      height: 90,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: colors.primary.withValues(alpha: 0.06),
                        image: coverImage != null ? DecorationImage(image: FileImage(coverImage!), fit: BoxFit.cover) : null,
                        border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
                      ),
                      child: coverImage == null
                          ? Center(child: Text('Add Cover Image', style: TextStyle(color: colors.primary, fontWeight: FontWeight.w700)))
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            sectionCard(
              context,
              child: Column(
                children: [
                  TextField(controller: nameController, decoration: themedInput(context, 'Operator Name')),
                  const SizedBox(height: 12),
                  TextField(controller: mobileController, keyboardType: TextInputType.phone, decoration: themedInput(context, 'Mobile Number (Optional)')),
                  const SizedBox(height: 12),
                  TextField(controller: companyController, decoration: themedInput(context, 'Company Name (Optional)')),
                ],
              ),
            ),
            sectionCard(
              context,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: machineType,
                    decoration: themedInput(context, 'Default Machine Type'),
                    items: const [
                      DropdownMenuItem(value: 'Single Needle', child: Text('Single Needle')),
                      DropdownMenuItem(value: 'Over Lock', child: Text('Over Lock')),
                      DropdownMenuItem(value: 'Flat Lock', child: Text('Flat Lock')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (value) { if (value != null) setState(() => machineType = value); },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: jobType,
                    decoration: themedInput(context, 'Default Job Type'),
                    items: const [
                      DropdownMenuItem(value: 'Full Piece', child: Text('Full Piece')),
                      DropdownMenuItem(value: 'Half Piece', child: Text('Half Piece')),
                      DropdownMenuItem(value: 'Contract', child: Text('Contract')),
                    ],
                    onChanged: (value) { if (value != null) setState(() => jobType = value); },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: currency,
                    decoration: themedInput(context, 'Currency'),
                    items: const [DropdownMenuItem(value: 'PKR', child: Text('PKR'))],
                    onChanged: (value) { if (value != null) setState(() => currency = value); },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedTheme,
                    decoration: themedInput(context, 'Theme'),
                    items: const [
                      DropdownMenuItem(value: 'classicLight', child: Text('Classic Light')),
                      DropdownMenuItem(value: 'shadowDark', child: Text('Shadow Dark')),
                      DropdownMenuItem(value: 'goldLegend', child: Text('Gold Legend')),
                      DropdownMenuItem(value: 'platinumPro', child: Text('Platinum Pro')),
                      DropdownMenuItem(value: 'cyberBlue', child: Text('Cyber Blue')),
                      DropdownMenuItem(value: 'neonGreen', child: Text('Neon Green')),
                      DropdownMenuItem(value: 'rubyRed', child: Text('Ruby Red')),
                    ],
                    onChanged: (value) async {
                      if (value == null) return;
                      setState(() => selectedTheme = value);
                      final theme = AppTheme.values.firstWhere((e) => e.name == value, orElse: () => AppTheme.classicLight);
                      AppThemeController.currentTheme.value = theme;
                      await DatabaseHelper.instance.saveTheme(value);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: saveProfile, child: const Text('Save Settings'))),
          ],
        ),
      ),
    );
  }
}
