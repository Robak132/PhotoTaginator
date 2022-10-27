import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';

import 'single_photo_view.dart';

class Gallery extends StatefulWidget {
  const Gallery({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  List<String> finalImages = [];
  bool _loading = false;
  List<int> data = [];

  @override
  void initState() {
    super.initState();
    _loading = true;
    initAsync();
  }

  Future<void> initAsync() async {
    if (!await _promptPermissionSetting()) {
      setState(() {
        _loading = false;
      });
      return;
    }

    List<Album> albums = await PhotoGallery.listAlbums(mediumType: MediumType.image);
    for (Album album in albums) {
      final List<Medium> mediums = (await album.listMedia()).items;
      for (Medium media in mediums) {
        if (!await checkCorruptedImage(media)) {
          setState(() {
            finalImages.add(media.id);
            _loading = false;
          });
        }
      }
    }
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

  Future<bool> _promptPermissionSetting() async {
    if (Platform.isIOS && await Permission.storage.request().isGranted && await Permission.photos.request().isGranted ||
        Platform.isAndroid && await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      // Body area
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
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
                                  image: ThumbnailProvider(mediumId: finalImages[index], highQuality: true),
                                  height: 300,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SinglePhotoView(
                                            galleryItems: finalImages,
                                            backgroundDecoration: const BoxDecoration(
                                              color: Colors.black,
                                            ),
                                            initialIndex: index,
                                            scrollDirection: Axis.horizontal,
                                          )),
                                );
                              },
                            );
                          },
                          itemCount: finalImages.length,
                        )))
              ],
            )),
    );
  }
}
