// ignore_for_file: unnecessary_string_escapes

import 'dart:io';
import 'package:tflite/tflite.dart';
import 'package:image/image.dart' as img;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GetImage extends StatefulWidget {
  const GetImage({Key? key}) : super(key: key);

  @override
  _GetImageState createState() => _GetImageState();
}

class _GetImageState extends State<GetImage> {
  late bool isimage = false;
  late bool _loading;
  late var _image;
  late var image;
  late List _outputs = [];
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
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 3,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
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
      body: Column(
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
                      Text(
                        result,
                        style: const TextStyle(
                          fontSize:20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget buildFileImage() => Container(
        margin: const EdgeInsets.only(top: 40, right: 10, left: 10),
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
}
