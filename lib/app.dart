import 'package:flutter/material.dart';
import 'package:photo_taginator/models/image_collection.dart';
import 'package:photo_taginator/models/tags_collection.dart';
import 'package:provider/provider.dart';

import 'views/main_view.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<TagCollection>(create: (context) => TagCollection()),
      ChangeNotifierProvider<ImageCollection>(create: (context) => ImageCollection()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Taginator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MainView(),
    );
  }
}
