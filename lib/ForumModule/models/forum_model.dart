import 'dart:convert';
//models for forum post entry

List<PostEntry> postEntryFromJson(String str) =>
    List<PostEntry>.from(json.decode(str).map((x) => PostEntry.fromJson(x)));

String postEntryToJson(List<PostEntry> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PostEntry {
  String id;
  String description;
  String? thumbnail;
  String category;
  int postViews;
  List<String> likes;
  DateTime createdAt;
  String owner; // username
  bool isPostHot;

  PostEntry({
    required this.id,
    required this.description,
    required this.thumbnail,
    required this.category,
    required this.postViews,
    required this.likes,
    required this.createdAt,
    required this.owner,
    required this.isPostHot,
  });

  factory PostEntry.fromJson(Map<String, dynamic> json) => PostEntry(
        id: json["id"],
        description: json["description"],
        thumbnail: json["thumbnail"],
        category: json["category"],
        postViews: json["post_views"],
        likes: List<String>.from(json["likes"].map((x) => x.toString())),
        createdAt: DateTime.parse(json["created_at"]),
        owner: json["owner"], 
        isPostHot: json["is_post_hot"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "description": description,
        "thumbnail": thumbnail,
        "category": category,
        "post_views": postViews,
        "likes": List<dynamic>.from(likes.map((x) => x)),
        "created_at": createdAt.toIso8601String(),
        "owner": owner,
        "is_post_hot": isPostHot,
      };
}