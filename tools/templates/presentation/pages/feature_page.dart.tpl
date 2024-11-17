import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/base_screen.dart';
import '../bloc/feature_bloc.dart';
import '../widgets/feature_list.dart';
import '../widgets/feature_loading.dart';
import '../widgets/feature_error.dart';

class FeaturePage extends StatelessWidget {
  const FeaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Features'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<FeatureBloc>().add(RefreshFeaturesEvent());
              },
            ),
          ],
        ),
        body: BlocBuilder<FeatureBloc, FeatureState>(
          builder: (context, state) {
            if (state is FeatureInitial || state is FeatureLoading) {
              return const FeatureLoading();
            } else if (state is FeatureLoaded) {
              return FeatureList(
                features: state.features,
                hasReachedMax: state.hasReachedMax,
                onLoadMore: () {
                  context.read<FeatureBloc>().add(
                        GetFeaturesEvent(page: state.currentPage + 1),
                      );
                },
              );
            } else if (state is FeatureError) {
              return FeatureError(
                message: state.message,
                onRetry: () {
                  context.read<FeatureBloc>().add(const GetFeaturesEvent());
                },
              );
            } else if (state is FeatureRefreshing) {
              return Stack(
                children: [
                  FeatureList(
                    features: state.currentFeatures,
                    hasReachedMax: true,
                    onLoadMore: () {},
                  ),
                  const Positioned.fill(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
