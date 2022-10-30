import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:photo_taginator/database_provider.dart';
import 'package:sqflite/sqflite.dart';

class ImageCollection extends ChangeNotifier {
  final List<TaggedImage> _images = [];
  late final Database database;

  get length => _images.length;
  get allImages => _images;
  TaggedImage operator [](int index) => _images[index];
  void operator []=(int index, TaggedImage value) => _images[index] = value;

  ImageCollection() {
    refresh();
  }

  Future<void> refresh() async {
    database = await DatabaseProvider.instance.getDatabase();
    log("Loading gallery...");
    List<Album> albums = await PhotoGallery.listAlbums(mediumType: MediumType.image);
    for (Album album in albums) {
      final List<Medium> mediums = (await album.listMedia()).items;
      for (Medium media in mediums) {
        if (!await checkCorruptedImage(media)) {
          List map = await database.rawQuery(
              "SELECT T.* FROM CONNECTIONS C JOIN TAGS T ON (C.TAG_ID = T.ID) WHERE C.IMAGE_ID = ?", [media.id]);
          List<Tag> tags = [for (Map object in map) Tag(id: object["ID"], name: object["NAME"])];
          add(TaggedImage(id: media.id, tags: tags));
        }
      }
    }
    log("Gallery loaded");
  }

  Future<bool> checkCorruptedImage(Medium media) async {
    try {
      await media.getThumbnail();
      return false;
    } catch (ex) {
      var corrupted = await media.getFile();
      log("Corrupted image: ${media.id}, path: ${corrupted.path}");
      return true;
    }
  }

  void add(TaggedImage image) {
    _images.add(image);
    notifyListeners();
  }

  void removeAt(int index) {
    _images.removeAt(index);
    notifyListeners();
  }
}

class TaggedImage {
  String id;
  List<Tag> tags = [];

  TaggedImage({required this.id, tags = const <Tag>[]}) {
    this.tags.addAll(tags);
  }

  bool containsTagName(String name) {
    return tags.any((tag) => tag.name == name);
  }
}

class Tag {
  int id;
  String name;

  Tag({required this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag && runtimeType == other.runtimeType && id == other.id && name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
