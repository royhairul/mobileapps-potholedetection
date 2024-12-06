import 'package:camera/camera.dart';
import 'package:pothole_detector/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pothole_detector/shared/widgets/custom_button.dart';

class LiveDetectorView extends StatelessWidget {
  const LiveDetectorView({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text("Live Detector"),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white
        ),
        backgroundColor: Colors.indigo[800]!,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:  CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.white,
            ),
            SizedBox(height: 20),
            AppButton(text: 'Turn On Camera', onPressed: () {}),
            SizedBox(height: 20),
            AppButton(text: 'Turn Off Camera', onPressed: () {})
          ],
        ),
      )
    );
  }
}
