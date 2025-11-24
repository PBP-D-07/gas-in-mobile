// To parse this JSON data, do
//
//     final eventMaker = eventMakerFromJson(jsonString);

import 'dart:convert';

EventMaker eventMakerFromJson(String str) => EventMaker.fromJson(json.decode(str));

String eventMakerToJson(EventMaker data) => json.encode(data.toJson());

class EventMaker {
    String message;
    Data data;

    EventMaker({
        required this.message,
        required this.data,
    });

    factory EventMaker.fromJson(Map<String, dynamic> json) => EventMaker(
        message: json["message"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": data.toJson(),
    };
}

class Data {
    String name;
    String description;
    DateTime date;
    String location;
    String category;
    bool? isAccepted;
    String id;
    String categoryDisplay;
    User owner;
    List<User> participants;
    String? thumbnail;

    Data({
        required this.name,
        required this.description,
        required this.date,
        required this.location,
        required this.category,
        required this.isAccepted,
        required this.id,
        required this.categoryDisplay,
        required this.owner,
        required this.participants,
        required this.thumbnail,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        name: json["name"],
        description: json["description"],
        date: DateTime.parse(json["date"]),
        location: json["location"],
        category: json["category"],
        isAccepted: json["is_accepted"],
        id: json["id"],
        categoryDisplay: json["category_display"],
        owner: User.fromJson(json["owner"]),
        participants: List<User>.from(json["participants"].map((x) => User.fromJson(x))),
        thumbnail: json["thumbnail"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "date": date.toIso8601String(),
        "location": location,
        "category": category,
        "is_accepted": isAccepted,
        "id": id,
        "category_display": categoryDisplay,
        "owner": owner.toJson(),
        "participants": List<dynamic>.from(participants.map((x) => x.toJson())),
        "thumbnail": thumbnail,
    };
}

class User {
    String id;
    String username;

    User({
        required this.id,
        required this.username,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        username: json["username"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
    };
}
