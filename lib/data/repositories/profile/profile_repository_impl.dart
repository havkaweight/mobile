import 'package:havka/utils/get_user_id_from_token.dart';

import '../../../domain/entities/profile/profile.dart';
import '../../../domain/repositories/auth/auth_repository.dart';
import '../../../domain/repositories/profile/profile_repository.dart';
import '../../api/api_service.dart';
import '../../api/endpoints.dart';
import '../../models/profile/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiService _apiService;
  final AuthRepository _authRepository;

  ProfileRepositoryImpl(this._authRepository, {required apiService}) : _apiService = apiService;

  @override
  Future<Profile> getProfile() async {
    final response = await _apiService.get(
        '${Endpoints.profileService}',
    );
    final data = response.data;
    return ProfileModel.fromJson(data).toDomain();
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    final profileModel = ProfileModel.fromDomain(profile);
    final queryParameters = {'id': profile.id};
    final response = await _apiService.patch(
        '${Endpoints.profileService}id/',
        queryParameters: queryParameters,
        data: profileModel.toJson(),
    );
    return ProfileModel.fromJson(response.data).toDomain();
  }
}
