import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

Widget buildImageLayer(String impactImageName) {
    AssetImage assetImage = AssetImage(impactImageName);
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