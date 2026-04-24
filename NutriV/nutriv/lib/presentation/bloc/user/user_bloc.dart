import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc(this._userRepository) : super(UserInitial()) {
    on<LoadUser>(_onLoadUser);
    on<SaveUser>(_onSaveUser);
    on<UpdateUser>(_onUpdateUser);
    on<DeleteUser>(_onDeleteUser);
  }

  void _onLoadUser(LoadUser event, Emitter<UserState> emit) {
    emit(UserLoading());
    try {
      final user = _userRepository.getUser();
      if (user != null) {
        emit(UserLoaded(user));
      } else {
        emit(UserNotFound());
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onSaveUser(SaveUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      await _userRepository.saveUser(event.user);
      emit(UserLoaded(event.user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUpdateUser(UpdateUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      await _userRepository.saveUser(event.user);
      emit(UserLoaded(event.user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onDeleteUser(DeleteUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      await _userRepository.deleteUser();
      emit(UserNotFound());
    } catch (e) {
      emit(UserNotFound());
    }
  }
}
