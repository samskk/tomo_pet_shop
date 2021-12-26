// ignore_for_file: unnecessary_string_escapes

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:tomo_pet_shop/widget/result_row.dart';

class GetImage extends StatefulWidget {
  const GetImage({Key? key}) : super(key: key);

  @override
  _GetImageState createState() => _GetImageState();
}

class _GetImageState extends State<GetImage> {
  late bool isimage = false;
  late bool isclassifed = false;
  late var image;
  var output;
  var result = '';

  @override
  void initState() {
    super.initState();

    loadModel().then((value) {
      setState(() {});
    });
  }

  final ImagePicker _picker = ImagePicker();
  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  pickImageFormCamera() async {
    isimage = false;
    image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        isimage = true;
        classifyImage(image);
      });
    }
  }

  pickImageFromGallery() async {
    isimage = false;
    image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        isimage = true;
        classifyImage(image);
      });
    }
  }

  classifyImage(XFile image) async {
    isclassifed = false;
    output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 3,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      isclassifed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final viewScreenHeight = screenHeight - statusBarHeight;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: statusBarHeight,
            ),
            if (!isimage)
              Column(
                children: [
                  getImageCamera(viewScreenHeight),
                  gridviewImage(viewScreenHeight)
                ],
              ),
            if (isimage)
              Column(
                children: [
                  SizedBox(
                    height: viewScreenHeight * .8,
                    child: Column(
                      children: [
                        if (isimage) buildFileImage(viewScreenHeight),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 5, left: 5),
                          padding: const EdgeInsets.only(top: 50, bottom: 50),
                          decoration: const BoxDecoration(
                              color: Color(0xffe4e9f5),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16))),
                          child: Column(
                            children: [
                              if (isclassifed) displayResult(),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      onPrimary: Colors.grey,
                      primary: Colors.black,
                      minimumSize: const Size(275, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  GridView gridviewImage(viewScreenHeight) {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: .5,
      mainAxisSpacing: .5,
      shrinkWrap: true,
      children: List.generate(
        12,
        (index) {
          var filename = "assets/image/" + index.toString() + ".jpg";
          return index == 0
              ? getImageGallery(viewScreenHeight)
              : Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Image.asset(filename, fit: BoxFit.cover),
                );
        },
      ),
    );
  }

  Container getImageGallery(viewScreenHeight) {
    return Container(
      height: viewScreenHeight * .8,
      color: Colors.grey,
      child: IconButton(
        iconSize: 50,
        icon: const Icon(Icons.image_search),
        onPressed: () {
          pickImageFromGallery();
        },
      ),
      alignment: Alignment.center,
    );
  }

  Container getImageCamera(viewScreenHeight) {
    return Container(
      height: viewScreenHeight * .25,
      child: Container(
        height: 80,
        width: 80,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
        ),
        child: IconButton(
          iconSize: 50,
          color: Colors.white,
          icon: const Icon(Icons.camera_alt_outlined),
          onPressed: () {
            pickImageFormCamera();
          },
        ),
      ),
      alignment: Alignment.center,
    );
  }

  Container getResultTap(int i) {
    var name = output[i]["label"].replaceAll('\t', ' ').substring(2);
    name = name[0].toUpperCase() + name.substring(1);
    var filename = output[i]["label"];

    filename = "assets/image/" + filename[0] + ".jpg";
    var confidence = output[i]['confidence'];
    var confidencepercent =
        ' (' + (output[i]["confidence"] * 100).toStringAsFixed(0) + '%)';
    return Container(
      child: ResultRow(
          filename: filename,
          name: name,
          confidence: confidence,
          confidencepercent: confidencepercent),
    );
  }

  Widget buildFileImage(viewScreenHeight) => SizedBox(
        width: 330,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(image.path),
            height: viewScreenHeight * .3,
            fit: BoxFit.cover,
          ),
        ),
      );

  displayResult() {
    if (output.isNotEmpty) {
      if (output.length == 1) {
        return Column(
          children: [
            getResultTap(0),
          ],
        );
      } else if (output.length == 2) {
        return Column(
          children: [getResultTap(0), getResultTap(1)],
        );
      } else {
        return Column(
          children: [getResultTap(0), getResultTap(1), getResultTap(2)],
        );
      }
    } else {
      return Container(
        alignment: Alignment.center,
        height: 70,
        margin: const EdgeInsets.all(8),
        child: const Text(
          'Cannot determine breed',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }
}
