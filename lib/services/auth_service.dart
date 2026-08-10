import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get user => _auth.authStateChanges();

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on TypeError catch (e) {
      throw _handleAuthError(te: e);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(fe: e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _handleAuthError({FirebaseAuthException? fe, TypeError? te}) {
    var error = '';
    if (fe != null) {
      switch (fe.code) {
        case 'user-not-found':
          error = 'Usuário não encontrado.';
        case 'wrong-password':
          error = 'Senha incorreta.';
        case 'invalid-email':
          error = 'Email inválido.';
        default:
          error = 'Erro ao fazer login. Tente novamente.';
      }
    }
    if (te != null) {
      switch (te.runtimeType.toString()) {
        case '_TypeError':
          error = '';
      }
    }
    return error;
  }
}