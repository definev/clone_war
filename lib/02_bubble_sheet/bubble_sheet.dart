import 'dart:math';
import 'dart:ui';

import 'package:clone_war/01_grid_layout/grid_zoom.dart';
import 'package:flutter/material.dart';

enum _LastState { close, open }

class BubbleSheetChallenge extends StatefulWidget {
  const BubbleSheetChallenge({Key? key}) : super(key: key);

  @override
  State<BubbleSheetChallenge> createState() => _BubbleSheetChallengeState();
}

class _BubbleSheetChallengeState extends State<BubbleSheetChallenge>
    with SingleTickerProviderStateMixin {
  static const double _threshold = 600;

  late final AnimationController _controller;

  late Animation<double> _scaleAnimation;
  late Animation<double> _blurAnimation;

  late Animation<double> _sheetSizeAnimation;

  //
  Offset _startOffset = Offset.zero;
  Offset _currentOffset = Offset.zero;
  _LastState _lastState = _LastState.close;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0) //
        .chain(CurveTween(curve: Curves.ease))
        .animate(_controller);

    _blurAnimation = Tween<double>(begin: 0.0, end: 1.0) //
        .chain(CurveTween(curve: Curves.ease))
        .animate(_controller);

    _sheetSizeAnimation = TweenSequence<double>(
      [
        TweenSequenceItem(
          tween: Tween(begin: 0.1, end: 0.4) //
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 0.4, end: 0.7) //
              .chain(CurveTween(curve: Curves.ease)),
          weight: 25,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 0.7, end: 1.0) //
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 25,
        ),
      ],
    ).animate(_controller);

    _controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final md = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Transform(
            transform: Matrix4.identity()
              ..scale(1.0 - _scaleAnimation.value * 0.05, 1.0, 1.0)
              ..translate(
                0.0,
                -0.4 * md.height * _scaleAnimation.value,
              ),
            alignment: Alignment.center,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: _blurAnimation.value * 10,
                sigmaY: _blurAnimation.value * 20,
              ),
              child: const GridLayoutChallenge(),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onVerticalDragStart: (details) {
                _startOffset = details.globalPosition;
              },
              onVerticalDragUpdate: (details) {
                _currentOffset = details.globalPosition;
                if (_lastState == _LastState.close) {
                  var thresholdPercent =
                      (_startOffset.dy - _currentOffset.dy) / _threshold;
                  if (thresholdPercent < 0) {
                    thresholdPercent = 0;
                  } else if (thresholdPercent > 0.5) {
                    thresholdPercent = 0.5;
                  }

                  _controller.value = thresholdPercent;
                } else {
                  var thresholdPercent =
                      (_currentOffset.dy - _startOffset.dy) / _threshold;
                  if (thresholdPercent < 0) {
                    thresholdPercent = 0;
                  } else if (thresholdPercent > 0.5) {
                    thresholdPercent = 0.51;
                  }

                  _controller.value = 1 - thresholdPercent;
                }
                setState(() {});
              },
              onVerticalDragEnd: (details) {
                final velocity = details.velocity.pixelsPerSecond.dy;

                if (velocity.abs() > 500) {
                  switch (_lastState) {
                    case _LastState.close:
                      _lastState = _LastState.open;
                      _controller.forward();
                      break;
                    case _LastState.open:
                      _lastState = _LastState.close;
                      _controller.reverse();
                      break;
                  }
                  return;
                }

                if (_controller.value >= 0.5) {
                  _lastState = _LastState.open;
                  _controller.forward();
                } else {
                  _lastState = _LastState.close;
                  _controller.reverse();
                }
              },
              child: Container(
                height: _sheetSizeAnimation.value * md.height,
                width: double.maxFinite,
                decoration: const BoxDecoration(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
