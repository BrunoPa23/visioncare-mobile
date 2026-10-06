import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:visioncare_app/models/medicines.dart';

class DatabaseHelper {
    static Database? _database;
    static final DatabaseHelper _instance = DatabaseHelper._init();

    DatabaseHelper._init();

    Future<Database> get database async {
        if (_database != null) return _database!;
        _database = await _initDB('visioncare.db');
        return _database!;
    }

    Future<Database> _initDB(String filePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, filePath);
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medicine (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT   NOT NULL,
        concept TEXT   NULL,
        side_effects TEXT   NULL,
        warnings TEXT   NULL,
        instruccions TEXT  NULL,
        isDeleted INTEGER  NOT NULL
      )
    ''');
  }

  Future<void> close() async {
    final db = await _instance.database;
    db.close();
  }

  Future<int> insertMedicine(Map<String, dynamic> medicine) async {
    final db = await _instance.database;
    return await db.insert('medicine', medicine);
  }

  Future<List<Medicines>> getMedicines() async {
    final db = await _instance.database;
    final List<Map<String, dynamic>> maps = await db.query('medicines');
    return List.generate(maps.length, (i) {
      return Medicines.fromMap(maps[i]);
    });
  }
}