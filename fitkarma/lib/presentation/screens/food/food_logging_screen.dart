import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:barcode_scan2/barcode_scan2.dart';

import '../../../core/theme/app_theme.dart';
import 'food_search_delegate.dart';
import '../../../data/providers/food_provider.dart';
import '../../widgets/voice_assistant_sheet.dart';
import '../../../core/utils/voice_service.dart';
import 'food_scanner_screen.dart';

class FoodLoggingScreen extends ConsumerStatefulWidget {
  const FoodLoggingScreen({super.key});

  @override
  ConsumerState<FoodLoggingScreen> createState() => _FoodLoggingScreenState();
}

class _FoodLoggingScreenState extends ConsumerState<FoodLoggingScreen> {
  String _selectedMealType = 'breakfast';

  final List<Map<String, dynamic>> _mealTypes = [
    {'type': 'breakfast', 'label': 'Breakfast', 'icon': Icons.free_breakfast},
    {'type': 'lunch', 'label': 'Lunch', 'icon': Icons.lunch_dining},
    {'type': 'dinner', 'label': 'Dinner', 'icon': Icons.dinner_dining},
    {'type': 'snack', 'label': 'Snack', 'icon': Icons.cookie},
    {'type': 'chai', 'label': 'Chai', 'icon': Icons.coffee},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Food'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: AppTheme.saffronColor),
            onPressed: () => context.push('/food/meal-planner'),
            tooltip: 'AI Meal Planner',
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanBarcode,
          ),
          IconButton(
            icon: const Icon(Icons.mic, color: AppTheme.primaryColor),
            onPressed: () => _showVoiceAssistant(context),
            tooltip: 'Voice Logging',
          ),
          IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined,
                color: AppTheme.accentColor),
            onPressed: () => _scanVisual(context),
            tooltip: 'Visual Food Scan',
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _scanOCR,
          ),
        ],
      ),
      body: Column(
        children: [
          // Meal Type Selector
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _mealTypes.length,
              itemBuilder: (context, index) {
                final meal = _mealTypes[index];
                final isSelected = _selectedMealType == meal['type'];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedMealType = meal['type'];
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            meal['icon'],
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            meal['label'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search food items...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onTap: () {
                showSearch(
                  context: context,
                  delegate:
                      FoodSearchDelegate(ref: ref, mealType: _selectedMealType),
                );
              },
            ),
          ),
          // Quick Add Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Quick Add',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showVoiceAssistant(context),
                  icon: const Icon(Icons.mic, size: 18),
                  label: const Text('Voice'),
                ),
              ],
            ),
          ),
          // Quick Add Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildQuickAddItem('Idli (2 pieces)', 150, 4, 20, 6),
                _buildQuickAddItem('Dosa (1 piece)', 250, 8, 35, 10),
                _buildQuickAddItem('Paratha (1 piece)', 300, 10, 40, 15),
                _buildQuickAddItem('Rice (1 cup)', 200, 4, 45, 1),
                _buildQuickAddItem('Dal (1 cup)', 150, 12, 20, 5),
                _buildQuickAddItem('Chicken Curry (1 cup)', 250, 25, 10, 15),
                _buildQuickAddItem('Poha (1 cup)', 180, 5, 25, 7),
                _buildQuickAddItem('Upma (1 cup)', 200, 6, 28, 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddItem(
      String name, int calories, double protein, double carbs, double fat) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(name),
        subtitle:
            Text('$calories cal | P: ${protein}g | C: ${carbs}g | F: ${fat}g'),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle_outline),
          color: AppTheme.primaryColor,
          onPressed: () async {
            await ref.read(foodLogProvider.notifier).logFood(
                  name: name,
                  calories: calories.toDouble(),
                  protein: protein,
                  carbs: carbs,
                  fat: fat,
                  mealType: _selectedMealType,
                  loggedVia: 'quick_add',
                );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Logged $name! +5 Karma'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _showVoiceAssistant(BuildContext context) async {
    final intent = await showModalBottomSheet<VoiceIntent>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const VoiceAssistantSheet(),
    );

    if (intent != null && context.mounted) {
      if (intent.action == 'log_food') {
        // In a real app, you'd trigger searching or logging
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logging: ${intent.data['query']}')),
        );
      }
    }
  }

  Future<void> _scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      if (result.type == ResultType.Barcode && result.rawContent.isNotEmpty) {
        // Search by barcode using provider
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scanning barcode: ${result.rawContent}')),
        );
        ref.read(foodSearchProvider.notifier).searchBarcode(result.rawContent);
        // Show search delegate which listens to this automatically
        showSearch(
          context: context,
          delegate: FoodSearchDelegate(ref: ref, mealType: _selectedMealType)
            ..query = result.rawContent,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to scan barcode.')),
      );
    }
  }

  void _scanOCR() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OCR Camera is mocked for MVP!')),
    );
  }

  Future<void> _scanVisual(BuildContext context) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const FoodScannerScreen()),
    );

    if (result != null && mounted) {
      // Trigger search with recognized label
      showSearch(
        context: context,
        delegate: FoodSearchDelegate(ref: ref, mealType: _selectedMealType),
        query: result,
      );
    }
  }
}
