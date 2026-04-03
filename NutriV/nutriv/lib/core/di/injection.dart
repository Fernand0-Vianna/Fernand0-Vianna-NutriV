import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../data/datasources/local_data_source.dart';
import '../../data/datasources/ai_food_service.dart';
import '../../data/datasources/auth_service.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/meal_repository.dart';
import '../../data/repositories/daily_log_repository.dart';
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
  getIt.registerSingleton<GoogleSignIn>(GoogleSignIn());

  getIt.registerSingleton<LocalDataSource>(
    LocalDataSource(getIt<SharedPreferences>()),
  );

  getIt.registerSingleton<AiFoodService>(AiFoodService(getIt<Dio>()));

  getIt.registerSingleton<UserRepository>(
    UserRepository(getIt<LocalDataSource>()),
  );

  getIt.registerSingleton<AuthService>(
    AuthService(getIt<GoogleSignIn>(), getIt<UserRepository>()),
  );

  getIt.registerSingleton<MealRepository>(
    MealRepository(getIt<SharedPreferences>()),
  );

  getIt.registerSingleton<DailyLogRepository>(
    DailyLogRepository(getIt<LocalDataSource>()),
  );

  getIt.registerFactory<UserBloc>(() => UserBloc(getIt<UserRepository>()));

  getIt.registerFactory<MealBloc>(() => MealBloc(getIt<MealRepository>()));

  getIt.registerFactory<FoodScannerBloc>(
    () => FoodScannerBloc(getIt<AiFoodService>()),
  );

  getIt.registerFactory<WaterBloc>(() => WaterBloc(getIt<SharedPreferences>()));

  getIt.registerFactory<BarcodeScannerBloc>(() => BarcodeScannerBloc());
}
