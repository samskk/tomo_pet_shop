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
  late bool _loading;
  late var _image;
  late File image;
  late List _outputs = [];
  var p = '';

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
    var image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _loading = true;
        _image = image;
        classifyImage(image);
      });
    } else {
      print('hi1');
    }
  }

  pickImageFromGallery() async {
    final imageXfile = await _picker.pickImage(source: ImageSource.gallery);
    var path1 = imageXfile!.path;
    if (image != null) {
     
      final bytes = await File(path1).readAsBytes();
      final img.Image? image = img.decodeImage(bytes);
      setState(() {
        _loading = true;
        _image = image!;
        classifyImage(imageXfile);
      });
    } else {
      print('error form pickImageFromGallery ');
    }
  }

  classifyImage(XFile image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 3,
      threshold: 0.005,
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
      }
    } catch (e) {
      reply = 'Cannot determine breed';
    }

    // else{
    //    reply = 'Cannot determine breed';
    // }

    print(output);
    print(output!.length);
    setState(() {
      _loading = false;
      p = reply;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 60,
          ),
          Row(
            children: [
              Container(
                child: FloatingActionButton(
                  child: const Icon(Icons.camera),
                  onPressed: () {
                    pickImageFormCamera();
                  },
                ),
                alignment: Alignment.center,
              ),
              Container(
                child: FloatingActionButton(
                  child: const Icon(Icons.image),
                  onPressed: () {
                    pickImageFromGallery();
                  },
                ),
                alignment: Alignment.center,
              ),
              _image=Container()
            ],
          ),
          Text(p),
        ],
      ),
    );
  }
}
