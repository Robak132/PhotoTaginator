import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:photo_taginator/models/tag.dart';
import 'package:photo_taginator/models/tagged_image.dart';
import 'package:photo_taginator/providers/database_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unique_list/unique_list.dart';

class TaggedImageProvider extends ChangeNotifier {
  final List<TaggedImage> _images = [];
  final Map<Tag, List<TaggedImage>> _tagMap = {};
  late final Database database;

  get images => _images;
  get tags => _tagMap.keys.toList();
  get map => _tagMap;

  TaggedImageProvider() {
    refresh();
  }
  // Future<Map<TaggedImage, List<Tag>>> getTagMap() async {
  //   List<TaggedImage> imageList = [];
  //   List databaseMap = await database.rawQuery("SELECT C.IMAGE_ID, C.TAG_ID, T.NAME FROM CONNECTIONS C JOIN TAGS T ON (C.TAG_ID = T.ID)");
  //   for (Map<String, Object?> entry in databaseMap) {
  //     Tag tag = Tag(id: entry["TAG_ID"] as int, name: entry["NAME"] as String);
  //     imageList.add(TaggedImage(id: entry["IMAGE_ID"]))
  //     resultMap.putIfAbsent(entry["IMAGE_ID"], () => <Tag>[]);
  //     resultMap[tag]!.add(image);
  //   }
  // }

  Future<void> refresh() async {
    database = await DatabaseProvider.instance.getDatabase();
    log("Loading gallery...");
    List<Album> albums = await PhotoGallery.listAlbums(mediumType: MediumType.image);
    for (Album album in albums) {
      final List<Medium> mediums = (await album.listMedia()).items;
      for (Medium media in mediums) {
        List map = await database.rawQuery(
            "SELECT T.* FROM CONNECTIONS C JOIN TAGS T ON (C.TAG_ID = T.ID) WHERE C.IMAGE_ID = ?", [media.id]);
        UniqueList<Tag> tags = UniqueList.of([for (Map object in map) Tag(id: object["ID"], name: object["NAME"])]);
        add(TaggedImage(id: media.id, tags: tags));
      }
    }
    log("Gallery loaded");
  }

  void add(TaggedImage image) {
    _images.add(image);
    for (Tag tag in image.tags) {
      _tagMap.putIfAbsent(tag, () => <TaggedImage>[]);
      _tagMap[tag]!.add(image);
    }
    notifyListeners();
  }

  Future<void> update(TaggedImage image) async {
    int index = _images.indexWhere((element) => element.id == image.id);
    _images[index] = image;
    await updateImage(image);
    notifyListeners();
  }

  void removeAt(int index) {
    _images.removeAt(index);
    notifyListeners();
  }

  Future<void> updateImage(TaggedImage image) async {
    Database database = await DatabaseProvider().getDatabase();
    Batch batch = database.batch();
    batch.delete("CONNECTIONS", where: "IMAGE_ID = ?", whereArgs: [image.id]);
    for (var tag in image.tags) {
      batch.insert("CONNECTIONS", {"IMAGE_ID": image.id, "TAG_ID": tag.id});
    }
    batch.commit(continueOnError: true);
  }
}
