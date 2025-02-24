import '../../../domain/entities/product/protein.dart';

class ProteinModel {
  final double? total;

  ProteinModel({
    this.total,
  });

  @override
  String toString() => this.toJson().toString();

  factory ProteinModel.fromJson(Map<String, dynamic> json) => ProteinModel(
    total: json['total'],
  );

  Map<String, dynamic> toJson() => {
    'total': this.total
  };

  Protein toDomain() {
    return Protein(
      total: this.total,
    );
  }

  static ProteinModel fromDomain(Protein protein) {
    return ProteinModel(
      total: protein.total,
    );
  }
}