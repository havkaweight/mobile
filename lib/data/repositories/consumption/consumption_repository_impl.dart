import 'package:havka/data/models/consumption/user_consumption_item_model.dart';
import 'package:havka/domain/entities/consumption/user_consumption_item.dart';
import 'package:havka/data/api/endpoints.dart';
import '../../../domain/entities/product/product.dart';
import '../../../domain/repositories/consumption/consumption_repository.dart';
import '../../api/api_service.dart';

class ConsumptionRepositoryImpl implements ConsumptionRepository {
  final ApiService _apiService;

  ConsumptionRepositoryImpl({required apiService}) : _apiService = apiService;

  @override
  Future<List<UserConsumptionItem>> getConsumptionItems() async {
    final queryParameters = {'limit': 1000};
    final response = await _apiService.get(
      '${Endpoints.consumptionService}${Endpoints.consumptionUser}',
      queryParameters: queryParameters,
    );
    final List<dynamic> data = response.data;
    return data.map((json) => UserConsumptionItemModel.fromJson(json).toDomain()).toList();
  }

  @override
  Future<UserConsumptionItem> getConsumptionItemById(String id) async {
    final response = await _apiService.get('${Endpoints.consumptionService}/$id');
    final data = response.data;
    return UserConsumptionItemModel.fromJson(data).toDomain();
  }

  @override
  Future<List<UserConsumptionItem>> getConsumptionItemsByProduct(Product product) async {
    final queryParameters = {'product_id': product.id};
    final response = await _apiService.get(
      '${Endpoints.consumptionService}${Endpoints.consumptionUser}',
      queryParameters: queryParameters,
    );
    final List<dynamic> data = response.data;
    return data.map((json) => UserConsumptionItemModel.fromJson(json).toDomain()).toList();
  }

  @override
  Future<UserConsumptionItem> addConsumptionItem(UserConsumptionItem userConsumptionItem) async {
    final response = await _apiService.post(
        '${Endpoints.consumptionService}${Endpoints.consumptionUser}',
        data: UserConsumptionItemModel.fromDomain(userConsumptionItem).toJson(),
    );
    print(response.data);
    return UserConsumptionItemModel.fromJson(response.data).toDomain();
  }

  @override
  Future<UserConsumptionItem> updateConsumptionItem(UserConsumptionItem userConsumptionItem) async {
    final userConsumptionItemModel = UserConsumptionItemModel.fromDomain(userConsumptionItem);
    final response = await _apiService.patch('${Endpoints.consumptionService}/${userConsumptionItem.id}', data: userConsumptionItemModel.toJson());
    return UserConsumptionItemModel.fromJson(response.data).toDomain();
  }

  @override
  Future<void> deleteConsumptionItem(String id) async {
    final queryParameters = {'id': id};
    await _apiService.delete(
      '${Endpoints.consumptionService}${Endpoints.consumptionUser}id/',
      queryParameters: queryParameters,
    );
  }
}