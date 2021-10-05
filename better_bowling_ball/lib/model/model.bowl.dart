import 'dart:ffi';

final String tableBowls = 'bowls';

class BowlFields {
  static final List<String> values = [
    /// Add all fields
    id, gameId, speed, rpm, xRotation, yRotation, zRotation, footPlacement, pinHit, timestamp
  ];

  static final String id = '_id';
  static final String gameId = '_game_id';
  static final String speed = 'speed';
  static final String rpm = 'rpm';
  static final String xRotation = 'xRotation';
  static final String yRotation = 'yRotation';
  static final String zRotation = 'zRotation';
  static final String footPlacement = 'footPlacement';
  static final String pinHit = 'pinHit';
  static final String timestamp = 'timestamp';
}


class Bowl {
  final int? id;
  final int? gamedID;
  final double speed;
  final double rpm;
  final double xRotation;
  final double yRotation;
  final double zRotation;
  final String footPlacement;
  final int pinHit;
  final DateTime timestamp;


  const Bowl({
    this.id,
    this.gamedID,
    required this.speed,
    required this.rpm,
    required this.xRotation,
    required this.yRotation,
    required this.zRotation,
    required this.footPlacement,
    required this.pinHit,
    required this.timestamp,

  });

  Bowl copy({
    int? id,
    int? gameId,
    double? speed,
    double? rpm,
    double? xRotation,
    double? yRotation,
    double? zRotation,
    String? footPlacement,
    int? pinHit,
    DateTime? timestamp,
  }) =>
      Bowl(
        id: id ?? this.id,
        gamedID: gamedID ?? this.gamedID,
        speed: speed ?? this.speed,
        rpm: rpm ?? this.rpm,
        xRotation: xRotation ?? this.xRotation,
        yRotation: yRotation ?? this.yRotation,
        zRotation: zRotation ?? this.zRotation,
        footPlacement: footPlacement ?? this.footPlacement,
        pinHit: pinHit ?? this.pinHit,
        timestamp: timestamp ?? this.timestamp
      );

  static Bowl fromJson(Map<String, Object?> json) => Bowl(
    id: json[BowlFields.id] as int?,
    gamedID: json[BowlFields.gameId] as int?,
    speed: json[BowlFields.speed] as double,
    rpm: json[BowlFields.rpm] as double,
    xRotation: json[BowlFields.xRotation] as double,
    yRotation: json[BowlFields.yRotation] as double,
    zRotation: json[BowlFields.zRotation] as double,
    footPlacement: json[BowlFields.footPlacement] as String,
    pinHit: json[BowlFields.pinHit] as int,
    timestamp: json[BowlFields.timestamp] as DateTime
  );

  Map<String, Object?> toJson() => {
    BowlFields.id: id,
    BowlFields.gameId: gamedID,
    BowlFields.speed: speed,
    BowlFields.rpm: rpm,
    BowlFields.xRotation: xRotation,
    BowlFields.yRotation: yRotation,
    BowlFields.xRotation: xRotation,
    BowlFields.footPlacement: footPlacement,
    BowlFields.pinHit: timestamp
  };
}
