import 'package:flutter/material.dart';
import 'package:photo_taginator/models/image_collection.dart';
import 'package:photo_taginator/models/tags_collection.dart';
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

  void onSubmit(ImageCollection imageCollection, Map<Tag, bool> valueMap) {
    // final filteredMap = [
    //   for (MapEntry<Tag, bool> entry in valueMap.entries)
    //     if (!entry.value) {"IMAGE_ID": widget.image.id, "TAG_ID": entry.key.id}
    // ];
    Navigator.pop(context);
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
            body: Consumer2<TagCollection, ImageCollection>(builder: (context, tagCollection, imageCollection, child) {
              final List<Tag> allTags = tagCollection.allTags;
              final Map<Tag, bool> valuesMap = {for (Tag tag in allTags) tag: widget.image.tags.contains(tag)};

              return Column(children: [
                Expanded(
                    child: ListView.builder(
                        itemCount: allTags.length,
                        itemBuilder: (BuildContext context, int index) {
                          return CheckboxListTile(
                              title: Text(allTags[index].name),
                              value: valuesMap[allTags[index]],
                              onChanged: (value) => valuesMap[allTags[index]] = value!);
                        })),
                ElevatedButton(onPressed: () => onSubmit(imageCollection, valuesMap), child: const Text('Submit'))
              ]);
            })));
  }
}
