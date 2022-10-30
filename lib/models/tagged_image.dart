import 'package:photo_taginator/models/tag.dart';

class TaggedImage {
  String id;
  List<Tag> tags = [];

  TaggedImage({required this.id, tags = const <Tag>[]}) {
    this.tags.addAll(tags);
  }

  void setTags(List<Tag> tags) {
    this.tags = tags;
  }

  void addTag(Tag tag) {
    if (!tags.contains(tag)) {
      tags.add(tag);
    }
  }

  void removeTag(Tag tag) {
    tags.remove(tag);
  }

  bool containsTagName(String name) {
    return tags.any((tag) => tag.name == name);
  }
}
