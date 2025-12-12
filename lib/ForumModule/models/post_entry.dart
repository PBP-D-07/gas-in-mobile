// To parse this JSON data, do
//
//     final postEntry = postEntryFromJson(jsonString);

import 'dart:convert';

List<PostEntry> postEntryFromJson(String str) => List<PostEntry>.from(json.decode(str).map((x) => PostEntry.fromJson(x)));

String postEntryToJson(List<PostEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PostEntry {
    dynamic id;
    String description;
    String? thumbnail;
    String category;
    int postViews;
    bool? isHot;
    int likeCount;
    DateTime createdAt;
    String? ownerId;
    String? ownerUsername;
    bool isRealUser;
    List<Comment>? comments;

    PostEntry({
        required this.id,
        required this.description,
        required this.thumbnail,
        required this.category,
        required this.postViews,
        this.isHot,
        required this.likeCount,
        required this.createdAt,
        this.ownerId,
        this.ownerUsername,
        required this.isRealUser,
        this.comments,
    });

    factory PostEntry.fromJson(Map<String, dynamic> json) => PostEntry(
        id: json["id"],
        description: json["description"],
        thumbnail: json["thumbnail"],
        category: json["category"],
        postViews: json["post_views"],
        isHot: json["is_hot"],
        likeCount: json["like_count"],
        createdAt: DateTime.parse(json["created_at"]),
        ownerId: json["owner_id"],
        ownerUsername: json["owner_username"],
        isRealUser: json["is_real_user"],
        comments: json["comments"] == null ? [] : List<Comment>.from(json["comments"]!.map((x) => Comment.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "description": description,
        "thumbnail": thumbnail,
        "category": category,
        "post_views": postViews,
        "is_hot": isHot,
        "like_count": likeCount,
        "created_at": createdAt.toIso8601String(),
        "owner_id": ownerId,
        "owner_username": ownerUsername,
        "is_real_user": isRealUser,
        "comments": comments == null ? [] : List<dynamic>.from(comments!.map((x) => x.toJson())),
    };
}

class Comment {
    String user;
    String content;
    DateTime createdAt;

    Comment({
        required this.user,
        required this.content,
        required this.createdAt,
    });

    factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        user: json["user"],
        content: json["content"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "user": user,
        "content": content,
        "created_at": createdAt.toIso8601String(),
    };
}
