import 'dart:developer';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:better_bowling_ball/model/model.bowl.dart';
import 'package:better_bowling_ball/model/model.game.dart';
import 'package:better_bowling_ball/model/model.point.dart';

// Class responsible for handling all database operations
class BowlingDatabase {
  static final BowlingDatabase instance = BowlingDatabase._init();

  static Database? _database;

  BowlingDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('notes.db');
    return _database!;
  }

  // Initialize the 'notes' sqlite databsae
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Create the db if it does not exist
  Future _createDB(Database db, int version) async {
    // Define types / constraints
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const fkType = 'INTEGER NOT NULL';
    const decimalType = 'REAL NOT NULL';
    const textType = 'TEXT NOT NULL';
    //const boolType = 'BOOLEAN NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    // games
    await db.execute('''
      CREATE TABLE $tableGames ( 
        ${GameFields.id} $idType, 
        ${GameFields.name} $textType,
        ${GameFields.notes} $textType,
        ${GameFields.date} $textType )
    ''');

    // bowls
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
        ${BowlFields.timestamp} $textType )
    ''');

    // points
    await db.execute('''
      CREATE TABLE $tablePoints ( 
        ${PointFields.id} $idType, 
        ${PointFields.bowlId} $fkType,
        ${PointFields.sequenceId} $fkType,
        ${PointFields.xPos} $decimalType,
        ${PointFields.yPos} $decimalType,
        ${PointFields.time} $textType )
    ''');
  }

  // ------- WRITE --------

  Future<Game> createGame(Game game) async {
    final db = await instance.database;
    final id = await db.insert(tableGames, game.toJson());
    log("Created game ${game.copy(id: id).toJson().toString()}");
    return game.copy(id: id);
  }

  Future<Bowl> createBowl(Bowl bowl) async {
    final db = await instance.database;
    final id = await db.insert(tableBowls, bowl.toJson());
    log("created bowl: ${bowl.copy(id: id).toJson()}");
    return bowl.copy(id: id);
  }

  Future<Point> createPoint(Point point) async {
    final db = await instance.database;
    final id = await db.insert(tableBowls, point.toJson());
    return point.copy(id: id);
  }

  deleteAllGames() async {
    final db = await instance.database;
    await db.delete(tableGames);
  }

  Future<int> deleteGame(int id) async {
    final db = await instance.database;

    await db.delete(
      tableGames,
      where: '${GameFields.id} = ?',
      whereArgs: [id],
    );

    return await db.delete(
      tableBowls,
      where: '${BowlFields.gameId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> update(Bowl bowl) async {
    final db = await instance.database;

    return db.update(
      tableGames,
      bowl.toJson(),
      where: '${BowlFields.id} = ?',
      whereArgs: [bowl.id],
    );
  }

  // ------- READ --------

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

  Future<Bowl> readBowl(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableBowls,
      columns: BowlFields.values,
      where: '${BowlFields.gameId} = ?',
      whereArgs: [id],
      orderBy: '${BowlFields.id} DSC',
      limit: 1,
      offset: id
    );

    if (maps.isNotEmpty) {
      return Bowl.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Point>> readPoints(int id) async {
    final db = await instance.database;

    final result = await db.query(tablePoints,
        columns: PointFields.values,
        where: '${PointFields.bowlId} = ?',
        whereArgs: [id],
        orderBy: '${PointFields.sequenceId} ASC');

    return result.map((json) => Point.fromJson(json)).toList();
  }

  Future<List<Game>> readAllGames() async {
    final db = await instance.database;

    final result = await db.rawQuery('''
      SELECT * 
      FROM $tableGames 
      ORDER BY ${GameFields.date} DESC
    ''');

    return result.map((json) => Game.fromJson(json)).toList();
  }

  Future<List<Bowl>> readBowls(int id) async {
    final db = await instance.database;

    final result = await db.query(tableBowls,
        columns: BowlFields.values,
        where: '${BowlFields.gameId} = ?',
        whereArgs: [id],
        orderBy: '${BowlFields.id} ASC');

    return result.map((json) => Bowl.fromJson(json)).toList();
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
