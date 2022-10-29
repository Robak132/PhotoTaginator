import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:photo_taginator/database_provider.dart';
import 'package:sqflite/sqflite.dart';

class TagCollection extends ChangeNotifier {
  final List<String> _tags = [];

  get length => _tags.length;
  get allTags => _tags;
  String operator [](int index) => _tags[index];
  void operator []=(int index, String value) => _tags[index] = value;

  TagCollection() {
    refresh();
  }

  Future<void> refresh() async {
    log("Loading tags from database...");
    Database database = await DatabaseProvider.instance.getDatabase();
    List query = await database.query("TAGS", columns: ["NAME"]);
    _tags.clear();
    for (String tag in query.map((entity) => entity["NAME"])) {
      _tags.add(tag);
      notifyListeners();
    }
    log("Tags loaded");
  }

  void add(String tag) {
    _tags.add(tag);
    notifyListeners();
  }

  void removeAt(int index) {
    _tags.removeAt(index);
    notifyListeners();
  }
}
