import '../../entities/product/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getAllProducts();
  Future<Product> getProductById(int id);
  Future<Product?> getProductByBarcode(String barcode);
  Future<List<Product>> getProductsBySearchingRequest(String searchingTerm);
  Future<Product> addProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(int id);
}