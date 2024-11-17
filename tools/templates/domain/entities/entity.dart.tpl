import 'package:equatable/equatable.dart';

class FeatureName extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? bio;
  final DateTime? lastSeen;
  final bool isOnline;

  const FeatureName({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.bio,
    this.lastSeen,
    this.isOnline = false,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        avatarUrl,
        bio,
        lastSeen,
        isOnline,
      ];
}
