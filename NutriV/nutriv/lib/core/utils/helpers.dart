import 'package:intl/intl.dart';

class DateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String formatDateLong(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy', 'pt_BR').format(date);
  }

  static String getDayName(DateTime date) {
    return DateFormat('EEEE', 'pt_BR').format(date);
  }

  static String getDayMonth(DateTime date) {
    return DateFormat('d MMM', 'pt_BR').format(date);
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static List<DateTime> getLastNDays(int n) {
    final now = DateTime.now();
    return List.generate(
      n,
      (i) => startOfDay(now.subtract(Duration(days: n - 1 - i))),
    );
  }
}

class NutritionUtils {
  static double calculateBMR({
    required double weight,
    required double height,
    required int age,
    required bool isMale,
  }) {
    if (isMale) {
      return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
  }

  static double calculateTDEE(double bmr, int activityLevel) {
    const multipliers = [1.2, 1.375, 1.55, 1.725, 1.9];
    return bmr * multipliers[activityLevel];
  }

  static String getActivityLevel(int level) {
    const levels = [
      'Sedentário',
      'Levemente ativo',
      'Moderadamente ativo',
      'Muito ativo',
      'Extremamente ativo',
    ];
    return levels[level];
  }

  static double calculateGoalCalories(double tdee, String goal) {
    switch (goal) {
      case 'lose':
        return tdee - 500;
      case 'gain':
        return tdee + 500;
      default:
        return tdee;
    }
  }

  /// Parse de peso que aceita vírgula ou ponto como separador decimal
  static double parseWeight(String value) {
    if (value.isEmpty) return 70; // Valor padrão
    final cleaned = value.replaceAll(',', '.').trim();
    return double.tryParse(cleaned) ?? 70;
  }

  /// Parse de altura que aceita vírgula ou ponto como separador decimal
  static double parseHeight(String value) {
    if (value.isEmpty) return 170; // Valor padrão
    final cleaned = value.replaceAll(',', '.').trim();
    return double.tryParse(cleaned) ?? 170;
  }
}

class WaterUtils {
  /// Calcula a meta diária de água em ml baseada no peso do usuário
  /// Fórmula: 35ml por kg de peso corporal (ajustável por atividade)
  static double calculateWaterGoal({
    required double weightKg,
    int activityLevel = 2,
    String climate = 'temperate',
  }) {
    // Base: 35ml por kg
    double baseWater = weightKg * 35;

    // Ajuste por nível de atividade
    final activityMultipliers = [1.0, 1.1, 1.2, 1.3, 1.4];
    baseWater *= activityMultipliers[activityLevel.clamp(0, 4)];

    // Ajuste por clima
    switch (climate) {
      case 'hot':
        baseWater *= 1.2; // +20% em clima quente
        break;
      case 'cold':
        baseWater *= 0.9; // -10% em clima frio
        break;
      default:
        break;
    }

    // Arredonda para múltiplo de 100 e limita entre 1500ml e 5000ml
    return baseWater.clamp(1500, 5000).roundToDouble();
  }

  /// Converte ml para litros com formatação
  static String formatLiters(double ml) {
    return '${(ml / 1000).toStringAsFixed(1)}L';
  }

  /// Converte litros (string) para ml
  static double parseLiters(String liters) {
    final cleaned = liters.replaceAll(',', '.').replaceAll('L', '').trim();
    final litersValue = double.tryParse(cleaned) ?? 0;
    return litersValue * 1000;
  }
}

class Validators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName é obrigatório';
    }
    return null;
  }

  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }
    if (double.tryParse(value) == null) {
      return '$fieldName deve ser um número';
    }
    return null;
  }

  static String? validatePositiveNumber(String? value, String fieldName) {
    final result = validateNumber(value, fieldName);
    if (result != null) return result;
    if (double.parse(value!) <= 0) {
      return '$fieldName deve ser maior que zero';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-mail é obrigatório';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'E-mail inválido';
    }
    return null;
  }
}
