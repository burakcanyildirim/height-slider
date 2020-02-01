import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:height_slider/src/height_slider_interal.dart';

class HeightSlider extends StatefulWidget {
  final int maxHeight;
  final int minHeight;
  final int height;
  final ValueChanged<int> onChange;
  final String personImagePath;

  const HeightSlider(
      {Key key,
      @required this.height,
      @required this.onChange,
      this.maxHeight = 190,
      this.minHeight = 145,
      this.personImagePath})
      : super(key: key);

  int get totalUnits => maxHeight - minHeight;

  @override
  _HeightSliderState createState() => _HeightSliderState();
}

class _HeightSliderState extends State<HeightSlider> {
  double startDragYOffset;
  int startDragHeight;
  double widgetHeight = 50;
  double labelFontSize = 12.0;

  double get _pixelsPerUnit {
    return _drawingHeight / widget.totalUnits;
  }

  double get _sliderPosition {
    double halfOfBottomLabel = labelFontSize / 2;
    int unitsFromBottom = widget.height - widget.minHeight;
    return halfOfBottomLabel + unitsFromBottom * _pixelsPerUnit;
  }

  double get _drawingHeight {
    double totalHeight = this.widgetHeight;
    double marginBottom = 12.0;
    double marginTop = 12.0;
    return totalHeight - (marginBottom + marginTop + labelFontSize);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: LayoutBuilder(builder: (context, constraints) {
        this.widgetHeight = constraints.maxHeight;
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: this._onTapDown,
          onVerticalDragStart: this._onDragStart,
          onVerticalDragUpdate: this._onDragUpdate,
          child: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              _drawPersonImage(),
              _drawSlider(),
              _drawLabels(),
            ],
          ),
        );
      }),
    );
  }

  _onTapDown(TapDownDetails tapDownDetails) {
    int height = _globalOffsetToHeight(tapDownDetails.globalPosition);
    widget.onChange(_normalizeHeight(height));
  }

  int _normalizeHeight(int height) {
    return math.max(widget.minHeight, math.min(widget.maxHeight, height));
  }

  int _globalOffsetToHeight(Offset globalOffset) {
    RenderBox getBox = context.findRenderObject();
    Offset localPosition = getBox.globalToLocal(globalOffset);
    double dy = localPosition.dy;
    dy = dy - 12.0 - labelFontSize / 2;
    int height = widget.maxHeight - (dy ~/ _pixelsPerUnit);
    return height;
  }

  _onDragStart(DragStartDetails dragStartDetails) {
    int newHeight = _globalOffsetToHeight(dragStartDetails.globalPosition);
    widget.onChange(newHeight);
    setState(() {
      startDragYOffset = dragStartDetails.globalPosition.dy;
      startDragHeight = newHeight;
    });
  }

  _onDragUpdate(DragUpdateDetails dragUpdateDetails) {
    double currentYOffset = dragUpdateDetails.globalPosition.dy;
    double verticalDifference = startDragYOffset - currentYOffset;
    int diffHeight = verticalDifference ~/ _pixelsPerUnit;
    int height = _normalizeHeight(startDragHeight + diffHeight);
    setState(() => widget.onChange(height));
  }

  Widget _drawSlider() {
    return Positioned(
      child: HeightSliderInteral(height: widget.height),
      left: 0.0,
      right: 0.0,
      bottom: _sliderPosition,
    );
  }

  Widget _drawLabels() {
    int labelsToDisplay = widget.totalUnits ~/ 5 + 1;
    List<Widget> labels = List.generate(
      labelsToDisplay,
      (idx) {
        return Text(
          "${widget.maxHeight - 5 * idx}",
          style: TextStyle(
            color: const Color.fromRGBO(216, 217, 223, 1.0),
            fontSize: labelFontSize,
          ),
        );
      },
    );

    return Align(
      alignment: Alignment.centerRight,
      child: IgnorePointer(
        child: Padding(
          padding: EdgeInsets.only(
            right: 12.0,
            bottom: 12.0,
            top: 12.0,
          ),
          child: Column(
            children: labels,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
        ),
      ),
    );
  }

  Widget _drawPersonImage() {
    double personImageHeight = _sliderPosition + 12.0;
    if (widget.personImagePath == null) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: SvgPicture.asset(
          "images/person.svg",
          package: 'height_slider',
          height: personImageHeight,
          width: personImageHeight / 3,
        ),
      );
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: SvgPicture.asset(
        widget.personImagePath,
        height: personImageHeight,
        width: personImageHeight / 3,
      ),
    );
  }
}