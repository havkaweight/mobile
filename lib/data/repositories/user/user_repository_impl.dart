import 'package:havka/data/api/token_storage.dart';
import 'package:havka/domain/repositories/user/user_repository.dart';
import 'package:havka/data/api/endpoints.dart';
import 'package:havka/utils/get_user_id_from_token.dart';

import '../../../domain/entities/user/user.dart';
import '../../api/api_service.dart';
import '../../models/user/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiService apiService;

  UserRepositoryImpl({required this.apiService});

  @override
  Future<List<User>> getAllUsers() async {
    final response = await apiService.get(Endpoints.products);
    final List<dynamic> data = response.data;
    return data.map((json) => UserModel.fromJson(json).toDomain()).toList();
  }

  @override
  Future<User> getUserById(String id) async {
    final queryParameters = {'id': id};
    final response = await apiService.get('${Endpoints.userService}', queryParameters: queryParameters);
    final data = response.data;
    return UserModel.fromJson(data).toDomain();
  }

  @override
  Future<User> getMe() async {
    final TokenStorage _tokenStorage = TokenStorage();
    final token = await _tokenStorage.getAccessToken();
    final userId = await getUserIdFromToken(token);

    final queryParameters = {'id': userId};
    final response = await apiService.get(
        '${Endpoints.userService}',
        queryParameters: queryParameters,
    );
    final data = response.data;
    return UserModel.fromJson(data).toDomain();
  }

  @override
  Future<User> createUser(User user) async {
    final userModel = UserModel.fromDomain(user);
    final newUserData = await apiService.post('${Endpoints.userService}', data: userModel.toJson());
    return UserModel.fromJson(newUserData.data).toDomain();
  }

  @override
  Future<User> updateUser(User user) async {
    final queryParameters = {'id': user.id};
    final userModel = UserModel.fromDomain(user);
    final updatedUserData = await apiService.patch(
        '${Endpoints.userService}id/',
        queryParameters: queryParameters,
        data: userModel.toJson()
    );
    return UserModel.fromJson(updatedUserData.data).toDomain();
  }

  @override
  Future<void> deleteUser(String id) async {
    final queryParameters = {'id': id};
    await apiService.delete(
      '${Endpoints.products}id/',
      queryParameters: queryParameters,
    );
  }
}