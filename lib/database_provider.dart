import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static final DatabaseProvider _instance = DatabaseProvider._();
  Database? _database;

  DatabaseProvider._();

  static DatabaseProvider get instance => _instance;

  Future<Database> getDatabase() async {
    _database ??= await _connect();
    return _database!;
  }

  static FutureOr<void> createDatabase(Database database) {
    log("Creating database");
    database.execute('CREATE TABLE IMAGES IF NOT EXISTS ('
        'ID INTEGER NOT NULL PRIMARY KEY, '
        'NAME TEXT NOT NULL, '
        'IMAGE_INDEX TEXT NOT NULL)');
    database.execute('CREATE TABLE TAGS IF NOT EXISTS ('
        'ID INTEGER NOT NULL PRIMARY KEY, '
        'NAME TEXT NOT NULL UNIQUE)');
    database.execute('CREATE TABLE CONNECTIONS IF NOT EXISTS ('
        'IMAGE_ID INTEGER NOT NULL constraint CONNECTIONS_TAGS_fk references TAGS, '
        'TAG_ID INTEGER NOT NULL constraint CONNECTIONS_IMAGES_fk references IMAGES,'
        'CONSTRAINT CONNECTIONS_PK PRIMARY KEY (IMAGE_ID, TAG_ID))');
    database.insert('TAGS', {"ID": 1, "NAME": "Asterix"});
    database.insert('TAGS', {"ID": 2, "NAME": "Obelix"});
    database.insert('TAGS', {"ID": 3, "NAME": "Kerfuś"});
  }

  static FutureOr<void> updateDatabase(Database database, int oldVersion, int newVersion) {
    log("Updating database");
    if (oldVersion < newVersion) {
      database.rawDelete("DELETE FROM IMAGES");
      database.rawDelete("DELETE FROM TAGS");
      createDatabase(database);
    }
  }

  static Future<Database> _connect() async {
    Database database = await databaseFactory.openDatabase("database.sqlite",
        options: OpenDatabaseOptions(
            version: 3,
            onCreate: (Database database, int version) => createDatabase(database),
            onOpen: (Database database) => log("Opening database"),
            onUpgrade: (Database database, int oldVersion, int newVersion) =>
                updateDatabase(database, oldVersion, newVersion)));
    log("Database loaded");
    return database;
  }
}

class BatchManager {
  BatchManager._();

  static Future<void> execute(String script, Database database) async {
    var component = BatchManager._();
    Batch batch = database.batch();
    await component._open(script, batch);
    batch.commit(continueOnError: true);
  }

  void _register(String line, Batch batch) {
    RegExp insertRegex = RegExp(r'INSERT INTO ".*" VALUES(.*)');
    RegExp valReg = RegExp(r'VALUES(.*)');
    if (insertRegex.hasMatch(line)) {
      var match = valReg.firstMatch(line);
      List<dynamic> data = line.substring(match!.start + 7, match.end - 2).replaceAll("'", "").split(",");
      var parsedData = [for (var object in data) _parseString(object)];
      var parsedInsert = line.replaceAll(valReg, "VALUES(${[for (int i = 0; i < data.length; i++) "?"].join(", ")})");
      batch.rawInsert(parsedInsert, parsedData);
    } else {
      batch.execute(line);
    }
  }

  dynamic _parseString(String string) {
    if (string == "NULL") {
      return null;
    }
    return int.tryParse(string) ?? string;
  }

  Future<void> _open(String dbCreateFile, Batch batch) async {
    String dbCreateString = await rootBundle.loadString(dbCreateFile);
    String command = "";
    for (String line in dbCreateString.split("\n")) {
      line = line.trim();
      command = "$command $line";
      if (line != "" && line[line.length - 1] == ";") {
        _register(command.trim(), batch);
        command = "";
      }
    }
  }
}
