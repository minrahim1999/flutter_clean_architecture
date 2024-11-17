import 'package:flutter/material.dart';

class FeatureNameLoading extends StatelessWidget {
  const FeatureNameLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
