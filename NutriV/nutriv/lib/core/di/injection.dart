import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/theme_notifier.dart';
import '../../core/services/error_tracking_service.dart';
import '../../core/services/haptic_service.dart';
import '../../core/interceptors/dio_interceptors.dart';
import '../../data/database/database_helper.dart';
import '../../data/database/sp_migration.dart';
import '../../data/datasources/local_data_source.dart';
import '../../data/datasources/ai_food_service.dart';
import '../../data/datasources/groq_vision_service.dart';
import '../../data/datasources/usda_food_service.dart';
import '../../data/datasources/fatsecret_service.dart';
import '../../data/datasources/gemini_food_service.dart';
import '../../data/datasources/auth_service.dart';
import '../../data/datasources/pedometer_service.dart';
import '../../data/datasources/activity_service.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../../data/repositories/meal_repository_v2.dart';
import '../../data/repositories/daily_log_repository.dart';
import '../../data/repositories/sync_meal_repository.dart';
import '../../data/repositories/water_repository.dart';
import '../../data/repositories/weight_repository.dart';
import '../../data/repositories/daily_summary_repository.dart';
import '../../data/repositories/favorite_dish_repository.dart';
import '../../domain/repositories/i_user_profile_repository.dart';
import '../../domain/repositories/i_meal_repository.dart';
import '../../domain/repositories/i_water_repository.dart';
import '../../domain/repositories/i_weight_repository.dart';
import '../../domain/repositories/i_daily_summary_repository.dart';
import '../../domain/repositories/i_favorite_dish_repository.dart';
import '../../presentation/bloc/user/user_bloc.dart';
import '../../presentation/bloc/meal/meal_bloc.dart';
import '../../presentation/bloc/food_scanner/food_scanner_bloc.dart';
import '../../presentation/bloc/water/water_bloc.dart';
import '../../presentation/bloc/barcode/barcode_scanner_bloc.dart';
import '../../presentation/bloc/weight/weight_bloc.dart';
import '../../presentation/bloc/favorite_dish/favorite_dish_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerSingleton<ErrorTrackingService>(ErrorTrackingService());
  getIt.registerSingleton<HapticService>(HapticService());

  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));
  dio.interceptors.add(LoggingInterceptor());
  dio.interceptors.add(AuthInterceptor());
  getIt.registerSingleton<Dio>(dio);

  final dbHelper = DatabaseHelper.instance;
  getIt.registerSingleton<DatabaseHelper>(dbHelper);

  await SharedPreferencesMigration.runMigration();

  await dbHelper.clearOldCache(daysOld: 30);

  getIt.registerSingleton<LocalDataSource>(
    LocalDataSource(getIt<SharedPreferences>(), dbHelper),
  );

  getIt.registerSingleton<ThemeNotifier>(
    ThemeNotifier(getIt<SharedPreferences>()),
  );

  getIt.registerSingleton<AiFoodService>(AiFoodService(getIt<Dio>()));
  getIt.registerSingleton<GroqVisionService>(GroqVisionService(getIt<Dio>()));
  getIt.registerSingleton<UsdaFoodService>(
    UsdaFoodService(getIt<Dio>(), dbHelper),
  );

  getIt.registerSingleton<FatSecretService>(
    FatSecretService(getIt<Dio>()),
  );

  getIt.registerSingleton<GeminiFoodService>(
    GeminiFoodService(getIt<Dio>()),
  );

  getIt.registerSingleton<UserRepository>(
    UserRepository(getIt<LocalDataSource>()),
  );

  getIt.registerSingleton<AuthService>(
    AuthService(Supabase.instance.client, getIt<UserRepository>()),
  );

  getIt.registerSingleton<IUserProfileRepository>(
    UserProfileRepository(Supabase.instance.client),
  );

  getIt.registerSingleton<IMealRepositoryV2>(
    MealRepositoryV2(Supabase.instance.client),
  );

  getIt.registerSingleton<IWaterRepository>(
    WaterRepository(Supabase.instance.client),
  );

  getIt.registerSingleton<IWeightRepository>(
    WeightRepository(Supabase.instance.client),
  );

  getIt.registerSingleton<IDailySummaryRepository>(
    DailySummaryRepository(Supabase.instance.client),
  );

  getIt.registerSingleton<IFavoriteDishRepository>(
    FavoriteDishRepository(Supabase.instance.client),
  );

  getIt.registerSingleton<SyncMealRepository>(
    SyncMealRepository(dbHelper, Supabase.instance.client),
  );

  getIt.registerSingleton<DailyLogRepository>(
    DailyLogRepository(getIt<LocalDataSource>()),
  );

  getIt.registerSingleton<PedometerService>(PedometerService(dbHelper));
  await getIt<PedometerService>().initialize();

  getIt.registerSingleton<ActivityService>(ActivityService(dbHelper));
  await getIt<ActivityService>().initialize();

  getIt.registerFactory<UserBloc>(() => UserBloc(getIt<UserRepository>()));

  getIt.registerFactory<MealBloc>(() => MealBloc(getIt<SyncMealRepository>()));

  getIt.registerFactory<FoodScannerBloc>(
    () => FoodScannerBloc(
      getIt<AiFoodService>(),
      getIt<GroqVisionService>(),
      getIt<UsdaFoodService>(),
      getIt<FatSecretService>(),
      getIt<GeminiFoodService>(),
    ),
  );

  getIt.registerFactory<WaterBloc>(() => WaterBloc(dbHelper));

  getIt.registerFactory<BarcodeScannerBloc>(() => BarcodeScannerBloc());

  getIt
      .registerFactory<WeightBloc>(() => WeightBloc(getIt<IWeightRepository>()));

  getIt.registerFactory<FavoriteDishBloc>(
      () => FavoriteDishBloc(getIt<IFavoriteDishRepository>()));

  final currentUser = Supabase.instance.client.auth.currentUser;
  if (currentUser != null) {
    await getIt<SyncMealRepository>().init();
  }
}
