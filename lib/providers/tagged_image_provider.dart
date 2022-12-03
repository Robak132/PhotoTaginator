import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:photo_taginator/models/tagged_image.dart';
import 'package:photo_taginator/providers/database_provider.dart';
import 'package:sqflite/sqflite.dart';
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
    await PhotoGallery.cleanCache();
    log("Loading gallery...");
    List<Album> albums = await PhotoGallery.listAlbums(mediumType: MediumType.image);
    for (Album album in albums) {
      if (album.id == "__ALL__") {
        final List<Medium> mediums = (await album.listMedia()).items;
        for (Medium media in mediums) {
          await add(TaggedImage(media.id), true);
        }
        break;
      }
    }
    log("Gallery loaded");
  }

  Future<void> add(TaggedImage image, [silent = false]) async {
    Database database = await DatabaseProvider().getDatabase();
    await database.insert("IMAGES", {"ID": image.id}, conflictAlgorithm: ConflictAlgorithm.ignore);
    images.add(image);
    notifyListeners(silent);
  }

  void remove(TaggedImage image) {
    images.remove(image);
    notifyListeners();
  }

  @override
  void notifyListeners([silent = false]) {
    if (!silent) log("Reloading TaggedImageProvider...");
    super.notifyListeners();
  }
}
