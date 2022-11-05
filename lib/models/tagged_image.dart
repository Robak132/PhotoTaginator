import 'dart:developer';

import 'package:photo_taginator/models/tag.dart';
import 'package:photo_taginator/providers/database_provider.dart';
import 'package:sqflite/sqflite.dart';

class TaggedImage {
  String id;
  List<Tag> tags = [];

  TaggedImage({required this.id, tags = const <Tag>[]}) {
    this.tags.addAll(tags);
  }

  void setTags(List<Tag> tags) {
    this.tags = tags;
  }

  void addTag(Tag tag) {
    if (!tags.contains(tag)) {
      tags.add(tag);
    }
  }

  void removeTag(Tag tag) {
    tags.remove(tag);
  }

  bool containsTagName(String name) {
    return tags.any((tag) => tag.name == name);
  }

  Future<void> fetchTags() async {
    log("Fetching tags for image: $this...");
    Database database = await DatabaseProvider().getDatabase();
    List<Map<String, Object?>> query = await database
        .rawQuery("SELECT T.ID, T.NAME FROM CONNECTIONS C JOIN TAGS T ON (T.ID = C.TAG_ID) WHERE IMAGE_ID = ?", [id]);
    tags = [for (Map<String, Object?> map in query) Tag(id: map["ID"] as int, name: map["NAME"] as String)];
    log("Tags fetched for: $this");
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TaggedImage && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TaggedImage{id: $id}';
  }
}
