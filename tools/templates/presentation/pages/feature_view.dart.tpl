import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/base_screen.dart';
import '../bloc/feature_bloc.dart';
import '../widgets/feature_list_item.dart';

class FeatureView extends StatelessWidget {
  const FeatureView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: BlocBuilder<FeatureBloc, FeatureState>(
        builder: (context, state) {
          if (state is FeatureInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FeatureLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FeatureLoaded) {
            if (state.features.isEmpty) {
              return const Center(
                child: Text('No features found'),
              );
            }

            return ListView.builder(
              itemCount: state.features.length,
              itemBuilder: (context, index) {
                final feature = state.features[index];
                return FeatureListItem(feature: feature);
              },
            );
          }

          if (state is FeatureError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
