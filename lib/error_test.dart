import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as uilib;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';

final imageCaptureglobalKey = GlobalKey();

class CaptureFailureDemoPage extends StatefulWidget {
  @override
  _CaptureFailureDemoPageState createState() => _CaptureFailureDemoPageState();
}

class _CaptureFailureDemoPageState extends State<CaptureFailureDemoPage> {
  File imageFile;
  bool repeatTest;
  int triedCount = 0;
  int failedCount = 0;
  int totalSuccessByteSize = 0;
  int totalFailureByteSize = 0;

  String results = "";

  void openGallery(context) async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxWidth: 1600);
    if (image != null) {
      setState(() {
        imageFile = image;
      });
    }
  }

  void addResult(size) {
    triedCount++;
    if (size < 200000) {
      totalFailureByteSize += size;
      failedCount++;
      results += '[$triedCount $size]';
    } else {
      totalSuccessByteSize += size;
    }
    setState(() {});
  }

  Future<int> captureAndReturnLength() async {
    RenderRepaintBoundary boundary =
        imageCaptureglobalKey.currentContext.findRenderObject();
    uilib.Image image = await boundary.toImage(pixelRatio: 3);
    ByteData byteData =
        await image.toByteData(format: uilib.ImageByteFormat.png);
    return byteData.lengthInBytes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Test Edit')),
      body: Column(
        children: [
          Stack(
            children: [
              RepaintBoundary(
                key: imageCaptureglobalKey,
                child: Container(
                  height: 300,
                  child: Stack(children: [
                    imageFile != null ? Image.file(imageFile) : Container(),
                    imageFile != null
                        ? Image.file(imageFile, width: 100)
                        : Container(),
                  ]),
                ),
              ),
              getButtons()
            ],
          ),
          getStatistics(),
          Container(width: 400, color: Colors.yellow[50], child: Text(results)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () async {
          int capturedImageSize = await captureAndReturnLength();
          addResult(capturedImageSize);
        },
      ),
    );
  }

  Widget getStatistics() {
    int failRate =
        failedCount > 0 ? (failedCount / triedCount * 100).toInt() : 0;
    int successCount = triedCount - failedCount;
    int avgSuccSize = successCount > 0
        ? (totalSuccessByteSize / (triedCount - failedCount)).toInt()
        : 0;
    int avgFailSize =
        failedCount > 0 ? (totalFailureByteSize / (failedCount)).toInt() : 0;
    return Text(
        "Fail%=$failRate  avgSuccSize=$avgSuccSize avgFailSize=$avgFailSize");
  }

  Widget getButtons() {
    return Row(children: [
      RaisedButton(
        child: Text('Load Image'),
        onPressed: () {
          openGallery(context);
        },
      ),
      RaisedButton(
        child: Text('Start Test'),
        onPressed: () async {
          results = "";
          repeatTest = true;
          while (repeatTest) {
            int length = await captureAndReturnLength();
            addResult(length);
          }
        },
      ),
      RaisedButton(
        child: Text('Stop Test'),
        onPressed: () {
          setState(() {
            repeatTest = false;
          });
        },
      )
    ]);
  }
}
