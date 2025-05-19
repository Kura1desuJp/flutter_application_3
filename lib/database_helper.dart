import 'dart:io';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_application_3/two_factor_code.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

class DatabaseHelper {
  static final _databaseName = "TwoFactorAuth.db";
  static final _databaseVersion = 1;

  // Таблиці для зберігання двофакторних кодів та користувачів
  static final table = 'codes';
  static final userTable = 'users'; // Таблиця для користувачів
  
  // Колонки для таблиці двофакторних кодів
  static final columnId = 'id';
  static final columnColor = 'color';
  static final columnWebsite = 'website';
  static final columnEmail = 'email';
  static final columnSecret = 'secret';

  // Колонки для таблиці користувачів
  static final columnUserId = 'id';
  static final columnUserEmail = 'email';
  static final columnUserPassword = 'password'; // Пароль для користувача

  static sql.Database? _database;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<sql.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

 Future<sql.Database> _initDatabase() async {
    String path;

    if (Platform.isAndroid || Platform.isIOS) {
      // Mobile platforms: Use the default database path
      path = join(await sql.getDatabasesPath(), _databaseName);
    } else {
      // Desktop platforms: Initialize FFI and set the database path
      final documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, _databaseName);
      // Initialize FFI
      ffi.sqfliteFfiInit();
      // Set the database factory to use FFI
      sql.databaseFactory = ffi.databaseFactoryFfi;
    }

    return await sql.openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }


  Future _onCreate(sql.Database db, int version) async {
    // Створення таблиці для двофакторних кодів
    await db.execute(''' 
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnColor INTEGER NOT NULL,
        $columnWebsite TEXT NOT NULL,
        $columnEmail TEXT NOT NULL,
        $columnSecret TEXT NOT NULL
      )
    ''');

    // Створення таблиці для користувачів
    await db.execute('''
      CREATE TABLE $userTable (
        $columnUserId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnUserEmail TEXT NOT NULL,
        $columnUserPassword TEXT NOT NULL
      )
    ''');
  }

  // Додаємо користувача в базу даних
  Future<void> insertUser(String email, String password) async {
    sql.Database db = await instance.database;
    await db.insert(userTable, {
      columnUserEmail: email,
      columnUserPassword: password, // Зберігаємо пароль
    });
  }

  // Перевірка, чи є користувач з таким емейлом і паролем
  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    sql.Database db = await instance.database;
    final result = await db.query(
      userTable,
      where: '$columnUserEmail = ? AND $columnUserPassword = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Методи для роботи з двофакторними кодами
  Future<int> insertCode(TwoFactorCode code) async {
    sql.Database db = await instance.database;
    return await db.insert(table, code.toMap());
  }

  Future<List<TwoFactorCode>> getAllCodes() async {
    sql.Database db = await instance.database;
    List<Map> maps = await db.query(table);
    return maps.map((map) => TwoFactorCode.fromMap(map)).toList();
  }

  Future<int> updateCode(TwoFactorCode code) async {
    sql.Database db = await instance.database;
    return await db.update(table, code.toMap(),
        where: '$columnId = ?', whereArgs: [code.id]);
  }

  Future<int> deleteCode(int id) async {
    sql.Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
