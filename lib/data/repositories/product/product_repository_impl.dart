import 'dart:developer';

import 'package:havka/data/models/product/product_model.dart';
import 'package:havka/domain/repositories/product/product_repository.dart';
import 'package:havka/data/api/endpoints.dart';
import 'package:havka/domain/entities/product/product.dart';

import '../../api/api_service.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ApiService _apiService;

  ProductRepositoryImpl({required apiService}) : _apiService = apiService;

  @override
  Future<List<Product>> getAllProducts() async {
    final response = await _apiService.get(Endpoints.productService);
    final List<dynamic> data = response.data;
    return data.map((json) => ProductModel.fromJson(json).toDomain()).toList();
  }

  @override
  Future<Product> getProductById(int id) async {
    final response = await _apiService.get('${Endpoints.productService}$id');
    final data = response.data;
    return ProductModel.fromJson(data).toDomain();
  }

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    final response = await _apiService.get('${Endpoints.products}${Endpoints.productByBarcode}$barcode');
    final data = response.data;
    return ProductModel.fromJson(data).toDomain();
  }

  @override
  Future<List<Product>> getProductsBySearchingRequest(String searchingTerm) async {
    final queryParameters = {'search_text': searchingTerm};
    final response = await _apiService.get(
      '${Endpoints.productService}${Endpoints.productsByRequest}',
      queryParameters: queryParameters,
    );
    final List<dynamic> data = response.data;
    return data.map((json) => ProductModel.fromJson(json).toDomain()).toList();
  }

  @override
  Future<Product> addProduct(Product product) async {
    final productModel = ProductModel.fromDomain(product);
    final response = await _apiService.post(Endpoints.products, data:productModel.toJson());
    return ProductModel.fromJson(response.data).toDomain();
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final queryParameters = {'id': product.id};
    final productModel = ProductModel.fromDomain(product);
    final response = await _apiService.patch(
        '${Endpoints.products}/${product.id}/',
        queryParameters: queryParameters,
        data: productModel.toJson()
    );
    return ProductModel.fromJson(response.data).toDomain();
  }

  @override
  Future<void> deleteProduct(int id) async {
    await _apiService.delete('${Endpoints.products}/$id');
  }
}