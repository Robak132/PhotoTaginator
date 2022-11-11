import 'package:photo_taginator/models/tag.dart';
import 'package:unique_list/unique_list.dart';

class SearchImageFiler {
  UniqueList<Tag>? whiteList;
  UniqueList<Tag>? blackList;

  SearchImageFiler({this.blackList, this.whiteList});

  factory SearchImageFiler.from(Map<Tag, bool?> valueMap) {
    UniqueList<Tag> blackList = UniqueList();
    UniqueList<Tag> whiteList = UniqueList();
    for (MapEntry<Tag, bool?> entry in valueMap.entries) {
      if (entry.value == false) {
        blackList.add(entry.key);
      }
      if (entry.value == true) {
        whiteList.add(entry.key);
      }
    }
    return SearchImageFiler(blackList: blackList, whiteList: whiteList);
  }

  bool test(List<int> tagIDs) {
    // Whitelist
    for (Tag tag in whiteList ?? []) {
      if (!tagIDs.contains(tag.id)) {
        return false;
      }
    }

    // Blacklist
    for (Tag tag in blackList ?? []) {
      if (tagIDs.contains(tag.id)) {
        return false;
      }
    }
    return true;
  }
}
