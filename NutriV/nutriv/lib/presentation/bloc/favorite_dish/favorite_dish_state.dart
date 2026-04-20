part of 'favorite_dish_bloc.dart';

abstract class FavoriteDishState extends Equatable {
  const FavoriteDishState();

  @override
  List<Object?> get props => [];
}

class FavoriteDishInitial extends FavoriteDishState {}

class FavoriteDishLoading extends FavoriteDishState {}

class FavoriteDishLoaded extends FavoriteDishState {
  final List<FavoriteDishModel> dishes;

  const FavoriteDishLoaded({required this.dishes});

  @override
  List<Object?> get props => [dishes];
}

class FavoriteDishError extends FavoriteDishState {
  final String message;

  const FavoriteDishError(this.message);

  @override
  List<Object?> get props => [message];
}