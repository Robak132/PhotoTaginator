import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:photo_taginator/models/tagged_image.dart';

class TaggedImageProvider extends ChangeNotifier {
  final List<TaggedImage> images = [];

  TaggedImageProvider() {
    refresh();
  }

  Future<void> refresh() async {
    images.clear();
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
