import 'package:sqflite/sqflite.dart';

final class AppDatabase {
  AppDatabase();

  static const String databaseName = 'delivo.db';
  static const int databaseVersion = 2;

  Database? _database;

  Future<Database> get database async {
    final existing = _database;

    if (existing != null) {
      return existing;
    }

    final databasePath = await getDatabasesPath();
    final path = '$databasePath/$databaseName';

    final database = await openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    _database = database;
    return database;
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createPhotoDecisions(db);
    await _createPhotoFolders(db);
  }

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _createPhotoFolders(db);
    }
  }

  Future<void> _createPhotoDecisions(Database db) async {
    await db.execute(
      '''
      CREATE TABLE IF NOT EXISTS photo_decisions (
        asset_id TEXT PRIMARY KEY NOT NULL,
        decision INTEGER NOT NULL,
        folder_id TEXT,
        decided_at INTEGER NOT NULL,
        asset_created_at INTEGER
      )
      ''',
    );

    await db.execute(
      '''
      CREATE INDEX IF NOT EXISTS idx_photo_decisions_decision
      ON photo_decisions(decision)
      ''',
    );

    await db.execute(
      '''
      CREATE INDEX IF NOT EXISTS idx_photo_decisions_folder
      ON photo_decisions(folder_id)
      ''',
    );
  }

  Future<void> _createPhotoFolders(Database db) async {
    await db.execute(
      '''
      CREATE TABLE IF NOT EXISTS photo_folders (
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL COLLATE NOCASE,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        cover_asset_id TEXT
      )
      ''',
    );

    await db.execute(
      '''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_photo_folders_name
      ON photo_folders(name)
      ''',
    );
  }

  Future<void> close() async {
    final database = _database;
    _database = null;

    if (database != null) {
      await database.close();
    }
  }
}
