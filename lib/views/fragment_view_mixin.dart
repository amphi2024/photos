import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/models/app_state.dart';
import 'package:photos/providers/providers.dart';

mixin FragmentViewMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (scrollController.offset > 60) {
        ref.read(titleMinimizedProvider.notifier).state = true;
      } else {
        ref.read(titleMinimizedProvider.notifier).state = false;
      }
    });

    appState.requestScrollToTop = () {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOutQuint,
      );
    };
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
