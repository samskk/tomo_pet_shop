import 'dart:io';

import 'package:flutter/material.dart';

class BuildFileImage extends StatelessWidget {
  const BuildFileImage({
    Key? key,
    required this.viewScreenHeight,
    required this.screenWidth,
    required this.image,
  }) : super(key: key);
  final double viewScreenHeight;
  final double screenWidth;
  final dynamic image;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(image.path),
          width: screenWidth,
          height: viewScreenHeight * .3,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
