import 'package:flutter/material.dart';
import 'package:photo_taginator/views/gallery_view.dart';
import 'package:photo_taginator/views/search_view.dart';
import 'package:photo_taginator/views/tagged_gallery.dart';

class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _bottomNavBarIndex = 1;
  PageController? _pageController;
  List<Widget> _views = [];

  @override
  void initState() {
    super.initState();
    _views = [const TaggedGalleryView(), const GalleryView(), const SearchView()];
    _pageController = PageController(initialPage: 1);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(controller: _pageController, physics: const NeverScrollableScrollPhysics(), children: _views),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.photo_album_rounded), label: 'Albums'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Gallery'),
            BottomNavigationBarItem(icon: Icon(Icons.image_search_outlined), label: 'Search'),
          ],
          currentIndex: _bottomNavBarIndex,
          selectedItemColor: Colors.green,
          onTap: (selectedPageIndex) {
            setState(() {
              _bottomNavBarIndex = selectedPageIndex;
              _pageController!.jumpToPage(selectedPageIndex);
            });
          }),
    );
  }
}
