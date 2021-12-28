import 'package:flutter/widgets.dart';

class CannotDetermine extends StatelessWidget {
  const CannotDetermine({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
