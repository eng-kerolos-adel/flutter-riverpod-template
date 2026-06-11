import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_riverpod_template/core/errors/failures.dart';
import 'package:flutter_riverpod_template/features/home/domain/entities/post_entity.dart';
import 'package:flutter_riverpod_template/features/home/domain/repositories/home_repository.dart';
import 'package:flutter_riverpod_template/features/home/domain/usecases/home_usecases.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

final tPost = PostEntity(
  id: 'post-1',
  title: 'Hello World',
  body: 'This is a test post.',
  authorId: 'user-1',
  authorName: 'Alice',
  createdAt: DateTime(2024, 1, 1),
);

void main() {
  late MockHomeRepository mockRepo;
  late GetPostsUseCase getPostsUseCase;
  late GetPostByIdUseCase getPostByIdUseCase;
  late ToggleLikeUseCase toggleLikeUseCase;

  setUp(() {
    mockRepo = MockHomeRepository();
    getPostsUseCase = GetPostsUseCase(mockRepo);
    getPostByIdUseCase = GetPostByIdUseCase(mockRepo);
    toggleLikeUseCase = ToggleLikeUseCase(mockRepo);
  });

  group('GetPostsUseCase', () {
    test('returns list of posts on success', () async {
      when(() => mockRepo.getPosts(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => Right([tPost]));

      final result = await getPostsUseCase(const GetPostsParams());

      expect(result.isRight(), isTrue);
      result.fold((_) {}, (posts) => expect(posts, [tPost]));
    });

    test('returns ServerFailure on error', () async {
      when(() => mockRepo.getPosts(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));

      final result = await getPostsUseCase(const GetPostsParams());
      expect(result.isLeft(), isTrue);
    });
  });

  group('GetPostByIdUseCase', () {
    test('returns post by id', () async {
      when(() => mockRepo.getPostById(any()))
          .thenAnswer((_) async => Right(tPost));

      final result = await getPostByIdUseCase('post-1');
      expect(result, Right<Failure, PostEntity>(tPost));
    });

    test('returns NotFoundFailure when post not found', () async {
      when(() => mockRepo.getPostById(any()))
          .thenAnswer((_) async => const Left(NotFoundFailure()));

      final result = await getPostByIdUseCase('invalid-id');
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<NotFoundFailure>()), (_) {});
    });
  });

  group('ToggleLikeUseCase', () {
    test('returns updated post after toggle', () async {
      final liked = tPost.copyWith(isLiked: true, likesCount: 1);
      when(() => mockRepo.toggleLike(any()))
          .thenAnswer((_) async => Right(liked));

      final result = await toggleLikeUseCase('post-1');
      result.fold((_) {}, (post) {
        expect(post.isLiked, isTrue);
        expect(post.likesCount, 1);
      });
    });
  });

  group('GetPostsParams', () {
    test('default values', () {
      const params = GetPostsParams();
      expect(params.page, 1);
      expect(params.limit, 20);
    });

    test('equatable', () {
      const a = GetPostsParams(page: 2, limit: 10);
      const b = GetPostsParams(page: 2, limit: 10);
      expect(a, equals(b));
    });
  });
}
