import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class busAppDB {
  static final busAppDB instance = busAppDB._initDB();
  static Database? _database;

  busAppDB._initDB();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('main.DB');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    db.execute('''
    CREATE TABLE appDB(starredStopCode STRING, starredBusNumber STRING, scheduledTime STRING, UNIQUE(starredStopCode, starredBusNumber))
    ''');
  }

  Future createStarred(String stopCode, String busNumber) async {
    final db = await instance.database;

    await db.insert(
        'appDB', {"starredStopCode": stopCode, "starredBusNumber": busNumber},
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future queryStarred(String stopCode, String busNumber) async {
    //returns a list
    final targetDB = await instance.database;

    return await targetDB.query(
      'appDB',
      columns: ['starredStopCode', 'starredBusNumber'],
      where:
          'starredStopCode = "$stopCode" AND starredBusNumber = "$busNumber"',
    );
  }

  Future<int> deleteStarred(String stopCode, String busNumber) async {
    //returns number of rows affected
    final targetDB = await instance.database;
    return await targetDB.delete('appDB',
        where:
            'starredStopCode = "$stopCode" AND starredBusNumber = "$busNumber"');
  }

  Future addOrUpdateSchedule(
      String stopCode, String busNumber, String scheduledTime) async {
    var test = await queryStarred(stopCode, busNumber);
    if (test.length == 0) {
      await createStarred(stopCode, busNumber);
    }

    var targetDB = await instance.database;
    return await targetDB.update('appDB', {"scheduledTime": scheduledTime},
        where: 'starredStopCode = $stopCode AND starredBusNumber = $busNumber');
  }

  Future deleteSchedule(String stopCode, String busNumber) async {
    var targetDB = await instance.database;
    return await targetDB.update('appDB', {"scheduledTime": null},
        where: 'starredStopCode = $stopCode AND starredBusNumber = $busNumber');
  }

  Future<void> close() async {
    final targetDB = await instance.database;
    targetDB.close();
  }

  Future readAll() async {
    final targetDB = await instance.database;
    return await targetDB.query(
      'appDB',
      columns: ['starredStopCode', 'starredBusNumber'],
    );
  }

  Future deleteAll() async {
    final targetDB = await instance.database;
    return await targetDB.delete('appDB');
  }
}

class recentSearchesDB {
  static final recentSearchesDB instance = recentSearchesDB._initDB();
  static Database? _database;

  recentSearchesDB._initDB();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('recent.DB');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    db.execute('''
    CREATE TABLE recentSearches(id INTEGER PRIMARY KEY AUTOINCREMENT, stopCode INTEGER UNIQUE(stopCode))
    ''');
  }

  Future deleteAll() async {
    final targetDB = await instance.database;
    return await targetDB.delete('recentSearches');
  }

  Future<void> deleteLastSearched() async {
    //returns number of rows affected
    final targetDB = await instance.database;
    await targetDB.execute(
        "DELETE FROM recentSearches WHERE id = (SELECT id FROM recentSearches ORDERBY id ASC LIMIT 1)");
    return;
  }

  Future<int> deleteOne(String stopCode) async {
    //returns number of rows affected
    final targetDB = await instance.database;
    return await targetDB.delete('recentSearches',
        where: 'stopCode = "$stopCode"');
  }

  Future addRecent(String stopCode) async {
    final targetDB = await instance.database;
    await targetDB.insert("recentSearches", {"stopCode": stopCode});
  }

  Future getAllRecent() async {
    final targetDB = await instance.database;
    return await targetDB.query(
      'recentSearches',
      columns: ['stopCode'],
    );
  }
}
