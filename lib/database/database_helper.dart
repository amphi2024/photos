import 'dart:io';

import 'package:photos/utils/migration/photos_migration.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/app_storage.dart';
import '../utils/migration/albums_migration.dart';

final databaseHelper = DatabaseHelper.instance;

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    if (Platform.isWindows || Platform.isLinux) {
      final databaseFactory = databaseFactoryFfi;
      final db = await databaseFactory.openDatabase(appStorage.databasePath, options: OpenDatabaseOptions(onCreate: _onCreate, version: 1));
      return db;
    }
    return await openDatabase(
      appStorage.databasePath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> notifySelectedUserChanged() async {
    await _database?.close();
    _database = await _openDatabase();
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute("""
                     CREATE TABLE IF NOT EXISTS photos (
                        id TEXT PRIMARY KEY NOT NULL, 
                        title TEXT NOT NULL,
                        created INTEGER NOT NULL,
                        modified INTEGER NOT NULL,
                        date INTEGER NOT NULL,
                        deleted INTEGER,
                        mime_type TEXT NOT NULL,
                        sha256 TEXT NOT NULL,
                        note TEXT,
                        tags TEXT
                      );
                        """);
    await db.execute("""
                       CREATE TABLE IF NOT EXISTS albums (
                          id TEXT PRIMARY KEY NOT NULL, 
                          title TEXT NOT NULL,
                          created INTEGER NOT NULL,
                          modified INTEGER NOT NULL,
                          deleted INTEGER,
                          photos TEXT NOT NULL,
                          cover_photo_index INTEGER,
                          note TEXT
                        );
                        """);
    await db.execute("""
                     CREATE TABLE IF NOT EXISTS themes (
                        id TEXT PRIMARY KEY NOT NULL,
                        title TEXT NOT NULL,
                        created INTEGER NOT NULL,
                        modified INTEGER NOT NULL,
            
                        background_light INTEGER NOT NULL,
                        text_light INTEGER NOT NULL,
                        accent_light INTEGER NOT NULL,
                        card_light INTEGER NOT NULL,
            
                        background_dark INTEGER NOT NULL,
                        text_dark INTEGER NOT NULL,
                        accent_dark INTEGER NOT NULL,
                        card_dark INTEGER NOT NULL
                      );
                        """);

    await migratePhotos(db);
    await migrateAlbums(db);
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
