import 'package:havka/data/repositories/product/product_repository_impl.dart';
import 'package:havka/domain/entities/product/product.dart';
import 'package:havka/domain/repositories/product/product_repository.dart';

class DeleteProduct {
  final ProductRepository repository;

  DeleteProduct(this.repository);

  Future<void> execute(int productId) async {
    await repository.deleteProduct(productId);
  }
}