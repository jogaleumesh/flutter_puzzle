import 'dart:async';
import 'dart:typed_data';
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

  int level;
  double eachBitmapWidth;
  double eachBitmapHeight;

  Future<ui.Image> init(String path, Size size, int level) async {
    await getImage(path);

    screenSize = size;
    this.level = level;
    eachWidth = screenSize.width * 0.8 / level;
    eachHeight = screenSize.height * 0.8 / (level - 1);

    baseX = screenSize.width * 0.1;

    baseY = (screenSize.height - screenSize.width) * 0.5;

    eachBitmapWidth = (image.width / level);
    eachBitmapHeight = (image.height / (level - 1));

    return image;
  }

  Future<ui.Image> getImage(String path) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    FrameInfo frameInfo = await codec.getNextFrame();
    image = frameInfo.image;
    return image;
  }

  List<ImageNode> doTask() {
    List<ImageNode> list = [];
    for (int j = 0; j < (level - 1); j++) {
      for (int i = 0; i < level; i++) {
        if (j * level + i + 1 < level * (level - 1)) {
          ImageNode node = ImageNode();
          node.rect = getOkRectF(i, j);
          node.index = j * level + i;
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
    int i = node.getXIndex(level);
    int j = node.getYIndex(level);

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
