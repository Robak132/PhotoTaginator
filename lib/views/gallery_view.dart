import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
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
          automaticallyImplyLeading: false,
          flexibleSpace: Container(),
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text('Gallery'),
          iconTheme: const IconThemeData(color: Colors.black)),
      body: RefreshIndicator(
        onRefresh: () async => refreshNotWait(),
        child: Consumer<TaggedImageProvider>(builder: (context, taggedImageProvider, child) {
          List<TaggedImage> images = taggedImageProvider.images;
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
            Expanded(child: GalleryWidget(images: images)),
          ]);
        }),
      ),
    );
  }
}
