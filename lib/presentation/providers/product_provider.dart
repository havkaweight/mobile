import 'package:flutter/material.dart';
import '../../domain/repositories/product/product_repository.dart';
import '../../domain/entities/product/product.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository;

  List<Product> _products = [];
  Product? _barcodeProduct;

  bool _isLoading = false;
  String? _errorMessage = null;

  ProductProvider({required ProductRepository repository}) : _repository = repository;

  List<Product> get products => _products;
  Product? get barcodeProduct => _barcodeProduct;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await _repository.getAllProducts();
    } catch (e) {
      throw('Failed to fetch products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSearchedProducts(String searchingTerm) async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await _repository.getProductsBySearchingRequest(searchingTerm);
    } catch (e) {
      throw('Failed to fetch searched products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product newProduct) async {
    try {
      final addedProduct = await _repository.addProduct(newProduct);
      _products.add(addedProduct);
      notifyListeners();
    } catch (e) {
      throw('Failed to add product: $e');
    }
  }

  Future<void> fetchProductByBarcode(String barcode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedProduct = await _repository.getProductByBarcode(barcode);
      _barcodeProduct = fetchedProduct;
    } catch (e) {
      _errorMessage = 'Failed to fetch product by barcode: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedProduct() {
    _barcodeProduct = null;
    notifyListeners();
  }
}
