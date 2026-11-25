import '../../core/errors/app_exceptions.dart';
import 'json_readers.dart';

class OrderItemModel {
  const OrderItemModel({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.image,
  });

  final String name;
  final int quantity;
  final double unitPrice;

  /// صورة الطبق (مسار أو رابط).
  final String? image;

  double get subtotal => quantity * unitPrice;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    try {
      return OrderItemModel(
        name: json['name'] as String,
        quantity: (json['quantity'] as num).toInt(),
        unitPrice: readDouble(json['unit_price']),
        image: json['image'] as String?,
      );
    } on TypeError catch (e) {
      throw ParsingException('Invalid order item: $json', e);
    }
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
    'unit_price': unitPrice,
    if (image != null) 'image': image,
  };
}
