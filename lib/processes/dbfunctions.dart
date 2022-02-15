import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Database {
  String dbName = 'bus_info.db';
  var database = null;

  initialise() async {
    WidgetsFlutterBinding.ensureInitialized();
    this.database = openDatabase(
      join(await getDatabasesPath(), dbName),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE buses(stopCode STRING PRIMARY KEY, busNumber STRING, UNIQUE(stopCode, busNumber))',
        );
      },
      version: 1,
    );

    Future<void> insertBus(Map<String, int> Info) async {
      final db = await this.database;
      await db.insert(
        'buses',
        Info,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

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

  void dbFunction() async {
    var db = new Database();
    await db.initialise();
    // do stuff with db here
  }
}
