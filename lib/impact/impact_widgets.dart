import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class ImpactImage extends StatelessWidget {
  ImpactImage({@required this.image}) : assert(image != null);
  final String image;
  @override
  Widget build(BuildContext context) {
    AssetImage assetImage = AssetImage(image);
    return Row(
      children: <Widget>[
        Expanded(
          child: FadeInImage(
            placeholder: MemoryImage(kTransparentImage),
            image: assetImage,
            fit: BoxFit.fill,
          ),
        ),
      ],
    );
  }
}
