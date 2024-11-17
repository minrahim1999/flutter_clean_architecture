import 'package:flutter/material.dart';
import '../../domain/entities/feature_entity.dart';

class FeatureListItem extends StatelessWidget {
  final FeatureEntity feature;

  const FeatureListItem({
    super.key,
    required this.feature,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: ListTile(
        title: Text(
          feature.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          feature.description,
          style: Theme.of(context).textTheme.bodyMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            // Navigate to feature details
          },
        ),
      ),
    );
  }
}
