import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Database {
  // value will be set later
  var database = null;
  var dbName;
  Database(String dbName) {
    this.dbName = dbName;
  } //class declaration

  initialise(String createQuery) async {
    WidgetsFlutterBinding.ensureInitialized();
    this.database = openDatabase(
      join(await getDatabasesPath(), this.dbName),
      onCreate: (db, version) {
        return db.execute(createQuery);
      },
      version: 1,
    );
  }

  Future<void> insert(String table, Map<String, Object> Info) async {
    final db = await this.database;
    await db.insert(
      table,
      Info,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

class BusDatabase extends Database {
  BusDatabase(String dbName) : super(dbName);

  Future<void> updateBus(int stopCode, int busNumber) async {
    final db = await this.database;

    await db.update(
      'buses',
      {"busNumber": busNumber},
      where: 'stopCode = ?',
      whereArgs: [busNumber],
    );
  }

  Future<void> deleteBus(int stopCode) async {
    final db = await this.database;

    await db.delete(
      'buses',
      where: 'stopCode = ?',
      whereArgs: [stopCode],
    );
  }
}

class RecentSearchesDatabase extends Database {
  var maxStorage;
  var maxSearches;
  RecentSearchesDatabase(String dbName, int maxSearches)
      : this.maxStorage = maxSearches,
        super(dbName);

  Future<void> deleteLastSearch() async {
    final db = await this.database;

    await db.execute(
        "DELETE FROM recentSearches WHERE id = (SELECT id FROM recentSearches ORDERBY id ASC LIMIT 1)");
  }

  Future<void> insertSearch(int stopCode) async {
    final db = await this.database;

    int searches = await db.execute("SELECT COUNT * FROM recentSearches");

    await super.insert("recentSearches", {"stopCode": stopCode});

    if (searches >= this.maxSearches) {
      await this.deleteLastSearch();
    }
  }
}

initDB() async {
  var busdb = new BusDatabase("bus_info.db");
  await busdb.initialise(
      "CREATE TABLE buses(stopCode INTEGER PRIMARY KEY, busNumber INTEGER, UNIQUE(stopCode, busNumber))");

  // do stuff with db here
  var recentSearchesdb = new RecentSearchesDatabase("recent_searches.db", 10);
  await recentSearchesdb.initialise(
      "CREATE TABLE recentSearches(id INTEGER PRIMARY KEY AUTOINCREMENT, stopCode INTEGER UNIQUE(stopCode))");

  // do stuff with recentsearch db here
}
