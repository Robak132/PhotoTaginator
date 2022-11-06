import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:photo_taginator/models/tag.dart';
import 'package:photo_taginator/models/tagged_image.dart';
import 'package:photo_taginator/providers/database_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unique_list/unique_list.dart';

class TagProvider extends ChangeNotifier {
  final UniqueList<Tag> tags = UniqueList();
  get notEmptyTags => tags.where((Tag tag) => tag.images.isNotEmpty).toUniqueList();

  TagProvider() {
    refresh();
  }

  Future<void> refresh() async {
    tags.clear();
    Database database = await DatabaseProvider().getDatabase();
    log("Loading tags from database...");
    List<Map<String, Object?>> query = await database.query("TAGS", columns: ["ID", "NAME"]);
    for (Tag tag in query.map((entity) => Tag(id: entity["ID"] as int, name: entity["NAME"] as String))) {
      await tag.fetchImages();
      tags.add(tag);
      notifyListeners();
    }
    log("Tags loaded");
  }

  Future<void> add(String tagName) async {
    Database database = await DatabaseProvider().getDatabase();
    int id = await database.insert("TAGS", {"NAME": tagName});
    tags.add(Tag(id: id, name: tagName));
    notifyListeners();
  }

  Future<void> remove(Tag tag) async {
    Database database = await DatabaseProvider().getDatabase();
    tags.remove(tag);
    await database.delete("TAGS", where: "ID = ? AND NAME = ?", whereArgs: [tag.id, tag.name]);
    notifyListeners();
  }

  Future<void> addImage(Tag tag, TaggedImage image) async {
    Database database = await DatabaseProvider().getDatabase();
    int index = tags.indexOf(tag);
    tags[index].images.add(image);
    await database.insert("CONNECTIONS", {"IMAGE_ID": image.id, "TAG_ID": tag.id},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    notifyListeners();
  }

  Future<void> removeImage(Tag tag, TaggedImage image) async {
    Database database = await DatabaseProvider().getDatabase();
    int index = tags.indexOf(tag);
    tags[index].images.remove(image);
    await database.delete("CONNECTIONS", where: "IMAGE_ID = ? AND TAG_ID = ?", whereArgs: [image.id, tag.id]);
    notifyListeners();
  }
}
