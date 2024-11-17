import 'package:flutter/material.dart';

import '../../../domain/entities/feature_entity.dart';

class FeatureDetail extends StatelessWidget {
  final FeatureEntity feature;

  const FeatureDetail({
    super.key,
    required this.feature,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            feature.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            feature.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          _buildInfoRow('Created', feature.createdAt),
          const SizedBox(height: 8),
          _buildInfoRow('Updated', feature.updatedAt),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, DateTime date) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(date.toString()),
      ],
    );
  }
}
