import '%CORE_ERROR_EXCEPTIONS_IMPORT%';
import '%CORE_DATABASE_DATABASE_SERVICE_IMPORT%';
import '../models/%MODEL_NAME%_model.dart';

abstract class %MODEL_NAME%LocalDataSource {
  Future<List<%MODEL_NAME%Model>> get%MODEL_NAME%List({int page = 1});
  Future<%MODEL_NAME%Model> get%MODEL_NAME%ById(String id);
  Future<void> cache%MODEL_NAME%List(List<%MODEL_NAME%Model> %MODEL_NAME%);
  Future<void> cache%MODEL_NAME%(%MODEL_NAME%Model %MODEL_NAME%);
  Future<void> delete%MODEL_NAME%FromCache(String id);
  Future<void> clearCache();
}

class %MODEL_NAME%LocalDataSourceImpl implements %MODEL_NAME%LocalDataSource {
  final DatabaseService databaseService;
  final String tableName = '%TABLE_NAME%';

  %MODEL_NAME%LocalDataSourceImpl({required this.databaseService});

  @override
  Future<List<%MODEL_NAME%Model>> get%MODEL_NAME%List({int page = 1}) async {
    try {
      final records = await databaseService.getAll(
        tableName,
        offset: (page - 1) * 20,
        limit: 20,
      );
      
      return records.map((record) {
        try {
          return %MODEL_NAME%Model.fromJson(record);
        } catch (e) {
          throw CacheException();
        }
      }).toList();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<%MODEL_NAME%Model> get%MODEL_NAME%ById(String id) async {
    try {
      final record = await databaseService.getById(tableName, id);
      return %MODEL_NAME%Model.fromJson(record);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cache%MODEL_NAME%List(List<%MODEL_NAME%Model> %MODEL_NAME%) async {
    try {
      for (var %MODEL_NAME% in %MODEL_NAME%) {
        await databaseService.insert(
          tableName,
          %MODEL_NAME%.toJson(),
        );
      }
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cache%MODEL_NAME%(%MODEL_NAME%Model %MODEL_NAME%) async {
    try {
      await databaseService.insert(
        tableName,
        %MODEL_NAME%.toJson(),
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> delete%MODEL_NAME%FromCache(String id) async {
    try {
      await databaseService.delete(tableName, id);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await databaseService.clear(tableName);
    } catch (e) {
      throw CacheException();
    }
  }
}
