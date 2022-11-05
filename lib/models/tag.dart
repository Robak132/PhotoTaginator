import 'dart:developer';

import 'package:photo_taginator/models/tagged_image.dart';
import 'package:photo_taginator/providers/database_provider.dart';
import 'package:sqflite/sqflite.dart';

class Tag {
  int id;
  String name;

  List<TaggedImage> images = [];

  Tag({required this.id, required this.name});

  Future<void> fetchImages() async {
    log("Fetching images for tag: $this...");
    Database database = await DatabaseProvider().getDatabase();
    List<Map<String, Object?>> query =
        await database.query("CONNECTIONS", columns: ["IMAGE_ID"], where: "TAG_ID = ?", whereArgs: [id]);
    images = [for (Map<String, Object?> map in query) TaggedImage(id: map["IMAGE_ID"] as String)];
    log("Images fetched for: $this");
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag && runtimeType == other.runtimeType && id == other.id && name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'Tag{id: $id, name: $name}';
  }
}
