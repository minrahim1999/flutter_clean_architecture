import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

abstract class DatabaseService {
  Future<Database> get database;
  Future<List<Map<String, dynamic>>> getAll(String store,
      {int? offset, int? limit});
  Future<Map<String, dynamic>?> getById(String store, String id);
  Future<void> insert(String store, Map<String, dynamic> data);
  Future<void> insertMany(String store, List<Map<String, dynamic>> data);
  Future<void> update(String store, String id, Map<String, dynamic> data);
  Future<void> delete(String store, String id);
  Future<void> clear(String store);
  Future<void> close();
}

class DatabaseServiceImpl implements DatabaseService {
  static const String _dbName = 'newsletter.db';
  static const int _version = 1;
  Database? _database;

  @override
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String dbPath = path.join(appDocDir.path, _dbName);

    final DatabaseFactory dbFactory = databaseFactoryIo;
    final Database db = await dbFactory.openDatabase(dbPath, version: _version);

    return db;
  }

  @override
  Future<List<Map<String, dynamic>>> getAll(String store,
      {int? offset, int? limit}) async {
    final db = await database;
    final storeRef = stringMapStoreFactory.store(store);

    final finder = Finder(
      offset: offset,
      limit: limit,
      sortOrders: [SortOrder('createdAt', false)],
    );

    final records = await storeRef.find(db, finder: finder);
    return records.map((record) => record.value).toList();
  }

  @override
  Future<Map<String, dynamic>?> getById(String store, String id) async {
    final db = await database;
    final storeRef = stringMapStoreFactory.store(store);

    final finder = Finder(filter: Filter.byKey(id));
    final record = await storeRef.findFirst(db, finder: finder);
    return record?.value;
  }

  @override
  Future<void> insert(String store, Map<String, dynamic> data) async {
    final db = await database;
    final storeRef = stringMapStoreFactory.store(store);

    data['createdAt'] = DateTime.now().toIso8601String();
    data['updatedAt'] = DateTime.now().toIso8601String();

    await storeRef.add(db, data);
  }

  @override
  Future<void> insertMany(String store, List<Map<String, dynamic>> data) async {
    final db = await database;
    final storeRef = stringMapStoreFactory.store(store);

    final records = data.map((item) {
      item['createdAt'] = DateTime.now().toIso8601String();
      item['updatedAt'] = DateTime.now().toIso8601String();
      return item;
    }).toList();

    await storeRef.addAll(db, records);
  }

  @override
  Future<void> update(
      String store, String id, Map<String, dynamic> data) async {
    final db = await database;
    final storeRef = stringMapStoreFactory.store(store);

    data['updatedAt'] = DateTime.now().toIso8601String();

    final finder = Finder(filter: Filter.byKey(id));
    await storeRef.update(db, data, finder: finder);
  }

  @override
  Future<void> delete(String store, String id) async {
    final db = await database;
    final storeRef = stringMapStoreFactory.store(store);

    final finder = Finder(filter: Filter.byKey(id));
    await storeRef.delete(db, finder: finder);
  }

  @override
  Future<void> clear(String store) async {
    final db = await database;
    final storeRef = stringMapStoreFactory.store(store);
    await storeRef.delete(db);
  }

  @override
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  Future<void> _onVersionChanged(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion == 0) {
      // First time creating the DB
      final store = intMapStoreFactory.store('newsletters');
      await store.drop(db);
    }
  }
}
