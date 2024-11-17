import 'package:flutter/material.dart';
import '../../domain/entities/FeatureName.dart';

class FeatureNameContent extends StatelessWidget {
  final FeatureName featureName;

  const FeatureNameContent({
    Key? key,
    required this.featureName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('FeatureName Content: ${featureName.id}'),
    );
  }
}
