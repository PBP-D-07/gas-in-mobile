// To parse this JSON data, do
//
//     final venueEntry = venueEntryFromJson(jsonString);

import 'dart:convert';

List<VenueEntry> venueEntryFromJson(String str) =>
    List<VenueEntry>.from(json.decode(str).map((x) => VenueEntry.fromJson(x)));

String venueEntryToJson(List<VenueEntry> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class VenueEntry {
  String id;
  String name;
  String description;
  String location;
  String thumbnail;
  List<String> images;
  String contactNumber;
  dynamic ownerUsername;
  String category;
  DateTime createdAt;
  dynamic ownerId;

  VenueEntry({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.thumbnail,
    required this.images,
    required this.contactNumber,
    required this.ownerUsername,
    required this.category,
    required this.createdAt,
    required this.ownerId,
  });

  factory VenueEntry.fromJson(Map<String, dynamic> json) => VenueEntry(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    location: json["location"],
    thumbnail: json["thumbnail"],
    images: List<String>.from(json["images"].map((x) => x)),
    contactNumber: json["contact_number"],
    ownerUsername: json["owner_username"],
    category: json["category"],
    createdAt: DateTime.parse(json["created_at"]),
    ownerId: json["owner_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "location": location,
    "thumbnail": thumbnail,
    "images": List<dynamic>.from(images.map((x) => x)),
    "contact_number": contactNumber,
    "owner_username": ownerUsername,
    "category": category,
    "created_at": createdAt.toIso8601String(),
    "owner_id": ownerId,
  };
}
