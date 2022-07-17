import 'dart:ui';

import 'package:clone_war/01_grid_layout/grid_zoom.dart';
import 'package:flutter/material.dart';

enum _LastState {
  close,
  open;

  _LastState get opposite =>
      this == _LastState.close ? _LastState.open : _LastState.close;
}

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
      duration: const Duration(milliseconds: 560),
    );
    _controller.addListener(() => setState(() {}));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _configurationAnimation();
      }
    });

    _configurationAnimation();
  }

  void _configurationAnimation() {
    final easeTween = (Tween<double>()
          ..begin = 0.0
          ..end = 1.0)
        .chain(CurveTween(curve: Curves.ease));

    final sheetSizeTween = () {
      switch (_lastState) {
        case _LastState.close:
          return TweenSequence<double>(
            [
              TweenSequenceItem(
                tween: (Tween<double>()
                      ..begin = 0.1
                      ..end = 0.4)
                    .chain(CurveTween(curve: Curves.ease)),
                weight: 50,
              ),
              TweenSequenceItem(
                tween: (Tween<double>()
                      ..begin = 0.4
                      ..end = 0.7)
                    .chain(CurveTween(curve: Curves.linear)),
                weight: 25,
              ),
              TweenSequenceItem(
                tween: (Tween<double>()
                      ..begin = 0.7
                      ..end = 1.0)
                    .chain(CurveTween(curve: Curves.easeOut)),
                weight: 25,
              ),
            ],
          );
        case _LastState.open:
          return TweenSequence<double>(
            [
              TweenSequenceItem(
                tween: (Tween<double>()
                      ..begin = 0.1
                      ..end = 0.3)
                    .chain(CurveTween(curve: Curves.easeIn)),
                weight: 25,
              ),
              TweenSequenceItem(
                tween: (Tween<double>()
                      ..begin = 0.3
                      ..end = 0.6)
                    .chain(CurveTween(curve: Curves.linear)),
                weight: 25,
              ),
              TweenSequenceItem(
                tween: (Tween<double>()
                      ..begin = 0.6
                      ..end = 1.0)
                    .chain(CurveTween(curve: Curves.ease)),
                weight: 50,
              ),
            ],
          );
      }
    }();

    _scaleAnimation = easeTween.animate(_controller);
    _blurAnimation = easeTween.animate(_controller);

    _sheetSizeAnimation = sheetSizeTween.animate(_controller);
  }

  void _notifController(_LastState state) {
    _lastState = state;
    switch (state) {
      case _LastState.open:
        _controller.forward();
        break;
      case _LastState.close:
        _controller.reverse();
        break;
    }
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
                double thresholdPercent;
                if (_lastState == _LastState.close) {
                  thresholdPercent =
                      (_startOffset.dy - _currentOffset.dy) / _threshold;
                } else {
                  thresholdPercent =
                      (_currentOffset.dy - _startOffset.dy) / _threshold;
                }
                if (thresholdPercent < 0) {
                  thresholdPercent = 0;
                } else if (thresholdPercent > 0.5) {
                  thresholdPercent = 0.5;
                }

                if (_lastState == _LastState.close) {
                  _controller.value = thresholdPercent;
                } else {
                  _controller.value = 1 - thresholdPercent;
                }
              },
              onVerticalDragEnd: (details) {
                final velocity = details.velocity.pixelsPerSecond.dy;

                if (velocity.abs() > 500 || _controller.value == 0.5) {
                  _notifController(_lastState.opposite);
                } else {
                  _notifController(_lastState);
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
