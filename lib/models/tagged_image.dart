import 'dart:developer';
import 'dart:io';

import 'package:photo_gallery/photo_gallery.dart';
import 'package:photo_taginator/models/tag.dart';
import 'package:photo_taginator/providers/database_provider.dart';
import 'package:sqflite/sqflite.dart';

class TaggedImage implements Comparable<TaggedImage> {
  String id;

  List<Tag> tags = [];

  TaggedImage(this.id, {tags = const <Tag>[]}) {
    this.tags.addAll(tags);
  }

  Future<String?> getFilename() async => (await PhotoGallery.getMedium(mediumId: id)).filename;

  Future<void> delete() async {
    File file = (await PhotoGallery.getFile(mediumId: id));
    await file.delete();
  }

  void addTag(Tag tag) {
    if (!tags.contains(tag)) {
      tags.add(tag);
    }
  }

  void removeTag(Tag tag) {
    tags.remove(tag);
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
  int compareTo(TaggedImage other) {
    return int.parse(id) - int.parse(other.id);
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
