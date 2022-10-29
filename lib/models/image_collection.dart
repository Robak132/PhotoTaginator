import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:photo_taginator/database_provider.dart';
import 'package:sqflite/sqflite.dart';

class ImageCollection extends ChangeNotifier {
  final List<String> _images = [];
  late final Database database;

  get length => _images.length;
  get allImages => _images;
  String operator [](int index) => _images[index];
  void operator []=(int index, String value) => _images[index] = value;

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
          add(media.id);
          notifyListeners();
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

  void add(String imageID) {
    _images.add(imageID);
    notifyListeners();
  }

  void removeAt(int index) {
    _images.removeAt(index);
    notifyListeners();
  }
}

class Image {
  String id;

  Image({required this.id});
}
