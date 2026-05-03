part of 'favorite_dish_bloc.dart';

abstract class FavoriteDishEvent extends Equatable {
  const FavoriteDishEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavoriteDishes extends FavoriteDishEvent {}

class AddFavoriteDish extends FavoriteDishEvent {
  final FavoriteDishModel dish;

  const AddFavoriteDish(this.dish);

  @override
  List<Object?> get props => [dish];
}

class DeleteFavoriteDish extends FavoriteDishEvent {
  final String id;

  const DeleteFavoriteDish(this.id);

  @override
  List<Object?> get props => [id];
}

class UseFavoriteDish extends FavoriteDishEvent {
  final FavoriteDishModel dish;

  const UseFavoriteDish(this.dish);

  @override
  List<Object?> get props => [dish];
}
