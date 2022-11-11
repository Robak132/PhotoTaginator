import 'package:flutter/material.dart';
import 'package:photo_taginator/models/tag.dart';
import 'package:photo_taginator/models/tagged_image.dart';
import 'package:photo_taginator/providers/tag_provider.dart';
import 'package:photo_taginator/utils/dialogs.dart';
import 'package:provider/provider.dart';

class TagManager extends StatefulWidget {
  const TagManager(this.image, {super.key, this.callback});
  final Function? callback;
  final TaggedImage image;

  @override
  State<TagManager> createState() => _TagManagerState();
}

class _TagManagerState extends State<TagManager> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> onChanged(TagProvider tagProvider, Map<Tag, bool> valuesMap, Tag tag, bool newValue) async {
    if (newValue) {
      widget.image.addTag(tag);
      await tagProvider.addImage(tag, widget.image);
    } else {
      widget.image.removeTag(tag);
      await tagProvider.removeImage(tag, widget.image);
    }
    valuesMap[tag] = newValue;
  }

  Future<void> onAdded(BuildContext context, TagProvider tagProvider) async {
    String? name = await createAddDialog(context, controller, "New tag", "Enter tag's name");
    if (name != null && name != "") {
      await tagProvider.add(name);
    }
  }

  Future<void> onRemoved(BuildContext context, TagProvider tagProvider, Tag tag) async {
    bool? status = await createRemoveDialog(context, "Delete tag?", "Do you want to remove \"${tag.name}\" tag?");
    if (status != null && status) {
      await tagProvider.remove(tag);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TagProvider>(builder: (context, tagProvider, child) {
      List<Tag> tags = tagProvider.tags;
      Map<Tag, bool> valuesMap = {for (Tag tag in tags) tag: widget.image.tags.contains(tag)};

      return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        child: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(15),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height - 275,
                child: ListView.builder(
                  itemCount: tags.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onLongPress: () => onRemoved(context, tagProvider, tags[index]),
                      child: CheckboxListTile(
                        title: Text(tags[index].name),
                        value: valuesMap[tags[index]],
                        onChanged: (value) => onChanged(tagProvider, valuesMap, tags[index], value!),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 28,
                child: FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () => onAdded(context, tagProvider),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
