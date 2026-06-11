import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_error_widget.dart';

/// A wrapper that handles all three [AsyncValue] states cleanly.
///
/// Usage:
/// ```dart
/// AsyncValueWidget<List<Post>>(
///   value: ref.watch(postsProvider),
///   loading: () => const PostListSkeleton(),
///   error: (e, _) => AppErrorWidget(message: e.toString()),
///   data: (posts) => PostList(posts: posts),
/// )
/// ```
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.skipLoadingOnReload = true,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function()? loading;
  final Widget Function(Object error, StackTrace? stack)? error;

  /// When true, shows stale data during reload instead of loading indicator.
  final bool skipLoadingOnReload;

  @override
  Widget build(BuildContext context) {
    if (skipLoadingOnReload) {
      return value.when(
        skipLoadingOnReload: true,
        data: data,
        loading: () => loading?.call() ?? const Center(child: CircularProgressIndicator()),
        error: (e, st) => error?.call(e, st) ??
            AppErrorWidget(message: e.toString()),
      );
    }

    return value.when(
      data: data,
      loading: () => loading?.call() ?? const Center(child: CircularProgressIndicator()),
      error: (e, st) => error?.call(e, st) ??
          AppErrorWidget(message: e.toString()),
    );
  }
}

/// Sliver version for use inside [CustomScrollView].
class AsyncValueSliverWidget<T> extends StatelessWidget {
  const AsyncValueSliverWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function()? loading;
  final Widget Function(Object error, StackTrace? stack)? error;

  @override
  Widget build(BuildContext context) {
    return value.when(
      skipLoadingOnReload: true,
      data: data,
      loading: () =>
          SliverToBoxAdapter(
            child: loading?.call() ?? const Center(child: CircularProgressIndicator()),
          ),
      error: (e, st) =>
          SliverToBoxAdapter(
            child: error?.call(e, st) ?? AppErrorWidget(message: e.toString()),
          ),
    );
  }
}
