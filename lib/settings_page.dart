import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'theme_manager.dart';
import 'app_theme_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  File? profileImage;
  final ImagePicker picker = ImagePicker();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final companyController = TextEditingController();

  String machineType = 'Single Needle';
  String jobType = 'Full Piece';
  String currency = 'PKR';
  String selectedTheme = 'goldLegend';

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
      selectedTheme = profile['selected_theme'] ?? 'goldLegend';
      if ((profile['profile_image'] ?? '').toString().isNotEmpty) {
        profileImage = File(profile['profile_image']);
      }
    });
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        profileImage = File(picked.path);
      });
    }
  }

  Future<void> saveProfile() async {
    print('SAVE BUTTON PRESSED');
    await DatabaseHelper.instance.saveProfile({
      'operator_name': nameController.text.trim(),
      'mobile_number': mobileController.text.trim(),
      'company_name': companyController.text.trim(),
      'default_machine_type': machineType,
      'default_job_type': jobType,
      'currency': currency,
      'profile_image': profileImage?.path ?? '',
      'selected_theme': selectedTheme,
    });
    switch (selectedTheme) {
      case 'shadowDark':
        AppThemeController.currentTheme.value = AppTheme.shadowDark;
        break;

      case 'goldLegend':
        AppThemeController.currentTheme.value = AppTheme.goldLegend;
        break;

      case 'platinumPro':
        AppThemeController.currentTheme.value = AppTheme.platinumPro;
        break;

      case 'cyberBlue':
        AppThemeController.currentTheme.value = AppTheme.cyberBlue;
        break;

      case 'neonGreen':
        AppThemeController.currentTheme.value = AppTheme.neonGreen;
        break;

      case 'rubyRed':
        AppThemeController.currentTheme.value = AppTheme.rubyRed;
        break;
    }
    print('PROFILE SAVED');
    final check = await DatabaseHelper.instance.getProfile();
    print(check);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile Saved Successfully')));
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    companyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: profileImage != null
                    ? FileImage(profileImage!)
                    : null,
                child: profileImage == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            ),

            const SizedBox(height: 15),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Operator Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: mobileController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Mobile Number (Optional)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: companyController,
              decoration: const InputDecoration(
                labelText: 'Company Name (Optional)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: machineType,
              decoration: const InputDecoration(
                labelText: 'Default Machine Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Single Needle',
                  child: Text('Single Needle'),
                ),
                DropdownMenuItem(value: 'Over Lock', child: Text('Over Lock')),
                DropdownMenuItem(value: 'Flat Lock', child: Text('Flat Lock')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) {
                setState(() {
                  machineType = value!;
                });
              },
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: jobType,
              decoration: const InputDecoration(
                labelText: 'Default Job Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Full Piece',
                  child: Text('Full Piece'),
                ),
                DropdownMenuItem(
                  value: 'Half Piece',
                  child: Text('Half Piece'),
                ),
                DropdownMenuItem(value: 'Contract', child: Text('Contract')),
              ],
              onChanged: (value) {
                setState(() {
                  jobType = value!;
                });
              },
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: currency,
              decoration: const InputDecoration(
                labelText: 'Currency',
                border: OutlineInputBorder(),
              ),
              items: const [DropdownMenuItem(value: 'PKR', child: Text('PKR'))],
              onChanged: (value) {
                setState(() {
                  currency = value!;
                });
              },
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: selectedTheme,
              decoration: const InputDecoration(
                labelText: 'Theme',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'shadowDark',
                  child: Text('Shadow Dark'),
                ),
                DropdownMenuItem(
                  value: 'goldLegend',
                  child: Text('Gold Legend'),
                ),
                DropdownMenuItem(
                  value: 'platinumPro',
                  child: Text('Platinum Pro'),
                ),
                DropdownMenuItem(value: 'cyberBlue', child: Text('Cyber Blue')),
                DropdownMenuItem(value: 'neonGreen', child: Text('Neon Green')),
                DropdownMenuItem(value: 'rubyRed', child: Text('Ruby Red')),
              ],
              onChanged: (value) async {
                if (value == null) return;

                setState(() {
                  selectedTheme = value;
                });

                AppThemeController.currentTheme.value = AppTheme.values
                    .firstWhere(
                      (e) => e.name == value,
                      orElse: () => AppTheme.shadowDark,
                    );

                await DatabaseHelper.instance.saveTheme(value);
              },
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: saveProfile,
                child: const Text('Save Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
