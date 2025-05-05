import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_application_3/two_factor_code.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final _databaseName = "TwoFactorAuth.db";
  static final _databaseVersion = 1;

  static final table = 'codes';
  
  static final columnId = 'id';
  static final columnColor = 'color';
  static final columnWebsite = 'website';
  static final columnEmail = 'email';
  static final columnSecret = 'secret';

  static Database? _database;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    // Initialize FFI database factory for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      databaseFactory = databaseFactoryFfi;
    }
    
    String path;
    if (Platform.isAndroid || Platform.isIOS) {
      path = join(await getDatabasesPath(), _databaseName);
    } else {
      // For desktop platforms
      final documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, _databaseName);
    }

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnColor INTEGER NOT NULL,
        $columnWebsite TEXT NOT NULL,
        $columnEmail TEXT NOT NULL,
        $columnSecret TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertCode(TwoFactorCode code) async {
    Database db = await instance.database;
    return await db.insert(table, code.toMap());
  }

  Future<List<TwoFactorCode>> getAllCodes() async {
    Database db = await instance.database;
    List<Map> maps = await db.query(table);
    return maps.map((map) => TwoFactorCode.fromMap(map)).toList();
  }

  Future<int> updateCode(TwoFactorCode code) async {
    Database db = await instance.database;
    return await db.update(table, code.toMap(),
        where: '$columnId = ?', whereArgs: [code.id]);
  }

  Future<int> deleteCode(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}