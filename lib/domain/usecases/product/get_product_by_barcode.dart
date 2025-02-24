import 'package:havka/data/repositories/product/product_repository_impl.dart';
import 'package:havka/domain/entities/product/product.dart';
import 'package:havka/domain/repositories/product/product_repository.dart';

class GetProductByBarcode {
  final ProductRepository repository;

  GetProductByBarcode(this.repository);

  Future<Product?> execute(String barcode) async {
    return await repository.getProductByBarcode(barcode);
  }
}