import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../repositories/user_repository.dart';

class AuthService {
  final GoogleSignIn _googleSignIn;
  final UserRepository _userRepository;

  AuthService(this._googleSignIn, this._userRepository);

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      await googleUser.authentication;

      final user = User(
        id: googleUser.id,
        name: googleUser.displayName ?? 'Usuário',
        email: googleUser.email,
        photoUrl: googleUser.photoUrl,
        weight: 0,
        height: 0,
        age: 0,
        isMale: true,
        activityLevel: 1,
        goal: 'maintain',
        calorieGoal: 2000,
        proteinGoal: 150,
        carbsGoal: 250,
        fatGoal: 65,
        waterGoal: 2000,
        createdAt: DateTime.now(),
      );
      await _userRepository.saveUser(user);
      return user;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error signing in with Google: $e');
      }
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  User? getCurrentUser() {
    return _userRepository.getUser();
  }

  bool isSignedIn() {
    return _googleSignIn.currentUser != null;
  }
}
