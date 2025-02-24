import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/repositories/auth/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider({required AuthRepository repository}) : _repository = repository;

  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> login(BuildContext context, String username, String password) async {
    log('AuthProvider: Login');
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.login(username, password);
      _isAuthenticated = true;
      notifyListeners();
      context.go('/fridge');
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      log('Error: ${_errorMessage}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.loginWithGoogle();
      _isAuthenticated = true;
    } catch (e) {
      _errorMessage = 'Google login failed: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithApple(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.loginWithApple(email);
      _isAuthenticated = true;
    } catch (e) {
      _errorMessage = 'Apple login failed: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> signUp(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.signUp(username, password);
    } catch (e) {
      _errorMessage = 'Sign up failed: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshToken() async {
    try {
      await _repository.refreshToken();
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Refresh token failed: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
