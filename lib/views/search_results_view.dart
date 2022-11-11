import 'package:flutter/material.dart';
import 'package:photo_taginator/models/tagged_image.dart';
import 'package:photo_taginator/providers/search_image_provider.dart';
import 'package:photo_taginator/widgets/gallery_widget.dart';
import 'package:provider/provider.dart';

class SearchResultsView extends StatefulWidget {
  const SearchResultsView({Key? key}) : super(key: key);

  @override
  State<SearchResultsView> createState() => _SearchGalleryViewState();
}

class _SearchGalleryViewState extends State<SearchResultsView> {
  @override
  void initState() {
    super.initState();
    Provider.of<SearchImageProvider>(context, listen: false).refreshAsync();
    Provider.of<SearchImageProvider>(context, listen: false).refreshAsync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
          title: const Text('Search Results')),
      body: Consumer<SearchImageProvider>(builder: (context, searchImageProvider, child) {
        List<TaggedImage> images = searchImageProvider.images;

        return RefreshIndicator(
          onRefresh: () async => searchImageProvider.refreshAsync(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[Expanded(child: GalleryWidget(images: images))],
          ),
        );
      }),
    );
  }
}
