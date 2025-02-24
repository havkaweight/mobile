import 'package:havka/data/repositories/product/product_repository_impl.dart';
import 'package:havka/domain/entities/product/product.dart';
import 'package:havka/domain/repositories/product/product_repository.dart';

class GetProductsBySearchingRequest {
  final ProductRepository repository;

  GetProductsBySearchingRequest(this.repository);

  Future<List<Product>> execute(String searchingTerm) async {
    final products = await repository.getProductsBySearchingRequest(searchingTerm);
    return products.toList();
  }
}