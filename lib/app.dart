import 'package:flutter/material.dart';
import 'package:photo_taginator/providers/tag_provider.dart';
import 'package:photo_taginator/providers/tagged_image_provider.dart';
import 'package:provider/provider.dart';

import 'views/main_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<TagProvider>(create: (context) => TagProvider(), lazy: false),
      ChangeNotifierProvider<TaggedImageProvider>(create: (context) => TaggedImageProvider())
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
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const MainView(),
    );
  }
}
