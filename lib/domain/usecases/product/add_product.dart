import 'package:havka/domain/entities/product/product.dart';
import 'package:havka/domain/repositories/product/product_repository.dart';

class AddProduct {
  final ProductRepository repository;

  AddProduct(this.repository);

  Future<void> execute(Product product) async {
    if (product.name != "") {
      throw Exception("Product name cannot be empty");
    }
    await repository.addProduct(product);
  }
}