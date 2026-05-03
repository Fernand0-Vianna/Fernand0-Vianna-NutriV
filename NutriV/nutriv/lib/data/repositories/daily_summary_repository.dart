import 'package:supabase_flutter/supabase_flutter.dart';

class DailySummaryData {
  final String? id;
  final DateTime summaryDate;
  final double totalCalories;
  final double totalProteinG;
  final double totalCarbsG;
  final double totalFatG;
  final double totalFiberG;
  final double waterConsumedMl;
  final double caloriesTarget;
  final double caloriesRemaining;
  final bool isGoalMet;
  final int mealsCount;
  final int entriesCount;
  final DateTime lastCalculatedAt;

  DailySummaryData({
    this.id,
    required this.summaryDate,
    this.totalCalories = 0,
    this.totalProteinG = 0,
    this.totalCarbsG = 0,
    this.totalFatG = 0,
    this.totalFiberG = 0,
    this.waterConsumedMl = 0,
    this.caloriesTarget = 2000,
    this.caloriesRemaining = 2000,
    this.isGoalMet = true,
    this.mealsCount = 0,
    this.entriesCount = 0,
    required this.lastCalculatedAt,
  });

  factory DailySummaryData.fromJson(Map<String, dynamic> json) {
    return DailySummaryData(
      id: json['id'] as String?,
      summaryDate: DateTime.parse(json['summary_date'] as String),
      totalCalories: (json['total_calories'] as num?)?.toDouble() ?? 0,
      totalProteinG: (json['total_protein_g'] as num?)?.toDouble() ?? 0,
      totalCarbsG: (json['total_carbs_g'] as num?)?.toDouble() ?? 0,
      totalFatG: (json['total_fat_g'] as num?)?.toDouble() ?? 0,
      totalFiberG: (json['total_fiber_g'] as num?)?.toDouble() ?? 0,
      waterConsumedMl: (json['water_consumed_ml'] as num?)?.toDouble() ?? 0,
      caloriesTarget: (json['calories_target'] as num?)?.toDouble() ?? 2000,
      caloriesRemaining:
          (json['calories_remaining'] as num?)?.toDouble() ?? 2000,
      isGoalMet: json['is_goal_met'] as bool? ?? true,
      mealsCount: json['meals_count'] as int? ?? 0,
      entriesCount: json['entries_count'] as int? ?? 0,
      lastCalculatedAt: DateTime.parse(json['last_calculated_at'] as String),
    );
  }

  /// Porcentagem de calorias consumidas
  double get caloriesConsumedPercent {
    if (caloriesTarget == 0) return 0;
    return (totalCalories / caloriesTarget).clamp(0.0, 1.0);
  }

  /// Porcentagem de água consumida (base: 2500ml)
  double get waterConsumedPercent {
    return (waterConsumedMl / 2500).clamp(0.0, 1.0);
  }
}

class DailySummaryRepository {
  final SupabaseClient _supabase;

  DailySummaryRepository(this._supabase);

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Busca resumo do dia
  Future<DailySummaryData?> getSummaryForDate(DateTime date) async {
    final userId = _currentUserId;
    if (userId == null) return null;

    final dateStr = date.toIso8601String().split('T')[0];

    final response = await _supabase
        .from('daily_summaries')
        .select()
        .eq('user_id', userId)
        .eq('summary_date', dateStr)
        .maybeSingle();

    return response != null ? DailySummaryData.fromJson(response) : null;
  }

  /// Busca resumos de um período
  Future<List<DailySummaryData>> getSummariesForRange(
    DateTime start,
    DateTime end,
  ) async {
    final userId = _currentUserId;
    if (userId == null) return [];

    final startStr = start.toIso8601String().split('T')[0];
    final endStr = end.toIso8601String().split('T')[0];

    final response = await _supabase
        .from('daily_summaries')
        .select()
        .eq('user_id', userId)
        .gte('summary_date', startStr)
        .lte('summary_date', endStr)
        .order('summary_date', ascending: false);

    return response.map((json) => DailySummaryData.fromJson(json)).toList();
  }

  /// Força recálculo do resumo
  Future<void> recalculateSummary(DateTime date) async {
    final userId = _currentUserId;
    if (userId == null) return;

    // O recálculo é feito automaticamente pelo trigger
    // Mas podemos forçar atualizando uma refeição vazia ou chamando RPC
    await _supabase.rpc('recalculate_daily_summary', params: {
      'p_user_id': userId,
      'p_date': date.toIso8601String().split('T')[0],
    });
  }

  /// Stream em tempo real do resumo do dia
  Stream<DailySummaryData?> watchTodaySummary() {
    return watchSummaryForDate(DateTime.now());
  }

  /// Stream em tempo real
  Stream<DailySummaryData?> watchSummaryForDate(DateTime date) {
    final userId = _currentUserId;
    if (userId == null) return Stream.value(null);

    final dateStr = date.toIso8601String().split('T')[0];

    return _supabase
        .from('daily_summaries')
        .stream(primaryKey: ['id']).map((data) {
      final summary = data.firstWhere(
        (s) => s['user_id'] == userId && s['summary_date'] == dateStr,
        orElse: () => <String, dynamic>{},
      );
      return summary.isNotEmpty ? DailySummaryData.fromJson(summary) : null;
    });
  }

  /// Stream dos últimos 7 dias
  Stream<List<DailySummaryData>> watchWeeklySummary() {
    final userId = _currentUserId;
    if (userId == null) return Stream.value([]);

    return _supabase
        .from('daily_summaries')
        .stream(primaryKey: ['id']).map((data) {
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));

      return data
          .where((s) {
            final date = DateTime.parse(s['summary_date'] as String);
            return s['user_id'] == userId && date.isAfter(weekAgo);
          })
          .map((json) => DailySummaryData.fromJson(json))
          .toList()
        ..sort((a, b) => a.summaryDate.compareTo(b.summaryDate));
    });
  }

  /// Estatísticas da semana
  Future<Map<String, dynamic>> getWeeklyStats() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final summaries = await getSummariesForRange(weekAgo, now);

    if (summaries.isEmpty) {
      return {
        'avgCalories': 0.0,
        'avgWater': 0.0,
        'goalDays': 0,
        'totalDays': 0,
      };
    }

    final totalCalories =
        summaries.fold<double>(0, (sum, s) => sum + s.totalCalories);
    final totalWater =
        summaries.fold<double>(0, (sum, s) => sum + s.waterConsumedMl);
    final goalDays = summaries.where((s) => s.isGoalMet).length;

    return {
      'avgCalories': totalCalories / summaries.length,
      'avgWater': totalWater / summaries.length,
      'goalDays': goalDays,
      'totalDays': summaries.length,
    };
  }
}
