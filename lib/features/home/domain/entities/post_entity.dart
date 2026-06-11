import 'package:equatable/equatable.dart';

/// Example domain entity for the home feature.
/// Replace or extend this with your actual domain model.
class PostEntity extends Equatable {
  const PostEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.authorId,
    required this.authorName,
    this.imageUrl,
    this.tags = const [],
    this.likesCount = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String authorId;
  final String authorName;
  final String? imageUrl;
  final List<String> tags;
  final int likesCount;
  final bool isLiked;
  final DateTime createdAt;

  PostEntity copyWith({
    String? id,
    String? title,
    String? body,
    String? authorId,
    String? authorName,
    String? imageUrl,
    List<String>? tags,
    int? likesCount,
    bool? isLiked,
    DateTime? createdAt,
  }) {
    return PostEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id, title, body, authorId, authorName,
        imageUrl, tags, likesCount, isLiked, createdAt,
      ];
}
