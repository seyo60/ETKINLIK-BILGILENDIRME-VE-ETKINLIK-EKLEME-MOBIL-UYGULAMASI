import 'package:firebase_auth/firebase_auth.dart';

final authRepository = AuthRepository(auth: FirebaseAuth.instance);

class AuthRepository {
  final FirebaseAuth auth;

  User? get currentUser => auth.currentUser;
  Stream<User?> get authStateChanges => auth.authStateChanges();

  AuthRepository({
    required this.auth,
  });

  // Giriş için
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Kayıt için
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Çıkış için
  Future<void> signOut() async {
    await auth.signOut();
  }
}
