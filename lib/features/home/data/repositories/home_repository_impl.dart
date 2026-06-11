import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../models/post_model.dart';

part 'home_repository_impl.g.dart';

@riverpod
HomeRepository homeRepository(HomeRepositoryRef ref) {
  return HomeRepositoryImpl(firestore: FirebaseFirestore.instance);
}

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({required this.firestore});

  final FirebaseFirestore firestore;

  @override
  Future<Either<Failure, List<PostEntity>>> getPosts({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.postsCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final posts = snapshot.docs
          .map((doc) => PostModel.fromFirestore(doc).toEntity())
          .toList();

      return Right(posts);
    } catch (e, st) {
      AppLogger.error('getPosts error', e, st);
      return Left(ServerFailure(message: 'Failed to load posts', stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> getPostById(String id) async {
    try {
      final doc = await firestore
          .collection(AppConstants.postsCollection)
          .doc(id)
          .get();

      if (!doc.exists) {
        return const Left(NotFoundFailure());
      }

      return Right(PostModel.fromFirestore(doc).toEntity());
    } catch (e, st) {
      AppLogger.error('getPostById error', e, st);
      return Left(ServerFailure(message: 'Failed to load post', stackTrace: st));
    }
  }

  @override
  Stream<Either<Failure, List<PostEntity>>> watchPosts() {
    return firestore
        .collection(AppConstants.postsCollection)
        .orderBy('createdAt', descending: true)
        .limit(AppConstants.defaultPageSize)
        .snapshots()
        .map((snapshot) {
      final posts = snapshot.docs
          .map((doc) => PostModel.fromFirestore(doc).toEntity())
          .toList();
      return Right<Failure, List<PostEntity>>(posts);
    }).handleError((e, st) {
      AppLogger.error('watchPosts error', e, st);
      return Left<Failure, List<PostEntity>>(
        ServerFailure(message: 'Real-time sync failed', stackTrace: st as StackTrace),
      );
    });
  }

  @override
  Future<Either<Failure, PostEntity>> toggleLike(String postId) async {
    try {
      final ref = firestore.collection(AppConstants.postsCollection).doc(postId);

      // Use a transaction for atomic like toggle
      final result = await firestore.runTransaction((tx) async {
        final doc = await tx.get(ref);
        if (!doc.exists) throw const NotFoundException();

        final model = PostModel.fromFirestore(doc);
        final nowLiked = !model.isLiked;
        final newCount = nowLiked ? model.likesCount + 1 : model.likesCount - 1;

        tx.update(ref, {
          'isLiked': nowLiked,
          'likesCount': newCount.clamp(0, double.maxFinite.toInt()),
        });

        return model
            .copyWith(isLiked: nowLiked, likesCount: newCount.clamp(0, 9999999))
            .toEntity();
      });

      return Right(result);
    } catch (e, st) {
      AppLogger.error('toggleLike error', e, st);
      return Left(ServerFailure(message: 'Failed to update like', stackTrace: st));
    }
  }
}
