import 'package:flutter/material.dart';
import 'package:photo_taginator/providers/search_image_provider.dart';
import 'package:photo_taginator/providers/tag_provider.dart';
import 'package:photo_taginator/providers/tagged_image_provider.dart';
import 'package:photo_taginator/views/main_view.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<TagProvider>(create: (context) => TagProvider()),
      ChangeNotifierProvider<TaggedImageProvider>(create: (context) => TaggedImageProvider()),
      ChangeNotifierProxyProvider<TagProvider, SearchImageProvider>(
          create: (BuildContext context) => SearchImageProvider(Provider.of<TagProvider>(context, listen: false)),
          update: (_, tagProvider, searchImageProvider) =>
              SearchImageProvider(tagProvider, searchImageFilter: searchImageProvider!.searchImageFilter))
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
