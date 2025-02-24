import 'package:flutter/material.dart';
import '../../domain/entities/user/user.dart';
import '../../domain/repositories/user/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _repository;

  User? _user;
  bool _isLoading = false;

  UserProvider({required UserRepository repository}) : _repository = repository;

  User? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> fetchMe() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _repository.getMe();
    } catch (e) {
      throw('Failed to fetch me: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUser(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _repository.getUserById(id);
    } catch (e) {
      throw('Failed to fetch user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(User updatedUser) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _repository.updateUser(updatedUser);
    } catch (e) {
      throw('Failed to update user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.deleteUser(id);
      _user = null;
      notifyListeners();
    } catch (e) {
      throw('Failed to delete User: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
