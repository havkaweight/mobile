import '../../../domain/entities/profile/height.dart';
import '../../../domain/entities/profile/weight.dart';

class BodyStats {
  Height? height;
  Weight? weight;

  BodyStats({
    this.height,
    this.weight,
  });
}