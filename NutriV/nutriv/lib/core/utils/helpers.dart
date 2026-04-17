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
