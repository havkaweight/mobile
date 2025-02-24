import 'package:havka/data/repositories/product/product_repository_impl.dart';
import 'package:havka/domain/entities/product/product.dart';
import 'package:havka/domain/repositories/product/product_repository.dart';

class UpdateProduct {
  final ProductRepository repository;

  UpdateProduct(this.repository);

  Future<void> execute(Product product) async {
    if (product.name != "") {
      throw Exception("Product name cannot be empty");
    }
    await repository.updateProduct(product);
  }
}