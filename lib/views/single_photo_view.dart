import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:photo_taginator/dialogs/tag_dialog.dart';
import 'package:photo_taginator/models/image_collection.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

class SinglePhotoView extends StatefulWidget {
  SinglePhotoView({Key? key, this.initialIndex = 0})
      : pageController = PageController(initialPage: initialIndex),
        super(key: key);

  final int initialIndex;
  final PageController pageController;

  @override
  State<StatefulWidget> createState() => _SinglePhotoViewState();
}

class _SinglePhotoViewState extends State<SinglePhotoView> {
  late int currentIndex = widget.initialIndex;

  Future<void> onPageChanged(ImageCollection imageCollection, int index) async {
    // await imageCollection.fetchTags(imageCollection[index]);
    setState(() {
      currentIndex = index;
    });
  }

  void onTap(int index, ImageCollection imageCollection) {
    switch (index) {
      case 0:
      case 1:
      case 2:
        showDialog(context: context, builder: (context) => TagDialog(image: imageCollection[currentIndex]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageCollection>(builder: (context, imageCollection, child) {
      return Scaffold(
          bottomNavigationBar: BottomNavigationBar(
              onTap: (index) => onTap(index, imageCollection),
              backgroundColor: Colors.white,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.black,
              showUnselectedLabels: false,
              showSelectedLabels: false,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: Icon(Icons.share), label: 'Share'),
                BottomNavigationBarItem(icon: Icon(Icons.delete), label: 'Remove'),
                BottomNavigationBarItem(icon: Icon(Icons.tag), label: 'Tag')
              ]),
          body: Container(
              constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height),
              child: Stack(alignment: Alignment.center, children: <Widget>[
                PhotoViewGallery.builder(
                    scrollPhysics: const AlwaysScrollableScrollPhysics(),
                    itemCount: imageCollection.length,
                    pageController: widget.pageController,
                    gaplessPlayback: true,
                    onPageChanged: (index) => onPageChanged(imageCollection, index),
                    scrollDirection: Axis.horizontal,
                    builder: (context, index) => PhotoViewGalleryPageOptions(
                        imageProvider: PhotoProvider(mediumId: imageCollection[index].id),
                        initialScale: PhotoViewComputedScale.contained,
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 1.8)),
                Container(
                    padding: const EdgeInsets.all(40.0),
                    alignment: Alignment.topCenter,
                    child: Text("Image ${imageCollection[currentIndex]}",
                        textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 17.0)))
              ])));
    });
  }
}
