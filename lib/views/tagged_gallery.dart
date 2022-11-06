import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:photo_taginator/models/tag.dart';
import 'package:photo_taginator/models/tagged_image.dart';
import 'package:photo_taginator/providers/tag_provider.dart';
import 'package:photo_taginator/widgets/gallery_widget.dart';
import 'package:provider/provider.dart';

class TaggedGalleryView extends StatefulWidget {
  const TaggedGalleryView({Key? key}) : super(key: key);

  @override
  State<TaggedGalleryView> createState() => _TaggedGalleryViewState();
}

class _TaggedGalleryViewState extends State<TaggedGalleryView> with AutomaticKeepAliveClientMixin<TaggedGalleryView> {
  @override
  bool get wantKeepAlive => true;

  void search() {}

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text('Albums'),
          actions: <Widget>[IconButton(icon: const Icon(Icons.search), onPressed: search)]),
      body: Consumer<TagProvider>(builder: (context, tagProvider, child) {
        List<Tag> tags = tagProvider.notEmptyTags;

        return RefreshIndicator(
          onRefresh: () async => tagProvider.refresh(),
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: tags.length,
                      itemBuilder: (BuildContext context, int index) {
                        Tag tag = tags[index];

                        return Column(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              child:
                                  Center(child: Text(tags[index].name, style: Theme.of(context).textTheme.labelLarge)),
                            ),
                            GalleryWidget(
                                images: tag.images,
                                onImageError: (String imageID) {
                                  TaggedImage image = TaggedImage(imageID);
                                  log("Removing $image from database due to errors");
                                  tagProvider.removeImage(tag, image);
                                })
                          ],
                        );
                      }),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
