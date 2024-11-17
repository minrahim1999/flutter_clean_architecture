import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/feature_name.dart';

part 'feature_name_model.g.dart';

@JsonSerializable()
class FeatureNameModel extends FeatureName {
  const FeatureNameModel({
    required String id,
    required String name,
    required String email,
    String? avatarUrl,
    String? bio,
    DateTime? lastSeen,
    bool isOnline = false,
  }) : super(
          id: id,
          name: name,
          email: email,
          avatarUrl: avatarUrl,
          bio: bio,
          lastSeen: lastSeen,
          isOnline: isOnline,
        );

  factory FeatureNameModel.fromJson(Map<String, dynamic> json) =>
      _$FeatureNameModelFromJson(json);

  Map<String, dynamic> toJson() => _$FeatureNameModelToJson(this);

  factory FeatureNameModel.fromEntity(FeatureName entity) {
    return FeatureNameModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      avatarUrl: entity.avatarUrl,
      bio: entity.bio,
      lastSeen: entity.lastSeen,
      isOnline: entity.isOnline,
    );
  }
}
