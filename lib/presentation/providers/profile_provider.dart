import 'package:flutter/material.dart';
import 'package:havka/presentation/screens/authorization.dart';
import 'package:havka/utils/get_user_id_from_token.dart';
import '../../domain/entities/profile/profile.dart';
import '../../domain/repositories/profile/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;

  Profile? _profile;
  bool _isLoading = false;

  ProfileProvider({required ProfileRepository repository}) : _repository = repository;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = await _repository.getProfile();
    } catch (e) {
      throw('Failed to fetch profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Profile updatedProfile) async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = await _repository.updateProfile(updatedProfile);
    } catch (e) {
      throw('Failed to update user profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
