import '../../domain/entities/user.dart';
import '../models/user_model.dart';
import '../datasources/local_data_source.dart';

class UserRepository {
  final LocalDataSource _localDataSource;

  UserRepository(this._localDataSource);

  Future<void> saveUser(User user) async {
    await _localDataSource.saveUser(UserModel.fromEntity(user));
  }

  User? getUser() {
    return _localDataSource.getUser();
  }

  Future<void> deleteUser() async {
    await _localDataSource.deleteUser();
  }

  bool hasUser() {
    return _localDataSource.getUser() != null;
  }
}
