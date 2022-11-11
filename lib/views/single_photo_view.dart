import 'dart:io';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:photo_taginator/models/tagged_image.dart';
import 'package:photo_taginator/providers/tag_provider.dart';
import 'package:photo_taginator/providers/tagged_image_provider.dart';
import 'package:photo_taginator/utils/dialogs.dart';
import 'package:photo_taginator/widgets/tag_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class SinglePhotoView extends StatefulWidget {
  SinglePhotoView({Key? key, required this.images, this.initialIndex = 0})
      : pageController = PageController(initialPage: initialIndex),
        super(key: key);

  final List<TaggedImage> images;
  final int initialIndex;
  final PageController pageController;

  @override
  State<StatefulWidget> createState() => _SinglePhotoViewState();
}

class _SinglePhotoViewState extends State<SinglePhotoView> {
  late int currentIndex = widget.initialIndex;
  bool showBottomMenu = false;

  Future<void> onTap(BuildContext context, int index, TaggedImage image) async {
    switch (index) {
      case 0:
        File file = await PhotoGallery.getFile(mediumId: image.id);
        await Share.shareXFiles([XFile(file.path)]);
        break;
      case 1:
        bool? result = await createRemoveDialog(
          context,
          "Remove image?",
          "Do you want to remove this image from your memory?",
        );
        if (result == true) {
          if (!mounted) return;
          Provider.of<TaggedImageProvider>(context, listen: false).remove(image);
          await Provider.of<TagProvider>(context, listen: false).removeImage(image);

          if (widget.images.isEmpty) {
            if (!mounted) return;
            Navigator.of(context).pop();
          }

          if (widget.images.length > currentIndex + 1) {
            setState(() {
              currentIndex++;
            });
          } else {
            setState(() {
              currentIndex--;
            });
          }
        }
        break;
      case 2:
        setState(() {
          showBottomMenu = !showBottomMenu;
        });
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(backButtonAction);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(backButtonAction);
    super.dispose();
  }

  bool backButtonAction(bool stopDefaultButtonEvent, RouteInfo info) {
    if (showBottomMenu) {
      setState(() {
        showBottomMenu = false;
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text('Gallery')),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) async => await onTap(context, index, widget.images[currentIndex]),
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.share), label: 'Share'),
          BottomNavigationBarItem(icon: Icon(Icons.delete), label: 'Remove'),
          BottomNavigationBarItem(icon: Icon(Icons.tag), label: 'Tag')
        ],
      ),
      body: Container(
        constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height),
        child: Column(children: [
          SizedBox(
            height: 32,
            child: Center(
              child: FutureBuilder<String?>(
                future: widget.images[currentIndex].getFilename(),
                builder: (context, snapshot) {
                  String text = snapshot.hasData ? snapshot.data! : "Image";
                  return Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black, fontSize: 16.0),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                PhotoViewGallery.builder(
                  scrollPhysics: const AlwaysScrollableScrollPhysics(),
                  itemCount: widget.images.length,
                  pageController: widget.pageController,
                  gaplessPlayback: true,
                  onPageChanged: (index) => setState(() => currentIndex = index),
                  scrollDirection: Axis.horizontal,
                  builder: (context, index) => PhotoViewGalleryPageOptions(
                      imageProvider: PhotoProvider(mediumId: widget.images[index].id),
                      initialScale: PhotoViewComputedScale.contained,
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 1.8),
                ),
                AnimatedPositioned(
                    curve: Curves.linear,
                    duration: const Duration(milliseconds: 300),
                    top: showBottomMenu ? 0 : height,
                    bottom: -20,
                    child: TagManager(widget.images[currentIndex]))
              ],
            ),
          )
        ]),
      ),
    );
  }
}
