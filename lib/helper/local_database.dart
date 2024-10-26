import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer' as developer;

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null)return _database!;
      _database = await _initDB('trivia.db');
      return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE scores (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL,
      score INTEGER NOT NULL,
      uuid TEXT NOT NULL,
      createdTime TEXT NOT NULL
    )
    ''');
  }
  Future<void> insertScore (Map<String, dynamic> score) async {
     final db = await instance.database;
     await db.insert('scores', score);
     developer.log('inserted locally');
     printLocalSavedScores();
  }

  Future<List<Map<String,dynamic>>> getScores() async {
       final db = await instance.database;
       return await db.query('scores');
  }

  Future<void> deleteScores() async {
    final db = await instance.database;
    await db.delete('scores');
    developer.log('deleted locally');
    printLocalSavedScores();

  }
  Future<void> printLocalSavedScores() async {
    List<Map<String,dynamic>> list = await getScores();
    print('list==${list.length}');
    for (var score in list){
      print(score);
    }

  }

}

