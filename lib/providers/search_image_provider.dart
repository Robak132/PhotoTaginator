import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:photo_taginator/models/tagged_image.dart';
import 'package:photo_taginator/providers/database_provider.dart';
import 'package:photo_taginator/utils/search_image_filter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unique_list/unique_list.dart';

class SearchImageProvider extends ChangeNotifier {
  final UniqueList<TaggedImage> images = UniqueList();
  SearchImageFiler searchImageFilter = SearchImageFiler();

  SearchImageProvider({SearchImageFiler? searchImageFilter}) {
    if (searchImageFilter != null) {
      this.searchImageFilter = searchImageFilter;
    }
    refresh();
  }

  Future<void> refresh() async {
    images.clear();
    Database database = await DatabaseProvider().getDatabase();
    log("Loading search results...");
    List<Map<String, Object?>> query = await database.rawQuery(
        "SELECT ID, (SELECT GROUP_CONCAT(C.TAG_ID) FROM CONNECTIONS C WHERE C.IMAGE_ID=ID) AS TAGS FROM IMAGES");
    for (Map<String, Object?> map in query) {
      TaggedImage image = TaggedImage(map["ID"] as String);
      List<String> tagsString = (map["TAGS"] == null) ? [] : (map["TAGS"] as String).split(",");
      List<int> tags = [for (String id in tagsString) int.parse(id)];

      if (searchImageFilter.test(tags)) {
        images.add(image);
        notifyListeners();
      }
    }
    log("Search results loaded...");
  }

  void setSearchFilter(SearchImageFiler searchImageFiler) {
    searchImageFilter = searchImageFiler;
    refresh();
  }
}
