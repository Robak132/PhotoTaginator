import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:photo_taginator/dialogs/tag_dialog.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class SinglePhotoView extends StatefulWidget {
  SinglePhotoView({Key? key, this.initialIndex = 0, required this.galleryItems})
      : pageController = PageController(initialPage: initialIndex),
        super(key: key);

  final int initialIndex;
  final PageController pageController;
  final List<String> galleryItems;

  @override
  State<StatefulWidget> createState() => _SinglePhotoViewState();
}

class _SinglePhotoViewState extends State<SinglePhotoView> {
  late int currentIndex = widget.initialIndex;

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  List<String> allCities = ['Alpha', 'Beta', 'Gamma'];
  List<String> selectedCities = [];

  void onTap(int index) {
    switch (index) {
      case 0:
      case 1:
      case 2:
        showDialog(
            context: context,
            builder: (context) {
              return TagDialog(
                  cities: allCities,
                  selectedCities: selectedCities,
                  onSelectedCitiesListChanged: (cities) {
                    selectedCities = cities;
                  });
            });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTap,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.share), label: 'Share'),
          BottomNavigationBarItem(icon: Icon(Icons.delete), label: 'Remove'),
          BottomNavigationBarItem(
            icon: Icon(Icons.tag),
            label: 'Tag',
          ),
        ],
      ),
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: _buildItem,
              itemCount: widget.galleryItems.length,
              pageController: widget.pageController,
              onPageChanged: onPageChanged,
              scrollDirection: Axis.horizontal,
            ),
            Container(
              padding: const EdgeInsets.all(40.0),
              alignment: Alignment.topCenter,
              child: Text(
                "Image ${widget.galleryItems[currentIndex]}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17.0,
                  decoration: null,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    String item = widget.galleryItems[index];

    return PhotoViewGalleryPageOptions(
      imageProvider: PhotoProvider(mediumId: item),
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 1.8,
    );
  }
}
