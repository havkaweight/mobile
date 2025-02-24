import 'package:havka/data/repositories/product/product_repository_impl.dart';
import 'package:havka/domain/entities/product/product.dart';
import 'package:havka/domain/repositories/product/product_repository.dart';

class GetAllProducts {
  final ProductRepository repository;

  GetAllProducts(this.repository);

  Future<List<Product>> execute() async {
    final products = await repository.getAllProducts();
    return products.toList();
  }
}