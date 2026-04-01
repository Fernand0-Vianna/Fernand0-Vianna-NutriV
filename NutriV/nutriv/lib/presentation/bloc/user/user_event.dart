import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUser extends UserEvent {}

class SaveUser extends UserEvent {
  final User user;

  const SaveUser(this.user);

  @override
  List<Object?> get props => [user];
}

class UpdateUser extends UserEvent {
  final User user;

  const UpdateUser(this.user);

  @override
  List<Object?> get props => [user];
}

class DeleteUser extends UserEvent {}
