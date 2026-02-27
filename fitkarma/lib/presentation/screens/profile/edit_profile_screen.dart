import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/sync/sync_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  String? _selectedGender;
  DateTime? _selectedDob;
  bool _isSaving = false;

  static const _genders = ['male', 'female', 'other'];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _weightController = TextEditingController(
      text: user?.weightKg != null ? user!.weightKg!.toStringAsFixed(1) : '',
    );
    _heightController = TextEditingController(
      text: user?.heightCm != null ? user!.heightCm!.toStringAsFixed(0) : '',
    );
    _selectedGender = user?.gender;
    _selectedDob = user?.dob;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(1995),
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _selectedDob = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final currentUser = ref.read(authStateProvider).user;
    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      weightKg: double.tryParse(_weightController.text.trim()),
      heightCm: double.tryParse(_heightController.text.trim()),
      gender: _selectedGender,
      dob: _selectedDob,
      updatedAt: DateTime.now(),
    );

    // Save locally and update auth state
    ref.read(authStateProvider.notifier).updateUser(updatedUser);

    // Sync to PocketBase
    ref.read(syncServiceProvider).enqueueAction(
      collection: 'users',
      operation: 'update',
      recordId: currentUser.id,
      data: {
        'Name': updatedUser.name,
        'Phone': updatedUser.phone ?? '',
        'Weight_kg': updatedUser.weightKg,
        'Height': updatedUser.heightCm,
        'Gender': updatedUser.gender != null
            ? _capitalise(updatedUser.gender!)
            : null,
        'DOB': updatedUser.dob?.toIso8601String().split('T').first,
      },
    );

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated!'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  String _capitalise(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.primaryColor),
                  ),
                )
              : TextButton(
                  onPressed: _save,
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader('Personal Info'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                  prefixText: '+91 ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              // DOB picker
              InkWell(
                onTap: _pickDob,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    prefixIcon: Icon(Icons.cake_outlined),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedDob != null
                        ? DateFormat('d MMM yyyy').format(_selectedDob!)
                        : 'Select date',
                    style: TextStyle(
                      color: _selectedDob != null
                          ? null
                          : Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Gender dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.wc_outlined),
                  border: OutlineInputBorder(),
                ),
                items: _genders
                    .map((g) => DropdownMenuItem(
                          value: g,
                          child: Text(_capitalise(g)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedGender = v),
              ),
              const SizedBox(height: 24),
              _sectionHeader('Body Metrics'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Weight',
                        suffixText: 'kg',
                        prefixIcon: Icon(Icons.monitor_weight_outlined),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final d = double.tryParse(v.trim());
                        if (d == null || d <= 0 || d > 300) {
                          return 'Enter valid weight';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      decoration: const InputDecoration(
                        labelText: 'Height',
                        suffixText: 'cm',
                        prefixIcon: Icon(Icons.height_outlined),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final d = double.tryParse(v.trim());
                        if (d == null || d <= 0 || d > 300) {
                          return 'Enter valid height';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
    );
  }
}
