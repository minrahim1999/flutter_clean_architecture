import 'package:flutter/material.dart';
import '../../domain/entities/feature_entity.dart';
import 'feature_list_item.dart';

class FeatureList extends StatefulWidget {
  final List<FeatureEntity> features;
  final bool hasReachedMax;
  final VoidCallback onLoadMore;

  const FeatureList({
    super.key,
    required this.features,
    required this.hasReachedMax,
    required this.onLoadMore,
  });

  @override
  State<FeatureList> createState() => _FeatureListState();
}

class _FeatureListState extends State<FeatureList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom && !widget.hasReachedMax) {
      widget.onLoadMore();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Implement refresh logic
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.hasReachedMax
            ? widget.features.length
            : widget.features.length + 1,
        itemBuilder: (context, index) {
          if (index >= widget.features.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return FeatureListItem(
            feature: widget.features[index],
          );
        },
      ),
    );
  }
}
