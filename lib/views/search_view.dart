import 'package:flutter/material.dart';
import 'package:photo_taginator/models/tag.dart';
import 'package:photo_taginator/providers/search_image_provider.dart';
import 'package:photo_taginator/providers/tag_provider.dart';
import 'package:photo_taginator/utils/search_image_filter.dart';
import 'package:photo_taginator/views/search_results_view.dart';
import 'package:provider/provider.dart';

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> with AutomaticKeepAliveClientMixin<SearchView> {
  Map<Tag, bool?> searchMap = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    searchMap = {for (Tag tag in Provider.of<TagProvider>(context, listen: false).tags) tag: false};
    super.didChangeDependencies();
  }

  void onPressed() {
    SearchImageFiler searchImageFiler = SearchImageFiler.from(searchMap);
    Provider.of<SearchImageProvider>(context, listen: false).setSearchFilter(searchImageFiler);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchResultsView()));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Search'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(onPressed: onPressed, child: const Icon(Icons.search)),
      body: Consumer<TagProvider>(builder: (context, tagProvider, child) {
        List<Tag> tags = tagProvider.tags;
        return RefreshIndicator(
          onRefresh: () async => await tagProvider.refresh(),
          child: ListView.builder(
              itemCount: tags.length,
              itemBuilder: (BuildContext context, int index) {
                return CheckboxListTile(
                    title: Text(tags[index].name),
                    tristate: true,
                    value: searchMap[tags[index]],
                    onChanged: (value) {
                      setState(() {
                        searchMap[tags[index]] = value;
                      });
                    });
              }),
        );
      }),
    );
  }
}
