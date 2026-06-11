import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/post_entity.dart';

abstract class HomeRepository {
  /// Fetch a paginated list of posts.
  Future<Either<Failure, List<PostEntity>>> getPosts({
    int page = 1,
    int limit = 20,
  });

  /// Fetch a single post by ID.
  Future<Either<Failure, PostEntity>> getPostById(String id);

  /// Stream of real-time posts from Firestore.
  Stream<Either<Failure, List<PostEntity>>> watchPosts();

  /// Toggle like on a post.
  Future<Either<Failure, PostEntity>> toggleLike(String postId);
}
