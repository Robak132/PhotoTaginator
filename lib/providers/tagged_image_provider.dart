import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:photo_taginator/models/tag.dart';
import 'package:photo_taginator/models/tagged_image.dart';
import 'package:photo_taginator/providers/database_provider.dart';
import 'package:sqflite/sqflite.dart';

class TaggedImageProvider extends ChangeNotifier {
  final List<TaggedImage> _images = [];
  late final Database database;

  get length => _images.length;
  get allImages => _images;
  TaggedImage operator [](int index) => _images[index];
  void operator []=(int index, TaggedImage value) => _images[index] = value;

  TaggedImageProvider() {
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
