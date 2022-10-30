import 'package:photo_taginator/models/tag.dart';

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
