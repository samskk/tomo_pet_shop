import 'package:flutter/material.dart';

class ResultRow extends StatelessWidget {
  const ResultRow({
    Key? key,
    required this.name,
    required this.confidence,
    required this.confidencepercent,
    required this.filename,
  }) : super(key: key);

  final String filename;
  final String name;
  final double confidence;
  final String confidencepercent;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 70,
        // padding: const EdgeInsets.only(right: 2),
        margin: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            Container(
              width: 90,
              height: 70,
              padding: const EdgeInsets.all(5),
              child: ClipRRect(
                child: Image.asset(filename, fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(23),
              ),
            ),
            SizedBox(
              width: 190,
              child: Column(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 9,
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(right: 5),
                        width: 130,
                        child: LinearProgressIndicator(
                          value: confidence,
                          minHeight: 5,
                          color: Colors.black,
                          backgroundColor: const Color(0xffcad4ee),
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
              child: Icon(
                Icons.check_circle_outline,
                color: Color(0xffcad4ee),
              ),
            ),
          ],
        ));
  }
}
