import 'package:flutter/material.dart';
import 'package:photo_taginator/models/tags_collection.dart';
import 'package:provider/provider.dart';

class TagDialog extends StatefulWidget {
  const TagDialog({
    super.key,
  });

  @override
  State<TagDialog> createState() => _TagDialogState();
}

class _TagDialogState extends State<TagDialog> {
  Map<String, bool> valuesMap = {};

  @override
  void initState() {
    super.initState();
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
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: Column(
            children: [
              Expanded(child: Consumer<TagCollection>(builder: (context, tagCollection, child) {
                final List<String> allTags = tagCollection.allTags;
                final List<String> currentTags = tagCollection.allTags;
                valuesMap = {for (String tag in allTags) tag: currentTags.contains(tag)};

                return ListView.builder(
                    itemCount: allTags.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String tag = allTags[index];
                      return CheckboxListTile(
                          title: Text(tag),
                          value: valuesMap[tag],
                          onChanged: (value) {
                            valuesMap[tag] = value!;
                          });
                    });
              })),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ],
          ),
        ));
  }
}
