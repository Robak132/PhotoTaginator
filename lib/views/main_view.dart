import 'package:flutter/material.dart';
import 'package:photo_taginator/views/gallery.dart';

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
    _views = [Container(), const Gallery(), Container()];
    _pageController = PageController(initialPage: _bottomNavBarIndex);
  }

  @override
  void dispose() {
    _pageController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text('Gallery'),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        // Body area
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _views,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Tags',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Gallery',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_album_rounded),
              label: 'Albums',
            ),
          ],
          currentIndex: _bottomNavBarIndex,
          selectedItemColor: Colors.amber,
          onTap: (selectedPageIndex) {
            setState(() {
              _bottomNavBarIndex = selectedPageIndex;
              _pageController!.jumpToPage(selectedPageIndex);
            });
          },
        ));
  }
}
