import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/local_data_source.dart';
import '../../data/datasources/ai_food_service.dart';
import '../../data/datasources/usda_food_service.dart';
import '../../data/datasources/auth_service.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/meal_repository.dart';
import '../../data/repositories/daily_log_repository.dart';
import '../../data/repositories/sync_meal_repository.dart';
import '../../presentation/bloc/user/user_bloc.dart';
import '../../presentation/bloc/meal/meal_bloc.dart';
import '../../presentation/bloc/food_scanner/food_scanner_bloc.dart';
import '../../presentation/bloc/water/water_bloc.dart';
import '../../presentation/bloc/barcode/barcode_scanner_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerSingleton<Dio>(Dio());

  getIt.registerSingleton<LocalDataSource>(
    LocalDataSource(getIt<SharedPreferences>()),
  );

  getIt.registerSingleton<AiFoodService>(AiFoodService(getIt<Dio>()));
  getIt.registerSingleton<UsdaFoodService>(UsdaFoodService(getIt<Dio>()));

  getIt.registerSingleton<UserRepository>(
    UserRepository(getIt<LocalDataSource>()),
  );

  getIt.registerSingleton<AuthService>(
    AuthService(Supabase.instance.client, getIt<UserRepository>()),
  );

  getIt.registerSingleton<SyncMealRepository>(
    SyncMealRepository(getIt<SharedPreferences>(), Supabase.instance.client),
  );

  getIt.registerSingleton<MealRepository>(
    MealRepository(getIt<SharedPreferences>()),
  );

  getIt.registerSingleton<DailyLogRepository>(
    DailyLogRepository(getIt<LocalDataSource>()),
  );

  getIt.registerFactory<UserBloc>(() => UserBloc(getIt<UserRepository>()));

  getIt.registerFactory<MealBloc>(() => MealBloc(getIt<SyncMealRepository>()));

  getIt.registerFactory<FoodScannerBloc>(
    () => FoodScannerBloc(getIt<AiFoodService>(), getIt<UsdaFoodService>()),
  );

  getIt.registerFactory<WaterBloc>(() => WaterBloc(getIt<SharedPreferences>()));

  getIt.registerFactory<BarcodeScannerBloc>(() => BarcodeScannerBloc());
}