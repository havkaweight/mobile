import '../../../domain/entities/fridge/fridge.dart';
import '../../../domain/entities/fridge/user_fridge.dart';
import '../../../domain/repositories/fridge/fridge_repository.dart';
import '../../api/endpoints.dart';
import '../../../domain/entities/product/fridge_item.dart';
import '../../api/api_service.dart';
import '../../models/fridge/fridge_model.dart';
import '../../models/fridge/user_fridge_model.dart';
import '../../models/product/fridge_item_model.dart';

class FridgeRepositoryImpl implements FridgeRepository {
  final ApiService _apiService;

  FridgeRepositoryImpl({required apiService}) : this._apiService = apiService;

  @override
  Future<List<Fridge>> getAllFridges() async {
    final response = await _apiService.get(Endpoints.fridgeService);
    final List<dynamic> data = response.data;
    return data.map((json) => FridgeModel.fromJson(json).toDomain()).toList();
  }

  @override
  Future<List<UserFridge>> getAllUserFridges() async {
    final response = await _apiService.get('${Endpoints.fridgeService}${Endpoints.fridgeUser}');
    final List<dynamic> data = response.data;
    return data.map((json) => UserFridgeModel.fromJson(json).toDomain()).toList();
  }

  @override
  Future<Fridge> getFridgeById(String id) async {
    final response = await _apiService.get('${Endpoints.fridgeService}/$id');
    return FridgeModel.fromJson(response.data).toDomain();
  }

  @override
  Future<Fridge> createNewFridge() async {
    final response = await _apiService.post(Endpoints.fridgeService);
    return FridgeModel.fromJson(response.data).toDomain();
  }

  @override
  Future<void> deleteFridge(String id) async {
    final queryParameters = {'id': id};
    await _apiService.delete(
      '${Endpoints.fridgeService}id/',
      queryParameters: queryParameters,
    );
  }


  @override
  Future<UserFridge> createUserFridge(String name, String? fridgeId) async {
    fridgeId ??= (await createNewFridge()).id;
    final userFridgeModel = UserFridgeModel(name: name, fridgeId: fridgeId);
    final response = await _apiService.post(
        '${Endpoints.fridgeService}${Endpoints.fridgeUser}',
        data: userFridgeModel.toJson(),
    );
    return UserFridgeModel.fromJson(response.data).toDomain();
  }

  @override
  Future<UserFridge> updateUserFridge(UserFridge userFridge) async {
    final queryParameters = {'id': userFridge.id};
    final userFridgeModel = UserFridgeModel.fromDomain(userFridge);
    final response = await _apiService.patch(
        '${Endpoints.fridgeService}${Endpoints.fridgeUser}id/',
        queryParameters: queryParameters,
        data: userFridgeModel.toJson(),
    );
    final dynamic data = response.data;
    return UserFridgeModel.fromJson(data).toDomain();
  }

  @override
  Future<void> deleteUserFridge(UserFridge userFridge) async {
    final queryParameters = {
      'id': userFridge.id,
      'fridge_id': userFridge.fridgeId
    };
    await _apiService.delete(
      '${Endpoints.fridgeService}${Endpoints.fridgeUser}id/',
      queryParameters: queryParameters,
    );
  }


  @override
  Future<List<FridgeItem>> getAllFridgeItems(String fridgeId) async {
    final queryParameters = {'fridge_id': fridgeId};
    final response = await _apiService.get(
        '${Endpoints.fridgeService}${Endpoints.fridgeItem}',
        queryParameters: queryParameters
    );
    final List<dynamic> data = response.data;
    return data.map((json) => FridgeItemModel.fromJson(json).toDomain()).toList();
  }

  @override
  Future<FridgeItem> getFridgeItemById(String id) async {
    final response = await _apiService.get('${Endpoints.fridgeItem}/$id');
    return FridgeItemModel.fromJson(response.data).toDomain();
  }

  @override
  Future<FridgeItem> createFridgeItem(String fridgeId, String productId) async {
    final response = await _apiService.post(
        '${Endpoints.fridgeService}${Endpoints.fridgeItem}',
        data: {
          'fridge_id': fridgeId,
          'product_id': productId,
          'initial_amount': {
            'unit': 'g',
            'value': 150,
          },
          'amount': {
            'unit': 'g',
            'value': 150,
          }
        });
    return FridgeItemModel.fromJson(response.data).toDomain();
  }

  @override
  Future<FridgeItem> updateFridgeItem(FridgeItem fridgeItem) async {
    final fridgeItemModel = FridgeItemModel.fromDomain(fridgeItem);
    final response = await _apiService.put('${Endpoints.fridgeService}${Endpoints.fridgeItem}/${fridgeItem.id}', data: fridgeItemModel.toJson());
    return FridgeItemModel.fromJson(response.data).toDomain();
  }

  @override
  Future<void> deleteFridgeItem(String id) async {
    final queryParameters = {'id': id};
    await _apiService.delete(
      '${Endpoints.fridgeService}${Endpoints.fridgeItem}id/',
      queryParameters: queryParameters,
    );
  }
}