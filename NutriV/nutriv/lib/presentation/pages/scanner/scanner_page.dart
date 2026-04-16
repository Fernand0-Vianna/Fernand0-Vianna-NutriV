import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../bloc/food_scanner/food_scanner_bloc.dart';
import '../../bloc/food_scanner/food_scanner_event.dart';
import '../../bloc/food_scanner/food_scanner_state.dart';
import '../../bloc/meal/meal_bloc.dart';
import '../../bloc/meal/meal_event.dart';
import '../../../domain/entities/meal.dart';
import '../../../domain/entities/food_item.dart';
import 'barcode_scan_page.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final ImagePicker _picker = ImagePicker();
  String _selectedMealType = 'Café da manhã';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner de Alimentos')),
      body: BlocBuilder<FoodScannerBloc, FoodScannerState>(
        builder: (context, state) {
          if (state is FoodScannerLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analisando imagem...'),
                ],
              ),
            );
          }

          if (state is FoodScannerAnalyzed) {
            return _buildAnalyzedView(state);
          }

          if (state is FoodScannerError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<FoodScannerBloc>().add(ClearScannedFoods());
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          return _buildInitialView();
        },
      ),
    );
  }

  Widget _buildInitialView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'O que você quer adicionar?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 32),
          _buildOptionButton(
            icon: Icons.qr_code_scanner,
            label: 'Código de Barras',
            onTap: _openBarcodeScanner,
          ),
          const SizedBox(height: 12),
          _buildOptionButton(
            icon: Icons.camera_alt,
            label: 'Tirar Foto',
            onTap: () => _pickImage(ImageSource.camera),
          ),
          const SizedBox(height: 12),
          _buildOptionButton(
            icon: Icons.photo_library,
            label: 'Escolher da Galeria',
            onTap: () => _pickImage(ImageSource.gallery),
          ),
          const SizedBox(height: 12),
          _buildOptionButton(
            icon: Icons.edit,
            label: 'Buscar Alimento',
            onTap: _showSearchDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildAnalyzedView(FoodScannerAnalyzed state) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Alimentos identificados',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...state.scannedFoods.map((food) => _buildFoodItem(food)),
            ],
          ),
        ),
        _buildMealTypeSelector(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.selectedFoods.isNotEmpty
                  ? () => _addToMeal(state.selectedFoods)
                  : null,
              child: Text('Adicionar ${state.selectedFoods.length} alimentos'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFoodItem(FoodItem food) {
    final scannerState = context.read<FoodScannerBloc>().state;
    if (scannerState is! FoodScannerAnalyzed) {
      return const SizedBox.shrink();
    }
    final isSelected = scannerState.selectedFoods.any((f) => f.id == food.id);
    return Card(
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (selected) {
          if (selected == true) {
            context.read<FoodScannerBloc>().add(SelectFood(food));
          } else {
            context.read<FoodScannerBloc>().add(DeselectFood(food));
          }
        },
        title: Text(food.name),
        subtitle: Text(
          '${food.calories.toInt()} kcal | P: ${food.protein.toInt()}g | C: ${food.carbs.toInt()}g | G: ${food.fat.toInt()}g',
        ),
        secondary: Text('${food.portion.toInt()}g'),
      ),
    );
  }

  Widget _buildMealTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedMealType,
        decoration: const InputDecoration(labelText: 'Tipo de refeição'),
        items: const [
          DropdownMenuItem(
            value: 'Café da manhã',
            child: Text('Café da manhã'),
          ),
          DropdownMenuItem(value: 'Almoço', child: Text('Almoço')),
          DropdownMenuItem(value: 'Jantar', child: Text('Jantar')),
          DropdownMenuItem(value: 'Lanche', child: Text('Lanche')),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedMealType = value);
          }
        },
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null && mounted) {
      context.read<FoodScannerBloc>().add(AnalyzeImage(File(image.path)));
    }
  }

  void _showSearchDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Alimento'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Ex: Arroz com feijão'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (controller.text.isNotEmpty) {
                this.context.read<FoodScannerBloc>().add(
                  AnalyzeText(controller.text),
                );
              }
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  void _addToMeal(List<FoodItem> foods) {
    final mealFoods = foods
        .map(
          (f) => MealFood(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            food: f,
            quantity: f.portion,
          ),
        )
        .toList();

    final meal = Meal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _selectedMealType,
      dateTime: DateTime.now(),
      mealType: _selectedMealType,
      foods: mealFoods,
    );

    context.read<MealBloc>().add(AddMeal(meal));
    context.read<FoodScannerBloc>().add(ClearScannedFoods());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alimentos adicionados com sucesso!')),
    );
  }

  void _openBarcodeScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScanPage()),
    );

    if (result != null && result is FoodItem) {
      _addToMeal([result]);
    }
  }
}
