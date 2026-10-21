import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get usuario => _auth.currentUser;

  String get nome =>
      usuario?.displayName?.isNotEmpty == true
          ? usuario!.displayName!
          : (usuario?.email ?? 'Usuário');

  AuthService() {
    _auth.authStateChanges().listen((_) => notifyListeners());
  }

  Future<String?> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      final credencial = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      await credencial.user?.updateDisplayName(nome);
      await credencial.user?.reload();
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _traduzirErro(e);
    } catch (_) {
      return 'Erro inesperado ao cadastrar. Tente novamente.';
    }
  }

  Future<String?> entrar({required String email, required String senha}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _traduzirErro(e);
    } catch (_) {
      return 'Erro inesperado ao entrar. Tente novamente.';
    }
  }

  Future<void> sair() async {
    await _auth.signOut();
    notifyListeners();
  }

  Future<String?> atualizarNome(String novoNome) async {
    try {
      await usuario?.updateDisplayName(novoNome);
      await usuario?.reload();
      notifyListeners();
      return null;
    } catch (_) {
      return 'Erro ao atualizar o nome.';
    }
  }

  String _traduzirErro(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Este e-mail já está em uso.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'weak-password':
        return 'A senha é muito fraca.';
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      default:
        return 'Erro: ${e.message ?? e.code}';
    }
  }
}
