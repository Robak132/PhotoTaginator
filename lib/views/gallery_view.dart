import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:photo_taginator/views/single_photo_view.dart';

class GalleryView extends StatefulWidget {
  const GalleryView({Key? key}) : super(key: key);

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> with AutomaticKeepAliveClientMixin<GalleryView> {
  final List<String> _images = [];
  bool _loading = false;

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
    _loading = true;
    if (!await _promptPermissionSetting()) {
      setState(() {
        _loading = false;
      });
    }

    List<Album> albums = await PhotoGallery.listAlbums(mediumType: MediumType.image);
    for (Album album in albums) {
      final List<Medium> mediums = (await album.listMedia()).items;
      for (Medium media in mediums) {
        if (!await checkCorruptedImage(media)) {
          setState(() {
            _images.add(media.id);
            _loading = false;
          });
        }
      }
    }
  }

  Future<bool> _promptPermissionSetting() async {
    if (Platform.isIOS && await Permission.storage.request().isGranted && await Permission.photos.request().isGranted ||
        Platform.isAndroid && await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }

  Future<bool> checkCorruptedImage(Medium media) async {
    try {
      await media.getThumbnail();
      return false;
    } catch (ex) {
      var corrupted = await media.getFile();
      log("Corrupted image: ${media.id}, path: ${corrupted.path}");
      return true;
    }
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
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: RefreshIndicator(
            onRefresh: () async => refreshNotWait(),
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : SafeArea(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                          child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 5,
                                ),
                                itemBuilder: (context, index) {
                                  return RawMaterialButton(
                                    child: InkWell(
                                      child: Ink.image(
                                        image: ThumbnailProvider(mediumId: _images[index], highQuality: true),
                                        height: 300,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SinglePhotoView(
                                                  galleryItems: _images,
                                                  initialIndex: index,
                                                )),
                                      );
                                    },
                                  );
                                },
                                itemCount: _images.length,
                              )))
                    ],
                  ))));
  }
}
