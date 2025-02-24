import '../product/serving.dart';

class ConsumedAmount {
  final Serving serving;
  final double value;

  const ConsumedAmount({
    required this.serving,
    required this.value,
  });
}