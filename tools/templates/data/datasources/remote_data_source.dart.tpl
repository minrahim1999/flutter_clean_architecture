import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_service.dart';
import '../models/feature_name_model.dart';

abstract class FeatureNameRemoteDataSource {
  Future<List<FeatureNameModel>> getFeatureNames({int page = 1});
  Future<FeatureNameModel> getFeatureNameById(String id);
  Future<FeatureNameModel> createFeatureName(FeatureNameModel featureName);
  Future<FeatureNameModel> updateFeatureName(FeatureNameModel featureName);
  Future<bool> deleteFeatureName(String id);
}

class FeatureNameRemoteDataSourceImpl implements FeatureNameRemoteDataSource {
  final ApiService apiService;

  FeatureNameRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<FeatureNameModel>> getFeatureNames({int page = 1}) async {
    try {
      final response = await apiService.get<Map<String, dynamic>>(
        '/api/featureName',
        queryParameters: {'page': page},
      );

      if (response.isSuccess) {
        final List<dynamic> data = response.data?['data'] ?? [];
        return data.map((json) => FeatureNameModel.fromJson(json)).toList();
      } else {
        throw ServerException(message: response.errorMessage);
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<FeatureNameModel> getFeatureNameById(String id) async {
    try {
      final response = await apiService.get<Map<String, dynamic>>(
        '/api/featureName/$id',
      );

      if (response.isSuccess && response.data != null) {
        return FeatureNameModel.fromJson(response.data!);
      } else {
        throw ServerException(message: response.errorMessage ?? 'Failed to get feature');
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<FeatureNameModel> createFeatureName(FeatureNameModel featureName) async {
    try {
      final response = await apiService.post<Map<String, dynamic>>(
        '/api/featureName',
        data: featureName.toJson(),
      );

      if (response.isSuccess && response.data != null) {
        return FeatureNameModel.fromJson(response.data!);
      } else {
        throw ServerException(message: response.errorMessage ?? 'Failed to create feature');
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<FeatureNameModel> updateFeatureName(FeatureNameModel featureName) async {
    try {
      final response = await apiService.put<Map<String, dynamic>>(
        '/api/featureName/${featureName.id}',
        data: featureName.toJson(),
      );

      if (response.isSuccess && response.data != null) {
        return FeatureNameModel.fromJson(response.data!);
      } else {
        throw ServerException(message: response.errorMessage ?? 'Failed to update feature');
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<bool> deleteFeatureName(String id) async {
    try {
      final response = await apiService.delete<Map<String, dynamic>>(
        '/api/featureName/$id',
      );

      if (response.isSuccess) {
        return true;
      } else {
        throw ServerException(message: response.errorMessage ?? 'Failed to delete feature');
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
