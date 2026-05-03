import 'package:supabase_flutter/supabase_flutter.dart';

class WeightLogData {
  final String? id;
  final double weightKg;
  final DateTime entryDate;
  final DateTime recordedAt;
  final double? bodyFatPercentage;
  final String? notes;
  final String source;

  WeightLogData({
    this.id,
    required this.weightKg,
    required this.entryDate,
    required this.recordedAt,
    this.bodyFatPercentage,
    this.notes,
    this.source = 'manual',
  });

  Map<String, dynamic> toJson() {
    return {
      'weight_kg': weightKg,
      'entry_date': entryDate.toIso8601String().split('T')[0],
      'recorded_at': recordedAt.toIso8601String(),
      'body_fat_percentage': bodyFatPercentage,
      'notes': notes,
      'source': source,
    };
  }

  factory WeightLogData.fromJson(Map<String, dynamic> json) {
    return WeightLogData(
      id: json['id'] as String?,
      weightKg: (json['weight_kg'] as num).toDouble(),
      entryDate: DateTime.parse(json['entry_date'] as String),
      recordedAt: DateTime.parse(json['recorded_at'] as String),
      bodyFatPercentage: (json['body_fat_percentage'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      source: json['source'] as String? ?? 'manual',
    );
  }
}

class WeightRepository {
  final SupabaseClient _supabase;

  WeightRepository(this._supabase);

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Registra peso
  Future<WeightLogData> addWeight(WeightLogData weight) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Usuário não autenticado');

    final response = await _supabase
        .from('weight_logs')
        .insert(weight.toJson()..['user_id'] = userId)
        .select()
        .single();

    return WeightLogData.fromJson(response);
  }

  /// Busca histórico (últimos N dias)
  Future<List<WeightLogData>> getWeightHistory({int days = 30}) async {
    final userId = _currentUserId;
    if (userId == null) return [];

    final startDate = DateTime.now().subtract(Duration(days: days));
    final startStr = startDate.toIso8601String().split('T')[0];

    final response = await _supabase
        .from('weight_logs')
        .select()
        .eq('user_id', userId)
        .gte('entry_date', startStr)
        .order('entry_date', ascending: false);

    return response.map((json) => WeightLogData.fromJson(json)).toList();
  }

  /// Peso mais recente
  Future<WeightLogData?> getLatestWeight() async {
    final userId = _currentUserId;
    if (userId == null) return null;

    final response = await _supabase
        .from('weight_logs')
        .select()
        .eq('user_id', userId)
        .order('entry_date', ascending: false)
        .limit(1)
        .maybeSingle();

    return response != null ? WeightLogData.fromJson(response) : null;
  }

  /// Peso de uma data específica
  Future<WeightLogData?> getWeightForDate(DateTime date) async {
    final userId = _currentUserId;
    if (userId == null) return null;

    final dateStr = date.toIso8601String().split('T')[0];

    final response = await _supabase
        .from('weight_logs')
        .select()
        .eq('user_id', userId)
        .eq('entry_date', dateStr)
        .maybeSingle();

    return response != null ? WeightLogData.fromJson(response) : null;
  }

  /// Atualiza registro
  Future<void> updateWeight(String id, WeightLogData weight) async {
    await _supabase
        .from('weight_logs')
        .update(weight.toJson()..remove('user_id'))
        .eq('id', id);
  }

  /// Deleta registro
  Future<void> deleteWeight(String id) async {
    await _supabase.from('weight_logs').delete().eq('id', id);
  }

  /// Progresso: peso inicial vs atual
  Future<Map<String, dynamic>?> getProgress() async {
    final history = await getWeightHistory(days: 365);
    if (history.isEmpty) return null;

    final latest = history.first;
    final oldest = history.last;
    final change = latest.weightKg - oldest.weightKg;

    return {
      'initial': oldest.weightKg,
      'current': latest.weightKg,
      'change': change,
      'changePercent': (change / oldest.weightKg) * 100,
      'daysTracked': history.length,
    };
  }

  /// Stream em tempo real
  Stream<List<WeightLogData>> watchWeightHistory() {
    final userId = _currentUserId;
    if (userId == null) return Stream.value([]);

    return _supabase.from('weight_logs').stream(primaryKey: ['id']).map((data) {
      return data
          .where((w) => w['user_id'] == userId)
          .map((json) => WeightLogData.fromJson(json))
          .toList()
        ..sort((a, b) => b.entryDate.compareTo(a.entryDate));
    });
  }
}
