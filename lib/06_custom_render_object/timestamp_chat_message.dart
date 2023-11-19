import 'dart:math' as math;

import 'package:flutter/material.dart';

class TimestampedChatMessage extends LeafRenderObjectWidget {
  const TimestampedChatMessage({
    super.key,
    required this.text,
    required this.sentAt,
    required this.textStyle,
    required this.sentAtTextStyle,
  });

  final String text;
  final String sentAt;
  final TextStyle textStyle;
  final TextStyle sentAtTextStyle;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return TimestampedChatMessageRenderObject(
      text: text,
      sentAt: sentAt,
      textStyle: textStyle,
      sentAtTextStyle: sentAtTextStyle,
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, TimestampedChatMessageRenderObject renderObject) {
    renderObject
      ..sentAt = sentAt
      ..text = text
      ..textStyle = textStyle
      ..sentAtTextStyle = sentAtTextStyle
      ..textDirection = Directionality.of(context);
  }
}

class TimestampedChatMessageRenderObject extends RenderBox {
  TimestampedChatMessageRenderObject({
    required String text,
    required String sentAt,
    required TextStyle textStyle,
    required TextStyle sentAtTextStyle,
    required TextDirection textDirection,
  }) {
    _text = text;
    _sentAt = sentAt;
    _textStyle = textStyle;
    _sentAtTextStyle = sentAtTextStyle;
    _textDirection = textDirection;

    _textPainter = TextPainter(
      text: TextSpan(text: _text, style: _textStyle),
      textDirection: _textDirection,
    );
    _sendAtTextPainter = TextPainter(
      text: TextSpan(text: _sentAt, style: _sentAtTextStyle),
      textDirection: _textDirection,
    );
  }

  late String _text;
  late String _sentAt;
  late TextStyle _textStyle;
  late TextStyle _sentAtTextStyle;
  late TextDirection _textDirection;

  late TextPainter _textPainter;
  late TextPainter _sendAtTextPainter;

  late double _lineHeight;
  late double _lastMessageLineWidth;
  late bool _sentAtFitsOnLastLine;
  double _longestLineWidth = 0;
  late double _sentAtLineWidth;
  late double _sentAtLineHeight;
  late int _numMessageLines;

  set text(String value) {
    if (value == _text) return;
    _text = value;
    _textPainter.text = textTextSpan;
    markNeedsLayout();
    // Because changing any text in our widget will definitely change the
    // semantic meaning of this piece of our UI, we need to call
    markNeedsSemanticsUpdate();
  }

  set sentAt(String value) {
    if (value == _sentAt) return;
    _sentAt = value;
    _sendAtTextPainter.text = sendAtTextSpan;
    markNeedsLayout();

    // Because changing any text in our widget will definitely change the
    // semantic meaning of this piece of our UI, we need to call
    markNeedsSemanticsUpdate();
  }

  set textStyle(TextStyle value) {
    if (value == _textStyle) return;
    _textStyle = value;
    _textPainter.text = textTextSpan;
    markNeedsLayout();
    markNeedsPaint();
  }

  set sentAtTextStyle(TextStyle value) {
    if (value == _sentAtTextStyle) return;
    _sentAtTextStyle = value;
    _sendAtTextPainter.text = sendAtTextSpan;
    markNeedsLayout();
    markNeedsPaint();
  }

  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    _textPainter.textDirection = value;
    _sendAtTextPainter.textDirection = value;
    markNeedsLayout();
    markNeedsPaint();
  }

  TextSpan get textTextSpan => TextSpan(text: _text, style: _textStyle);
  TextSpan get sendAtTextSpan => TextSpan(text: _sentAt, style: _sentAtTextStyle);

  Size _performTextLayout(double maxWidth) {
    if (_textPainter.text == null) return Size.zero;
    if (_textPainter.text!.toPlainText() == '') return Size.zero;
    _textPainter.layout(maxWidth: maxWidth);
    final textLines = _textPainter.computeLineMetrics();

    _sendAtTextPainter.layout(maxWidth: maxWidth);
    final textLinesWithDate = _sendAtTextPainter.computeLineMetrics();
    _sentAtLineWidth = textLinesWithDate.first.width;
    _sentAtLineHeight = textLinesWithDate.first.height;

    _longestLineWidth = 0;

    for (final line in textLines) {
      _longestLineWidth = math.max(line.width, _longestLineWidth);
    }
    _longestLineWidth = math.max(_longestLineWidth, _sendAtTextPainter.width);

    final sizeOfMessage = Size(_longestLineWidth, _textPainter.height);

    _lastMessageLineWidth = textLines.last.width;
    _lineHeight = textLines.last.height;
    _numMessageLines = textLines.length;

    final lastLineWithDate = _lastMessageLineWidth + (_sentAtLineWidth * 1.08);
    if (textLines.length == 1) {
      _sentAtFitsOnLastLine = lastLineWithDate < maxWidth;
    } else {
      _sentAtFitsOnLastLine = lastLineWithDate < math.min(_longestLineWidth, maxWidth);
    }

    Size computedSize;
    if (!_sentAtFitsOnLastLine) {
      computedSize = Size(
        sizeOfMessage.width,
        sizeOfMessage.height + _sendAtTextPainter.height,
      );
    } else {
      if (textLines.length == 1) {
        computedSize = Size(
          lastLineWithDate,
          sizeOfMessage.height,
        );
      } else {
        computedSize = Size(
          _longestLineWidth,
          sizeOfMessage.height,
        );
      }
    }
    return computedSize;
  }

  @override
  void performLayout() {
    final computedSize = _performTextLayout(constraints.maxWidth);
    size = constraints.constrain(computedSize);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_textPainter.text == null) return;
    if (_textPainter.text!.toPlainText() == '') return;
    _textPainter.paint(context.canvas, offset);

    Offset sentAtOffset;
    if (_sentAtFitsOnLastLine) {
      sentAtOffset = Offset(
        offset.dx + (size.width - _sentAtLineWidth),
        offset.dy + _textPainter.height - _lineHeight,
      );
    } else {
      sentAtOffset = Offset(
        offset.dx + (size.width - _sentAtLineWidth),
        offset.dy + (_lineHeight * _numMessageLines) + math.max((_lineHeight - _sentAtLineHeight) / 1.6, 0),
      );
    }

    _sendAtTextPainter.paint(context.canvas, sentAtOffset);
  }
}
