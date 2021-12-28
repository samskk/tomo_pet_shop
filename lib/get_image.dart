import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:tomo_pet_shop/widget/build_file_image.dart';
import 'package:tomo_pet_shop/widget/cannot_determine.dart';
import 'package:tomo_pet_shop/widget/done_button.dart';
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
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.height;
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
                        if (isimage)
                          BuildFileImage(
                            image: image,
                            screenWidth: screenWidth,
                            viewScreenHeight: viewScreenHeight,
                          ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
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
                  const DoneButton(),
                ],
              ),
          ],
        ),
      ),
    );
  }

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
      color: Colors.black,
      child: IconButton(
        iconSize: 50,
        color: Colors.white,
        icon: const Icon(Icons.photo_library_outlined),
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

  Widget displayResult() {
    if (output.isNotEmpty) {
      if (output.length == 1) {
        return Column(
          children: [
            getResultTap(0),
          ],
        );
      } else if (output.length == 2) {
        return Column(
          children: [
            getResultTap(0),
            getResultTap(1),
          ],
        );
      } else {
        return Column(
          children: [
            getResultTap(0),
            getResultTap(1),
            getResultTap(2),
          ],
        );
      }
    } else {
      return const CannotDetermine();
    }
  }
}
