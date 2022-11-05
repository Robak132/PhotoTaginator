import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:photo_taginator/models/tag.dart';
import 'package:photo_taginator/models/tagged_image.dart';
import 'package:photo_taginator/providers/database_provider.dart';
import 'package:sqflite/sqflite.dart';

class TagProvider extends ChangeNotifier {
  final List<Tag> tags = [];

  TagProvider() {
    refresh();
  }

  Future<void> refresh() async {
    Database database = await DatabaseProvider().getDatabase();
    log("Loading tags from database...");
    List<Map<String, Object?>> query = await database.query("TAGS", columns: ["ID", "NAME"]);
    for (Tag tag in query.map((entity) => Tag(id: entity["ID"] as int, name: entity["NAME"] as String))) {
      tag.fetchImages();
      add(tag);
    }
    log("Tags loaded");
  }

  void add(Tag tag) {
    tags.add(tag);
    notifyListeners();
  }

  void removeAt(int index) {
    tags.removeAt(index);
    notifyListeners();
  }

  Future<void> addImage(Tag tag, TaggedImage image) async {
    Database database = await DatabaseProvider().getDatabase();
    int index = tags.indexOf(tag);
    tags[index].images.add(image);
    database.insert("CONNECTIONS", {"IMAGE_ID": image.id, "TAG_ID": tag.id},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    notifyListeners();
  }

  Future<void> removeImage(Tag tag, TaggedImage image) async {
    Database database = await DatabaseProvider().getDatabase();
    int index = tags.indexOf(tag);
    tags[index].images.remove(image);
    database.delete("CONNECTIONS", where: "IMAGE_ID = ? AND TAG_ID = ?", whereArgs: [image.id, tag.id]);
    notifyListeners();
  }
}
