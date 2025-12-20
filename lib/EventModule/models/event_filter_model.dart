import 'dart:convert';

SavedSearchResponse savedSearchResponseFromJson(String str) => SavedSearchResponse.fromJson(json.decode(str));

String savedSearchResponseToJson(SavedSearchResponse data) => json.encode(data.toJson());

class SavedSearchResponse {
    String message;
    List<SavedSearch> data;

    SavedSearchResponse({
        required this.message,
        required this.data,
    });

    factory SavedSearchResponse.fromJson(Map<String, dynamic> json) => SavedSearchResponse(
        message: json["message"],
        data: List<SavedSearch>.from(json["data"].map((x) => SavedSearch.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class SavedSearch {
    String id;
    String name;
    String location;
    String category;
    DateTime createdAt;

    SavedSearch({
        required this.id,
        required this.name,
        required this.location,
        required this.category,
        required this.createdAt,
    });

    factory SavedSearch.fromJson(Map<String, dynamic> json) => SavedSearch(
        id: json["id"],
        name: json["name"],
        location: json["location"],
        category: json["category"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "location": location,
        "category": category,
        "created_at": createdAt.toIso8601String(),
    };
}