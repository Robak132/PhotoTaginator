import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:photo_taginator/models/tagged_image.dart';
import 'package:photo_taginator/providers/database_provider.dart';
import 'package:sqflite/sqflite.dart';

class TaggedImageProvider extends ChangeNotifier {
  final List<TaggedImage> images = [];
  late final Database database;

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
        add(TaggedImage(id: media.id));
      }
    }
    log("Gallery loaded");
  }

  void add(TaggedImage image) {
    images.add(image);
    notifyListeners();
  }
}
