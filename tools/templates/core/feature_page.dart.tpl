import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/base_screen.dart';
import '../bloc/feature_name_bloc.dart';

class FeatureNamePage extends StatelessWidget {
  const FeatureNamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FeatureName'),
        ),
        body: BlocBuilder<FeatureNameBloc, FeatureNameState>(
          builder: (context, state) {
            if (state is FeatureNameLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is FeatureNameError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<FeatureNameBloc>().add(GetFeatureNamesEvent());
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }
            
            if (state is FeatureNameLoaded) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.featureNames.length,
                itemBuilder: (context, index) {
                  final featureName = state.featureNames[index];
                  return Card(
                    child: ListTile(
                      title: Text(featureName.title),
                      subtitle: Text(featureName.description),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Handle item tap
                      },
                    ),
                  );
                },
              );
            }
            
            return const SizedBox();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Handle create action
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
