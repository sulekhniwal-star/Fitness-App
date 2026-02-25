import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

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
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanBarcode,
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
                // TODO: Navigate to search
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
                  onPressed: () {},
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

  Widget _buildQuickAddItem(String name, int calories, double protein, double carbs, double fat) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(name),
        subtitle: Text('$calories cal | P: ${protein}g | C: ${carbs}g | F: ${fat}g'),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle_outline),
          color: AppTheme.primaryColor,
          onPressed: () {
            // TODO: Add to log
          },
        ),
      ),
    );
  }

  void _scanBarcode() {
    // TODO: Implement barcode scanning
  }

  void _scanOCR() {
    // TODO: Implement OCR scanning
  }
}
