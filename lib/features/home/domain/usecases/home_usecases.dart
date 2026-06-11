import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/post_entity.dart';
import '../repositories/home_repository.dart';

class GetPostsUseCase {
  const GetPostsUseCase(this._repository);
  final HomeRepository _repository;

  Future<Either<Failure, List<PostEntity>>> call(GetPostsParams params) {
    return _repository.getPosts(page: params.page, limit: params.limit);
  }
}

class GetPostsParams extends Equatable {
  const GetPostsParams({this.page = 1, this.limit = 20});
  final int page;
  final int limit;

  @override
  List<Object?> get props => [page, limit];
}

class GetPostByIdUseCase {
  const GetPostByIdUseCase(this._repository);
  final HomeRepository _repository;

  Future<Either<Failure, PostEntity>> call(String id) {
    return _repository.getPostById(id);
  }
}

class ToggleLikeUseCase {
  const ToggleLikeUseCase(this._repository);
  final HomeRepository _repository;

  Future<Either<Failure, PostEntity>> call(String postId) {
    return _repository.toggleLike(postId);
  }
}
