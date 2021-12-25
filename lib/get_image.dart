// ignore_for_file: unnecessary_string_escapes

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class GetImage extends StatefulWidget {
  const GetImage({Key? key}) : super(key: key);

  @override
  _GetImageState createState() => _GetImageState();
}

class _GetImageState extends State<GetImage> {
  late bool isimage = false;
  late bool _loading;
  late bool isclassifed = false;
  late var _image;
  late var image;
  late List _outputs = [];
  var output;
  var result = '';

  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
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
        _loading = true;
        _image = image;
        classifyImage(image);
      });
    } else {
      print('hi1');
    }
  }

  pickImageFromGallery() async {
    isimage = false;
    image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        isimage = true;
        _loading = true;
        classifyImage(image);
      });
    } else {
      print('error form pickImageFromGallery ');
    }
  }

  classifyImage(XFile image) async {
    isclassifed = false;
    output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 3,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    isclassifed = true;
    String breed;
    String conf;
    String reply = '';
    try {
      if (output!.length == 1) {
        breed = output[0]["label"].replaceAll('\t', ' ').substring(2);
        breed = breed[0].toUpperCase() + breed.substring(1);
        conf = (output[0]["confidence"] * 100).toStringAsFixed(0);
        reply = breed + ' (' + conf + '%)';
      } else if (output.length == 2) {
        breed = output[0]["label"].replaceAll('\t', ' ').substring(2);
        breed = breed[0].toUpperCase() + breed.substring(1);
        conf = (output[0]["confidence"] * 100).toStringAsFixed(0);
        reply = breed + ' (' + conf + '%)';
        breed = output[1]["label"].replaceAll('\t', ' ').substring(2);
        breed = breed[0].toUpperCase() + breed.substring(1);
        conf = (output[1]["confidence"] * 100).toStringAsFixed(0);
        reply = reply + '\n' + breed + ' (' + conf + '%)';
      } else if (output.length == 3) {
        breed = output[0]["label"].replaceAll('\t', ' ').substring(2);
        breed = breed[0].toUpperCase() + breed.substring(1);
        conf = (output[0]["confidence"] * 100).toStringAsFixed(0);
        reply = breed + ' (' + conf + '%)';
        breed = output[1]["label"].replaceAll('\t', ' ').substring(2);
        breed = breed[0].toUpperCase() + breed.substring(1);
        conf = (output[1]["confidence"] * 100).toStringAsFixed(0);
        reply = reply + '\n' + breed + ' (' + conf + '%)';
        breed = output[2]["label"].replaceAll('\t', ' ').substring(2);
        breed = breed[0].toUpperCase() + breed.substring(1);
        conf = (output[2]["confidence"] * 100).toStringAsFixed(0);
        reply = reply + '\n' + breed + ' (' + conf + '%)';
      } else if (output.isEmpty) {
        reply = 'Cannot determine breed';
      }
    } catch (e) {
      reply = 'Cannot determine breed';
    }
    print(output);
    print(output!.length);
    setState(() {
      result = reply;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (!isimage)
              Column(
                children: [
                  getImageCamera(),
                  GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: .5,
                    mainAxisSpacing: .5,
                    shrinkWrap: true,
                    children: [
                      getImageGallery(),
                      Image.asset('assets/image/1.jpg', fit: BoxFit.cover),
                      Image.asset('assets/image/2.jpg', fit: BoxFit.cover),
                      Image.asset('assets/image/3.jpg', fit: BoxFit.cover),
                      Image.asset('assets/image/4.jpg', fit: BoxFit.cover),
                      Image.asset('assets/image/5.jpg', fit: BoxFit.cover),
                      Image.asset('assets/image/6.jpg', fit: BoxFit.cover),
                      Image.asset('assets/image/7.jpg', fit: BoxFit.cover),
                      Image.asset('assets/image/8.jpg', fit: BoxFit.cover),
                      Image.asset('assets/image/9.jpg', fit: BoxFit.cover),
                      Image.asset('assets/image/10.jpg', fit: BoxFit.cover),
                      Image.asset('assets/image/11.jpg', fit: BoxFit.cover),
                    ],
                    // children: List.generate(
                    //   11,
                    //   (index) {
                    //     return Padding(
                    //       padding: const EdgeInsets.all(1.0),
                    //       child: Container(
                    //         child: Text(index.toString()),
                    //         decoration: const BoxDecoration(
                    //           color: Colors.white,
                    //           borderRadius: BorderRadius.all(
                    //             Radius.circular(20.0),
                    //           ),
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // ),
                  )
                ],
              ),
            if (isimage)
              Column(
                children: [
                  SizedBox(
                    height: 650,
                    child: Column(
                      children: [
                        if (isimage) buildFileImage(),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          padding: const EdgeInsets.only(top: 50, bottom: 50),
                          decoration: const BoxDecoration(
                              color: Colors.grey,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
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

  Container getImageGallery() {
    return Container(
      height: 200,
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

  Container getImageCamera() {
    return Container(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Container(
          height: 80,
          width: 80,
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.all(
              Radius.circular(40.0),
            ),
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
      ),
      alignment: Alignment.center,
    );
  }

  Container getResultTap(int i) {
    var name = output[i]["label"].replaceAll('\t', ' ').substring(2);
    name = name[0].toUpperCase() + name.substring(1);
    var confidence = output[i]['confidence'];
    var confidencepercent =
        ' (' + (output[i]["confidence"] * 100).toStringAsFixed(0) + '%)';
    return Container(
        height: 70,
        // padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            Container(
              child: Image.asset('assets/image/1.jpg', fit: BoxFit.cover),
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15))),
            ),
            SizedBox(
              width: 220,
              child: Column(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        width: 140,
                        child: LinearProgressIndicator(
                          value: confidence,
                          minHeight: 2,
                          color: Colors.black,
                          backgroundColor: Colors.grey,
                        ),
                      ),
                      Text(
                        confidencepercent,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 50,
              height: 70,
              child: Icon(Icons.check_circle_outline,color: Colors.lime,),
            ),
          ],
        ));
  }

  Widget buildFileImage() => Container(
        margin: const EdgeInsets.only(top: 40, right: 10, left: 10, bottom: 5),
        height: 200,
        width: 300,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        child: Image.file(
          File(image.path),
          height: 200,
          width: 350,
          fit: BoxFit.cover,
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
      return const SizedBox(
        height: 70,
        child: Text(
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

class Resulttab extends StatelessWidget {
  Resulttab({
    Key? key,
    required this.output,
  }) : super(key: key);

  final List<dynamic> output;
  var name;
  var confidence;
  @override
  Widget build(BuildContext context) {
    name = output[0]["label"].replaceAll('\t', ' ').substring(2);
    name = name[0].toUpperCase() + name.substring(1);
    confidence = output[0]['confidence'];
    return Container(
        height: 70,
        color: Colors.amberAccent,
        // padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Text(
              name,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LinearProgressIndicator(
                value: confidence,
                minHeight: 2,
                color: Colors.black,
              ),
            ),
          ],
        ));
  }
}
