import '../../core/errors/app_exceptions.dart';
import 'json_readers.dart';

/// مراحل التوصيل بالترتيب.
enum DeliveryStage {
  received('received'),
  preparing('preparing'),

  /// مرحلة ملغاة: تُقرأ ولا تُعرض.
  pickedUp('picked_up'),
  inTransit('in_transit'),
  delivered('delivered'),
  cancelled('cancelled');

  const DeliveryStage(this.key);
  final String key;

  /// المراحل المعروضة.
  static const List<DeliveryStage> flow = [
    received,
    preparing,
    inTransit,
    delivered,
  ];

  static DeliveryStage fromKey(String key) => values.firstWhere(
    (s) => s.key == key,
    orElse: () => throw ParsingException('Unknown stage "$key"'),
  );
}

class TimelineStageModel {
  const TimelineStageModel({
    required this.stage,
    required this.labelAr,
    required this.isCompleted,
    this.timestamp,
  });

  final DeliveryStage stage;
  final String labelAr;
  final DateTime? timestamp;
  final bool isCompleted;

  factory TimelineStageModel.fromJson(Map<String, dynamic> json) {
    try {
      return TimelineStageModel(
        stage: DeliveryStage.fromKey(json['stage'] as String),
        labelAr: json['label_ar'] as String,
        timestamp: readDateOrNull(json['timestamp']),
        isCompleted: json['is_completed'] as bool? ?? false,
      );
    } on TypeError catch (e) {
      throw ParsingException('Invalid timeline stage: $json', e);
    } on FormatException catch (e) {
      throw ParsingException('Invalid timeline date: $json', e);
    }
  }

  Map<String, dynamic> toJson() => {
    'stage': stage.key,
    'label_ar': labelAr,
    'timestamp': writeDateOrNull(timestamp),
    'is_completed': isCompleted,
  };

  TimelineStageModel copyWith({DateTime? timestamp, bool? isCompleted}) =>
      TimelineStageModel(
        stage: stage,
        labelAr: labelAr,
        timestamp: timestamp ?? this.timestamp,
        isCompleted: isCompleted ?? this.isCompleted,
      );
}
