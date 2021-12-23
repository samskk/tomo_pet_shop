import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:tomo_pet_shop/get_image.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late bool _loading;
  late XFile _image;
  late File image;
  late List _outputs = [];
  var p = '';
  var imagep;

  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  final ImagePicker _picker = ImagePicker();
  pickImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      print('hi');
    } else {
      print('hi1');
    }

    setState(() {
      _loading = true;

      _image = image!;
    });
    classifyImage(image!);
    // _classifyDog(image);
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
    if (output!.isEmpty) {
      reply = 'Cannot determine breed';
    } else if (output.length == 1) {
      breed = output[0]["label"].replaceAll('\t', ' ').substring(4);
      breed = breed[0].toUpperCase() + breed.substring(1);
      conf = (output[0]["confidence"] * 100).toStringAsFixed(0);
      reply = breed + ' (' + conf + '%)';
    } else if (output.length == 2) {
      breed = output[1]["label"].replaceAll('\t', ' ').substring(10);
      breed = breed[0].toUpperCase() + breed.substring(1);
      conf = (output[1]["confidence"] * 100).toStringAsFixed(0);
      reply = reply + '\n' + breed + ' (' + conf + '%)';
    } else {}

    print(output);
    print(output.length);
    setState(() {
      _loading = false;
      //Declare List _outputs in the class which will be used to show the classified classs name and confidence
      _outputs = output;
      var p1 = (_outputs[0]['confidence']);
      p = reply;
    });
  }

  Future<String> _classifyDog(XFile image) async {
    var resultList = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    print(resultList);
    if (resultList!.length == 0) return 'Cannot determine breed';

    String breed = resultList[0]["label"].replaceAll('\t', ' ').substring(10);
    breed = breed[0].toUpperCase() + breed.substring(1);
    String conf = (resultList[0]["confidence"] * 100).toStringAsFixed(0);
    String reply = breed + ' (' + conf + '%)';

    if (resultList.length > 1) {
      breed = resultList[1]["label"].replaceAll('\t', ' ').substring(10);
      breed = breed[0].toUpperCase() + breed.substring(1);
      conf = (resultList[1]["confidence"] * 100).toStringAsFixed(0);
      reply = reply + '\n' + breed + ' (' + conf + '%)';
    }
    print(reply);
    return reply;
  }

  final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
    onPrimary: Colors.grey,
    primary: Colors.black,
    minimumSize: const Size(275,40),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
    ),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: raisedButtonStyle,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GetImage()),
                );
              },
              child: const Text(
                'Add Image',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            imagep = Container(),
            _outputs != null
                ? Text(
                    p,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        background: Paint()..color = Colors.white,
                        fontWeight: FontWeight.bold),
                  )
                : Text("Classification Waiting")
          ],
        ),
      ),
    );
  }
}
