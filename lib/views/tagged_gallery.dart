import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_taginator/models/tag.dart';
import 'package:photo_taginator/models/tagged_image.dart';
import 'package:photo_taginator/providers/tag_provider.dart';
import 'package:photo_taginator/providers/tagged_image_provider.dart';
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

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refreshNotWait() {
    refresh();
  }

  Future<void> refresh() async {
    await _promptPermissionSetting();
  }

  Future<bool> _promptPermissionSetting() async {
    if (Platform.isIOS && await Permission.storage.request().isGranted && await Permission.photos.request().isGranted ||
        Platform.isAndroid && await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
          foregroundColor: Colors.black, backgroundColor: Colors.white, centerTitle: true, title: const Text('Albums')),
      body: RefreshIndicator(
        onRefresh: () async => refreshNotWait(),
        child: Consumer2<TagProvider, TaggedImageProvider>(builder: (context, tagProvider, taggedImageProvider, child) {
          List<TaggedImage> images = taggedImageProvider.images;
          List<Tag> tags = tagProvider.allTags;

          return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: tags.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Center(
                          child: Text(tags[index].name, style: Theme.of(context).textTheme.labelLarge),
                        ),
                      ),
                      GalleryWidget(images: images.sublist(9 * index, 9 * (index + 1)))
                    ]);
                  }),
            )
          ]);
        }),
      ),
    );
  }
}
