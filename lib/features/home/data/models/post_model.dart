import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/post_entity.dart';

part 'post_model.freezed.dart';
part 'post_model.g.dart';

@freezed
class PostModel with _$PostModel {
  const factory PostModel({
    required String id,
    required String title,
    required String body,
    required String authorId,
    required String authorName,
    String? imageUrl,
    @Default([]) List<String> tags,
    @Default(0) int likesCount,
    @Default(false) bool isLiked,
    required DateTime createdAt,
  }) = _PostModel;

  const PostModel._();

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Firestore Timestamp → DateTime
    if (data['createdAt'] is Timestamp) {
      data['createdAt'] = (data['createdAt'] as Timestamp)
          .toDate()
          .toIso8601String();
    }
    return PostModel.fromJson({'id': doc.id, ...data});
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    json['createdAt'] = Timestamp.fromDate(createdAt);
    return json;
  }

  PostEntity toEntity() => PostEntity(
        id: id,
        title: title,
        body: body,
        authorId: authorId,
        authorName: authorName,
        imageUrl: imageUrl,
        tags: tags,
        likesCount: likesCount,
        isLiked: isLiked,
        createdAt: createdAt,
      );
}
