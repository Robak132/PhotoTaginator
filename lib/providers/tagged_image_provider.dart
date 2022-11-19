import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:photo_taginator/models/tagged_image.dart';
import 'package:unique_list/unique_list.dart';

class TaggedImageProvider extends ChangeNotifier {
  final UniqueList<TaggedImage> images = UniqueList();

  TaggedImageProvider() {
    promptPermissionSetting().then((value) {
      log("Permissions: $value");
      refresh();
    });
  }

  static Future<bool> promptPermissionSetting() async {
    if (Platform.isIOS && await Permission.storage.request().isGranted && await Permission.photos.request().isGranted ||
        Platform.isAndroid && await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }

  Future<void> refresh() async {
    images.clear();
    log("Loading gallery...");
    List<Album> albums = await PhotoGallery.listAlbums(mediumType: MediumType.image);
    for (Album album in albums) {
      final List<Medium> mediums = (await album.listMedia()).items;
      for (Medium media in mediums) {
        images.add(TaggedImage(media.id));
        super.notifyListeners();
      }
    }
    log("Gallery loaded");
  }

  void add(TaggedImage image) {
    images.add(image);
    notifyListeners();
  }

  void remove(TaggedImage image) {
    images.remove(image);
    notifyListeners();
  }

  @override
  void notifyListeners() {
    log("Reloading TaggedImageProvider...");
    super.notifyListeners();
  }
}
