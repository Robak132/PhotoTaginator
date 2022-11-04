import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:photo_taginator/models/tagged_image.dart';
import 'package:photo_taginator/views/single_photo_view.dart';

class GalleryWidget extends StatelessWidget {
  const GalleryWidget({
    Key? key,
    required this.images,
  }) : super(key: key);

  final List<TaggedImage> images;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GridView.builder(
        itemCount: images.length,
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 5),
        itemBuilder: (context, index) {
          return RawMaterialButton(
              child: Ink.image(
                  image: ThumbnailProvider(mediumId: images[index].id, highQuality: true),
                  height: 300,
                  fit: BoxFit.cover),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SinglePhotoView(initialIndex: index)));
              });
        },
      ),
    );
  }
}
