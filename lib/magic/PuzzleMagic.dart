import 'dart:async';
import 'dart:ui' as ui show instantiateImageCodec, Codec, Image;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_puzzle/magic/ImageNode.dart';

class PuzzleMagic {
  ui.Image image;
  double eachWidth;
  double eachHeight;
  Size screenSize;
  double baseX;
  double baseY;

  int horizontal;
  int vertical;

  double eachBitmapWidth;
  double eachBitmapHeight;

  Future<ui.Image> init(String pathType, String path, Size size, int horizontal,
      int vertical) async {
    pathType == 'network'
        ? await getNetworkImage(path)
        : await getLocalImage(path);

    screenSize = size;
    this.horizontal = horizontal;
    this.vertical = vertical;

    eachWidth = screenSize.width * 0.8 / horizontal;
    eachHeight = screenSize.height * 0.3 / vertical;

    baseX = screenSize.width * 0.1;

    baseY = (screenSize.height - screenSize.width) * 0.5;

    eachBitmapWidth = image.width / horizontal;
    eachBitmapHeight = image.height / vertical;

    return image;
  }

  Future<ui.Image> getLocalImage(String path) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    FrameInfo frameInfo = await codec.getNextFrame();
    image = frameInfo.image;
    return image;
  }

  Future<ui.Image> getNetworkImage(String path) async {
    Completer<ImageInfo> completer = Completer();
    var img = new NetworkImage(path);
    img
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info);
    }));
    ImageInfo imageInfo = await completer.future;
    image = imageInfo.image;
    return image;
  }

  List<ImageNode> doTask() {
    List<ImageNode> list = [];
    for (int j = 0; j < vertical; j++) {
      for (int i = 0; i < horizontal; i++) {
        if ((j * vertical) + i + vertical < horizontal * vertical) {
          ImageNode node = ImageNode();
          node.rect = getOkRectF(i, j);
          node.index = j * horizontal + i;
          makeBitmap(node);
          list.add(node);
        }
      }
    }
    return list;
  }

  Rect getOkRectF(int i, int j) {
    return Rect.fromLTWH(
        baseX + eachWidth * i, baseY + eachWidth * j, eachWidth, eachWidth);
  }

  void makeBitmap(ImageNode node) {
    int i = node.getXIndex(horizontal);
    int j = node.getYIndex(horizontal);

    Rect rect = getShapeRect(i, j, eachBitmapWidth, eachBitmapHeight);

    rect = rect.shift(Offset(
        eachBitmapWidth.toDouble() * i, eachBitmapHeight.toDouble() * j));

    PictureRecorder recorder = PictureRecorder();
    double ww = eachBitmapWidth.toDouble();
    double hh = eachBitmapHeight.toDouble();

    Canvas canvas = Canvas(recorder, Rect.fromLTWH(0.0, 0.0, ww, hh));

    Rect rect2 = Rect.fromLTRB(0.0, 0.0, rect.width, rect.height);

    canvas.drawImageRect(image, rect, rect2, Paint());
    recorder
        .endRecording()
        .toImage(ww.floor(), hh.floor())
        .then((value) => node.image = value);
    node.rect = getOkRectF(i, j);
  }

  Rect getShapeRect(int i, int j, double width, double height) {
    return Rect.fromLTRB(0.0, 0.0, width, height);
  }
}
