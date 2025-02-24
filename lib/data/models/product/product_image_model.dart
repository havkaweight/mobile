import '../../../domain/entities/product/product_image.dart';

class ProductImageModel {
  final String? small;
  final String? original;

  const ProductImageModel({
    this.small,
    this.original,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      small: json['small'].replaceAll('?', '%3F'),
      original: json['original'].replaceAll('?', '%3F'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'small': small,
      'original': original,
    };
  }

  static ProductImageModel fromDomain(ProductImage productImage) {
    return ProductImageModel(
      small: productImage.small,
      original: productImage.original,
    );
  }

  ProductImage toDomain() {
    return ProductImage(
      small: small,
      original: original,
    );
  }
}