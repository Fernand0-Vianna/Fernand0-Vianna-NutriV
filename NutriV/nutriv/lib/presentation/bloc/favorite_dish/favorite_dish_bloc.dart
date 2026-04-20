import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/favorite_dish_repository.dart';
import '../../../data/models/favorite_dish_model.dart';

part 'favorite_dish_event.dart';
part 'favorite_dish_state.dart';

class FavoriteDishBloc extends Bloc<FavoriteDishEvent, FavoriteDishState> {
  final FavoriteDishRepository _repository;

  FavoriteDishBloc(this._repository) : super(FavoriteDishInitial()) {
    on<LoadFavoriteDishes>(_onLoadFavoriteDishes);
    on<AddFavoriteDish>(_onAddFavoriteDish);
    on<DeleteFavoriteDish>(_onDeleteFavoriteDish);
    on<UseFavoriteDish>(_onUseFavoriteDish);
  }

  Future<void> _onLoadFavoriteDishes(
    LoadFavoriteDishes event,
    Emitter<FavoriteDishState> emit,
  ) async {
    emit(FavoriteDishLoading());
    try {
      final dishes = await _repository.getFavoriteDishes();
      emit(FavoriteDishLoaded(dishes: dishes));
    } catch (e) {
      emit(FavoriteDishError(e.toString()));
    }
  }

  Future<void> _onAddFavoriteDish(
    AddFavoriteDish event,
    Emitter<FavoriteDishState> emit,
  ) async {
    try {
      await _repository.addFavoriteDish(event.dish);
      add(LoadFavoriteDishes());
    } catch (e) {
      emit(FavoriteDishError(e.toString()));
    }
  }

  Future<void> _onDeleteFavoriteDish(
    DeleteFavoriteDish event,
    Emitter<FavoriteDishState> emit,
  ) async {
    try {
      await _repository.deleteFavoriteDish(event.id);
      add(LoadFavoriteDishes());
    } catch (e) {
      emit(FavoriteDishError(e.toString()));
    }
  }

  Future<void> _onUseFavoriteDish(
    UseFavoriteDish event,
    Emitter<FavoriteDishState> emit,
  ) async {
    try {
      final dishId = event.dish.id;
      if (dishId != null) {
        await _repository.updateTimesUsed(dishId, event.dish.timesUsed + 1);
        add(LoadFavoriteDishes());
      }
    } catch (e) {
      // Ignore increment errors
    }
  }
}
