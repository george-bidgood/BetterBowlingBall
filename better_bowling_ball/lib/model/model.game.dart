final String tableGames = 'games';

class GameFields {
  static final List<String> values = [
    /// Add all fields
    id, name, notes, date
  ];

  static final String id = '_id';
  static final String name = 'name';
  static final String notes = 'notes';
  static final String date = 'date';
}

class Game {
  final int? id;
  final String name;
  final String notes;
  final DateTime date;

  const Game(
      {this.id, required this.name, required this.notes, required this.date});

  Game copy({
    int? id,
    String? name,
    String? notes,
    DateTime? date,
  }) =>
      Game(
          id: id ?? this.id,
          name: name ?? this.name,
          notes: notes ?? this.notes,
          date: date ?? this.date);

  static Game fromJson(Map<String, Object?> json) => Game(
        id: json[GameFields.id] as int?,
        name: json[GameFields.name] as String,
        notes: json[GameFields.notes] as String,
        date: DateTime.parse(json[GameFields.date] as String),
      );

  Map<String, Object?> toJson() => {
        GameFields.id: id,
        GameFields.name: name,
        GameFields.notes: notes,
        GameFields.date: date.toIso8601String(),
      };
}
