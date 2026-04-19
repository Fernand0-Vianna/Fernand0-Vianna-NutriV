import 'package:supabase_flutter/supabase_flutter.dart';

class WaterIntakeData {
  final String? id;
  final double amountMl;
  final DateTime entryDate;
  final DateTime consumedAt;
  final String drinkType;

  WaterIntakeData({
    this.id,
    required this.amountMl,
    required this.entryDate,
    required this.consumedAt,
    this.drinkType = 'water',
  });

  Map<String, dynamic> toJson() {
    return {
      'amount_ml': amountMl,
      'entry_date': entryDate.toIso8601String().split('T')[0],
      'consumed_at': consumedAt.toIso8601String(),
      'drink_type': drinkType,
    };
  }

  factory WaterIntakeData.fromJson(Map<String, dynamic> json) {
    return WaterIntakeData(
      id: json['id'] as String?,
      amountMl: (json['amount_ml'] as num).toDouble(),
      entryDate: DateTime.parse(json['entry_date'] as String),
      consumedAt: DateTime.parse(json['consumed_at'] as String),
      drinkType: json['drink_type'] as String? ?? 'water',
    );
  }
}

class WaterRepository {
  final SupabaseClient _supabase;

  WaterRepository(this._supabase);

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Adiciona consumo de água
  Future<WaterIntakeData> addWater(WaterIntakeData water) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Usuário não autenticado');

    final response = await _supabase
        .from('water_intake')
        .insert(water.toJson()..['user_id'] = userId)
        .select()
        .single();

    return WaterIntakeData.fromJson(response);
  }

  /// Busca consumo do dia
  Future<List<WaterIntakeData>> getWaterForDate(DateTime date) async {
    final userId = _currentUserId;
    if (userId == null) return [];

    final dateStr = date.toIso8601String().split('T')[0];

    final response = await _supabase
        .from('water_intake')
        .select()
        .eq('user_id', userId)
        .eq('entry_date', dateStr)
        .order('consumed_at');

    return response.map((json) => WaterIntakeData.fromJson(json)).toList();
  }

  /// Total consumido no dia
  Future<double> getTotalWaterForDate(DateTime date) async {
    final entries = await getWaterForDate(date);
    return entries.fold<double>(0.0, (sum, e) => sum + e.amountMl);
  }

  /// Deleta entrada
  Future<void> deleteWater(String id) async {
    await _supabase.from('water_intake').delete().eq('id', id);
  }

  /// Stream em tempo real
  Stream<List<WaterIntakeData>> watchWaterForDate(DateTime date) {
    final userId = _currentUserId;
    if (userId == null) return Stream.value([]);

    final dateStr = date.toIso8601String().split('T')[0];

    return _supabase.from('water_intake').stream(primaryKey: ['id']).map((
      data,
    ) {
      return data
          .where((w) => w['user_id'] == userId && w['entry_date'] == dateStr)
          .map((json) => WaterIntakeData.fromJson(json))
          .toList();
    });
  }
}
