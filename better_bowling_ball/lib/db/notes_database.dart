import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_database_example/model/model.bowl.dart';
import 'package:sqflite_database_example/model/model.game.dart';
import 'package:sqflite_database_example/model/model.point.dart';
import 'package:sqflite_database_example/model/note.dart';

class NotesDatabase {
  static final NotesDatabase instance = NotesDatabase._init();

  static Database? _database;

  NotesDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final fkType = 'INTEGER NOT NULL';
    final decimalType = 'REAL NOT NULL';
    final textType = 'TEXT NOT NULL';
    final boolType = 'BOOLEAN NOT NULL';
    final integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE $tableGames ( 
  ${GameFields.id} $idType, 
  ${GameFields.name} $textType,
  ${GameFields.notes} $textType,
  ${GameFields.date} $textType
  )
''');

    await db.execute('''
CREATE TABLE $tableNotes ( 
  ${NoteFields.id} $idType, 
  ${NoteFields.isImportant} $boolType,
  ${NoteFields.number} $integerType,
  ${NoteFields.title} $textType,
  ${NoteFields.description} $textType,
  ${NoteFields.time} $textType
  )
''');

    await db.execute('''
CREATE TABLE $tableBowls ( 
  ${BowlFields.id} $idType, 
  ${BowlFields.gameId} $fkType,
  ${BowlFields.speed} $decimalType,
  ${BowlFields.rpm} $decimalType,
  ${BowlFields.xRotation} $decimalType,
  ${BowlFields.yRotation} $decimalType,
  ${BowlFields.zRotation} $decimalType,
  ${BowlFields.footPlacement} $textType,
  ${BowlFields.pinHit} $integerType,
  ${BowlFields.timestamp} $textType
  )
''');

    await db.execute('''
CREATE TABLE $tablePoints ( 
  ${PointFields.id} $idType, 
  ${PointFields.bowlId} $fkType,
  ${PointFields.sequenceId} $fkType,
  ${PointFields.xPos} $decimalType,
  ${PointFields.yPos} $decimalType,
  ${PointFields.time} $textType
  )
''');
  }

  Future<Note> createNote(Note note) async {
    final db = await instance.database;

    // final json = note.toJson();
    // final columns =
    //     '${NoteFields.title}, ${NoteFields.description}, ${NoteFields.time}';
    // final values =
    //     '${json[NoteFields.title]}, ${json[NoteFields.description]}, ${json[NoteFields.time]}';
    // final id = await db
    //     .rawInsert('INSERT INTO table_name ($columns) VALUES ($values)');

    final id = await db.insert(tableNotes, note.toJson());
    return note.copy(id: id);
  }

  Future<Game> createGame(Game game) async {
    final db = await instance.database;
    final id = await db.insert(tableGames, game.toJson());
    return game.copy(id: id);
  }

  Future<Bowl> createBowl(Bowl bowl) async {
    final db = await instance.database;
    final id = await db.insert(tableBowls, bowl.toJson());
    return bowl.copy(id: id);
  }

  Future<Point> createPoint(Point point) async {
    final db = await instance.database;
    final id = await db.insert(tableBowls, point.toJson());
    return point.copy(id: id);
  }

  // Future<Point> createPoints(List<Point> points) async {
  //   final db = await instance.database;
  //   final id = await db.insert(tableBowls, points.toJson());
  //   return points[0].copy(id: id);
  // }

  Future<Note> readNote(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableNotes,
      columns: NoteFields.values,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Note.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<Game> readGame(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableGames,
      columns: GameFields.values,
      where: '${GameFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Game.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<Game> readBowl(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableGames,
      columns: GameFields.values,
      where: '${GameFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Game.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Point>> readPoints(int id) async {
    final db = await instance.database;

    final result = await db.query(
      tablePoints,
      columns: PointFields.values,
      where: '${PointFields.bowlId} = ?',
      whereArgs: [id],
      orderBy: '${PointFields.sequenceId} ASC'
    );

    return result.map((json) => Point.fromJson(json)).toList();
  }

  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;

    final orderBy = '${NoteFields.time} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.query(tableNotes, orderBy: orderBy);

    return result.map((json) => Note.fromJson(json)).toList();
  }

  Future<int> update(Note note) async {
    final db = await instance.database;

    return db.update(
      tableNotes,
      note.toJson(),
      where: '${NoteFields.id} = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableNotes,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
