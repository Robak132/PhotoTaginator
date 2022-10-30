import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:photo_taginator/models/tag.dart';
import 'package:photo_taginator/providers/database_provider.dart';
import 'package:sqflite/sqflite.dart';

class TagProvider extends ChangeNotifier {
  final List<Tag> _tags = [];

  get length => _tags.length;
  get allTags => _tags;
  Tag operator [](int index) => _tags[index];
  void operator []=(int index, Tag value) => _tags[index] = value;

  TagProvider() {
    refresh();
  }

  Future<void> refresh() async {
    log("Loading tags from database...");
    Database database = await DatabaseProvider().getDatabase();
    List query = await database.query("TAGS", columns: ["ID", "NAME"]);
    _tags.clear();
    for (Tag tag in query.map((entity) => Tag(id: entity["ID"], name: entity["NAME"]))) {
      _tags.add(tag);
      notifyListeners();
    }
    log("Tags loaded");
  }

  void add(Tag tag) {
    _tags.add(tag);
    notifyListeners();
  }

  void removeAt(int index) {
    _tags.removeAt(index);
    notifyListeners();
  }
}