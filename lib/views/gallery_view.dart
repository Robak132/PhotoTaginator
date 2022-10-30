import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:photo_taginator/providers/tagged_image_provider.dart';
import 'package:photo_taginator/views/single_photo_view.dart';
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Consumer<TaggedImageProvider>(builder: (context, taggedImageProvider, child) {
                        return GridView.builder(
                            itemCount: taggedImageProvider.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 5),
                            itemBuilder: (context, index) {
                              return RawMaterialButton(
                                  child: Ink.image(
                                      image:
                                          ThumbnailProvider(mediumId: taggedImageProvider[index].id, highQuality: true),
                                      height: 300,
                                      fit: BoxFit.cover),
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) => SinglePhotoView(initialIndex: index)));
                                  });
                            });
                      })))
            ])));
  }
}
