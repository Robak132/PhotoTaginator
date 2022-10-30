import 'dart:async';
import 'dart:developer';

import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static final DatabaseProvider _instance = DatabaseProvider._();
  Database? _database;

  DatabaseProvider._();

  factory DatabaseProvider() {
    return _instance;
  }
  static DatabaseProvider get instance => _instance;

  Future<Database> getDatabase() async {
    _database ??= await _connect();
    return _database!;
  }

  static FutureOr<void> createDatabase(Database database) {
    log("Creating database");
    database.execute("DELETE FROM IMAGES");
    database.execute("DELETE FROM TAGS");
    database.execute("DELETE FROM CONNECTIONS");
    database.execute("DROP TABLE IMAGES");
    database.execute("DROP TABLE TAGS");
    database.execute("DROP TABLE CONNECTIONS");
    database.execute('CREATE TABLE IF NOT EXISTS IMAGES (ID INTEGER NOT NULL PRIMARY KEY)');
    database.execute('CREATE TABLE IF NOT EXISTS TAGS ('
        'ID INTEGER NOT NULL PRIMARY KEY, '
        'NAME TEXT NOT NULL UNIQUE)');
    database.execute('CREATE TABLE IF NOT EXISTS CONNECTIONS ('
        'IMAGE_ID INTEGER NOT NULL constraint CONNECTIONS_TAGS_fk references TAGS, '
        'TAG_ID INTEGER NOT NULL constraint CONNECTIONS_IMAGES_fk references IMAGES,'
        'CONSTRAINT CONNECTIONS_PK PRIMARY KEY (IMAGE_ID, TAG_ID))');
    database.insert('TAGS', {"ID": 1, "NAME": "Asterix"});
    database.insert('TAGS', {"ID": 2, "NAME": "Obelix"});
    database.insert('TAGS', {"ID": 3, "NAME": "Nowy"});
    database.insert('CONNECTIONS', {"IMAGE_ID": '32013', "TAG_ID": 1});
    log("Database created");
  }

  static FutureOr<void> updateDatabase(Database database, int oldVersion, int newVersion) {
    log("Updating database...");
    if (oldVersion < newVersion) {
      createDatabase(database);
    }
  }

  static Future<Database> _connect() async {
    Database database = await databaseFactory.openDatabase("database.sqlite",
        options: OpenDatabaseOptions(
            version: 9,
            onCreate: (Database database, int version) => createDatabase(database),
            onOpen: (Database database) => log("Opening database"),
            onUpgrade: (Database database, int oldVersion, int newVersion) =>
                updateDatabase(database, oldVersion, newVersion)));
    log("Database loaded");
    return database;
  }
}