import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failures.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/usecases/home_usecases.dart';

part 'home_provider.g.dart';

// ─── Posts List (paginated) ────────────────────────────────────────

@riverpod
class PostsNotifier extends _$PostsNotifier {
  late HomeRepository _repository;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  Future<List<PostEntity>> build() async {
    _repository = ref.watch(homeRepositoryProvider);
    return _fetchPage(page: 1);
  }

  Future<List<PostEntity>> _fetchPage({required int page}) async {
    final result = await GetPostsUseCase(_repository).call(
      GetPostsParams(page: page, limit: 20),
    );
    return result.fold(
      (failure) => throw failure,
      (posts) {
        _hasMore = posts.length >= 20;
        return posts;
      },
    );
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;
    final current = state.valueOrNull ?? [];
    _currentPage++;
    final next = await _fetchPage(page: _currentPage);
    state = AsyncData([...current, ...next]);
  }

  Future<void> refresh() async {
    _currentPage = 1;
    _hasMore = true;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPage(page: 1));
  }

  Future<void> toggleLike(String postId) async {
    final result = await ToggleLikeUseCase(_repository).call(postId);
    result.fold(
      (_) {}, // silently ignore like failures
      (updated) {
        final current = state.valueOrNull ?? [];
        state = AsyncData([
          for (final p in current)
            if (p.id == postId) updated else p,
        ]);
      },
    );
  }
}

// ─── Single Post ──────────────────────────────────────────────────

@riverpod
Future<PostEntity> post(PostRef ref, String id) async {
  final repository = ref.watch(homeRepositoryProvider);
  final result = await GetPostByIdUseCase(repository).call(id);
  return result.fold(
    (failure) => throw failure,
    (post) => post,
  );
}

// ─── Real-time Posts Stream ────────────────────────────────────────

@riverpod
Stream<List<PostEntity>> postsStream(PostsStreamRef ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.watchPosts().map((either) => either.fold(
        (failure) => throw failure,
        (posts) => posts,
      ));
}
