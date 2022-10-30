import 'package:flutter/material.dart';
import 'package:photo_taginator/models/tag.dart';
import 'package:photo_taginator/models/tagged_image.dart';
import 'package:photo_taginator/providers/tag_provider.dart';
import 'package:photo_taginator/providers/tagged_image_provider.dart';
import 'package:provider/provider.dart';

class TagDialog extends StatefulWidget {
  final TaggedImage image;

  const TagDialog({super.key, required this.image});

  @override
  State<TagDialog> createState() => _TagDialogState();
}

class _TagDialogState extends State<TagDialog> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> onSubmit(BuildContext context) async {
    await Provider.of<TaggedImageProvider>(context, listen: false).update(widget.image);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void onChanged(Map<Tag, bool> valuesMap, Tag tag, bool newValue) {
    if (newValue) {
      widget.image.addTag(tag);
    } else {
      widget.image.removeTag(tag);
    }
    valuesMap[tag] = newValue;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        insetPadding: const EdgeInsets.only(top: 100, bottom: 100, left: 50, right: 50),
        child: Scaffold(
            appBar: AppBar(
                automaticallyImplyLeading: false,
                flexibleSpace: Container(),
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                centerTitle: true,
                title: const Text('Manage Tags'),
                iconTheme: const IconThemeData(color: Colors.black)),
            body: Consumer2<TagProvider, TaggedImageProvider>(
                builder: (context, tagProvider, taggedImageProvider, child) {
              List<Tag> tags = tagProvider.allTags;
              Map<Tag, bool> valuesMap = {for (Tag tag in tags) tag: widget.image.tags.contains(tag)};

              return Column(children: [
                Expanded(
                    child: ListView.builder(
                        itemCount: tags.length,
                        itemBuilder: (BuildContext context, int index) {
                          return CheckboxListTile(
                              title: Text(tags[index].name),
                              value: valuesMap[tags[index]],
                              onChanged: (value) => onChanged(valuesMap, tags[index], value!));
                        })),
                ElevatedButton(onPressed: () async => onSubmit(context), child: const Text('Done'))
              ]);
            })));
  }
}
