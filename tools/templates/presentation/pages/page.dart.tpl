import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/feature_name_bloc.dart';
import '../bloc/feature_name_event.dart';
import '../bloc/feature_name_state.dart';
import '../widgets/feature_name_loading.dart';
import '../widgets/feature_name_error.dart';
import '../widgets/feature_name_content.dart';

class FeatureNamePage extends StatelessWidget {
  const FeatureNamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FeatureName'),
      ),
      body: BlocBuilder<FeatureNameBloc, FeatureNameState>(
        builder: (context, state) {
          if (state is FeatureNameInitial) {
            context.read<FeatureNameBloc>().add(GetFeatureNameEvent());
            return const FeatureNameLoading();
          } else if (state is FeatureNameLoading) {
            return const FeatureNameLoading();
          } else if (state is FeatureNameLoaded) {
            return FeatureNameContent(featureName: state.featureName);
          } else if (state is FeatureNameError) {
            return FeatureNameError(message: state.message);
          }
          return const SizedBox();
        },
      ),
    );
  }
}
