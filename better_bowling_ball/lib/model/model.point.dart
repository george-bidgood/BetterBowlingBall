const String tablePoints = 'points';

class PointFields {
  static final List<String> values = [
    /// Add all fields
    id, bowlId, sequenceId, xPos, yPos, time
  ];

  static const String id = '_id';
  static const String bowlId = 'bowlId';
  static const String sequenceId = 'sequenceId';
  static const String xPos = 'xPos';
  static const String yPos = 'yPos';
  static const String time = 'time';
}

class Point {
  final int? id;
  final int bowlId;
  final int sequenceId;
  final double xPos;
  final double yPos;
  final DateTime time;

  const Point({
    this.id,
    required this.bowlId,
    required this.sequenceId,
    required this.xPos,
    required this.yPos,
    required this.time,
  });

  Point copy({
    int? id,
    int? bowlId,
    int? sequenceId,
    double? xPos,
    double? yPos,
    DateTime? time,
  }) =>
      Point(
        id: id ?? this.id,
        bowlId: bowlId ?? this.bowlId,
        sequenceId: sequenceId ?? this.sequenceId,
        xPos: xPos ?? this.xPos,
        yPos: yPos ?? this.yPos,
        time: time ?? this.time,
      );

  static Point fromJson(Map<String, Object?> json) => Point(
        id: json[PointFields.id] as int?,
        bowlId: json[PointFields.bowlId] as int,
        sequenceId: json[PointFields.sequenceId] as int,
        xPos: json[PointFields.xPos] as double,
        yPos: json[PointFields.yPos] as double,
        time: DateTime.parse(json[PointFields.time] as String),
      );

  Map<String, Object?> toJson() => {
        PointFields.id: id,
        PointFields.bowlId: bowlId,
        PointFields.sequenceId: sequenceId,
        PointFields.xPos: xPos,
        PointFields.yPos: yPos,
        PointFields.time: time.toIso8601String(),
      };
}
