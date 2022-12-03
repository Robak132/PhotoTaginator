import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:photo_taginator/models/tagged_image.dart';
import 'package:photo_taginator/providers/tagged_image_provider.dart';
import 'package:photo_taginator/widgets/gallery_widget.dart';
import 'package:provider/provider.dart';

class GalleryView extends StatefulWidget {
  const GalleryView({Key? key}) : super(key: key);

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> with AutomaticKeepAliveClientMixin<GalleryView> {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text('Gallery')),
      body: Consumer<TaggedImageProvider>(builder: (context, taggedImageProvider, child) {
        List<TaggedImage> images = taggedImageProvider.images;

        return RefreshIndicator(
          onRefresh: () async => taggedImageProvider.refresh(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                  child: GalleryWidget(
                images: images,
                onImageError: (image) {
                  log("Removing $image from database due to errors");
                  taggedImageProvider.remove(image);
                },
              ))
            ],
          ),
        );
      }),
    );
  }
}
