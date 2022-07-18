import 'dart:ui';

import 'package:clone_war/02_bubble_sheet/bubble_painter.dart';
import 'package:flutter/material.dart';

enum _LastState {
  close,
  open;

  _LastState get opposite =>
      this == _LastState.close ? _LastState.open : _LastState.close;
}

class BubbleSheet extends StatefulWidget {
  const BubbleSheet({
    Key? key,
    required this.bottomSheet,
    required this.child,
    required this.backgroundColor,
  }) : super(key: key);

  final Color backgroundColor;
  final Widget bottomSheet;
  final Widget child;

  @override
  State<BubbleSheet> createState() => _BubbleSheetState();
}

class _BubbleSheetState extends State<BubbleSheet>
    with SingleTickerProviderStateMixin {
  static const double _threshold = 1100;

  late final AnimationController _controller;

  late Animation<double> _scaleAnimation;
  late Animation<double> _blurAnimation;

  late Animation<double> _sheetSizeAnimation;
  late Animation<double> _sheetContentAnimation;

  late Animation<double> _contentRadiusAnimation;
  late Animation<double> _bouncingBubbleAnimation;

  void _configurationAnimation() {
    final scaleTween = (Tween<double>()
          ..begin = 0.0
          ..end = 1.0)
        .chain(CurveTween(curve: Curves.ease));
    final blurTween = TweenSequence([
      TweenSequenceItem(
        tween: (Tween<double>()
              ..begin = 0.0
              ..end = 1.0)
            .chain(CurveTween(curve: Curves.ease)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 50,
      ),
    ]);

    final sheetSizeTween = () {
      return TweenSequence<double>(
        [
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 0.1,
              end: 0.5,
            ).chain(CurveTween(curve: Curves.ease)),
            weight: 30,
          ),
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 0.5,
              end: 0.5,
            ).chain(CurveTween(curve: Curves.ease)),
            weight: 10,
          ),
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 0.5,
              end: 0.7,
            ).chain(CurveTween(curve: Curves.ease)),
            weight: 30,
          ),
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 0.7,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeOut)),
            weight: 30,
          ),
        ],
      );
    }();
    final sheetContentTween = () {
      return TweenSequence<double>(
        [
          TweenSequenceItem(
            tween: Tween(begin: 0.0, end: 0.0),
            weight: 10,
          ),
          TweenSequenceItem(
            tween: Tween(begin: 0.0, end: 0.2)
                .chain(CurveTween(curve: Curves.ease)),
            weight: 20,
          ),
          TweenSequenceItem(
            tween: Tween(begin: 0.2, end: 0.5)
                .chain(CurveTween(curve: Curves.linear)),
            weight: 10,
          ),
          TweenSequenceItem(
            tween: Tween(begin: 0.5, end: 0.8)
                .chain(CurveTween(curve: Curves.ease)),
            weight: 40,
          ),
          TweenSequenceItem(
            tween: Tween(begin: 0.8, end: 1.0)
                .chain(CurveTween(curve: Curves.easeOut)),
            weight: 20,
          ),
        ],
      );
    }();

    final contentRadiusTween = TweenSequence<double>(
      [
        TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 0.0),
          weight: 10,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 20.0),
          weight: 30,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 20.0, end: 0.0)
              .chain(CurveTween(curve: Curves.ease)),
          weight: 60,
        ),
      ],
    );
    final bouncingBubbleTween = () {
      return TweenSequence<double>(
        [
          TweenSequenceItem(
            tween: Tween(begin: 0.0, end: 0.0)
                .chain(CurveTween(curve: Curves.linear)),
            weight: 40,
          ),
          TweenSequenceItem(
            tween: Tween(begin: 0.0, end: -0.05),
            weight: 10,
          ),
          TweenSequenceItem(
            tween: Tween(begin: -0.05, end: 0.04),
            weight: 50,
          ),
        ],
      );
    }();

    _scaleAnimation = scaleTween.animate(_controller);
    _blurAnimation = blurTween.animate(_controller);

    _sheetSizeAnimation = sheetSizeTween.animate(_controller);
    _sheetContentAnimation = sheetContentTween.animate(_controller);

    _contentRadiusAnimation = contentRadiusTween.animate(_controller);
    _bouncingBubbleAnimation = bouncingBubbleTween.animate(_controller);
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

  double get notchSize =>
      _sheetSizeAnimation.value - _sheetContentAnimation.value;

  //
  Offset _startOffset = Offset.zero;
  Offset _currentOffset = Offset.zero;
  _LastState _lastState = _LastState.close;

  void onVerticalDragStart(DragStartDetails details) {
    _startOffset = details.globalPosition;
  }

  void onVerticalDragUpdate(DragUpdateDetails details) {
    _currentOffset = details.globalPosition;
    double thresholdPercent;
    if (_lastState == _LastState.close) {
      thresholdPercent = (_startOffset.dy - _currentOffset.dy) / _threshold;
    } else {
      thresholdPercent = (_currentOffset.dy - _startOffset.dy) / _threshold;
    }
    if (thresholdPercent < 0) {
      thresholdPercent = 0;
    } else if (thresholdPercent > 0.3) {
      thresholdPercent = 0.3;
    }

    if (_lastState == _LastState.close) {
      _controller.value = thresholdPercent;
    } else {
      _controller.value = 1 - thresholdPercent;
    }
  }

  void onVerticalDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dy;

    if (velocity < -500 || _controller.value == 0.3) {
      _notifController(_lastState.opposite);
    } else {
      _notifController(_lastState);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _controller.addListener(() => setState(() {}));

    _configurationAnimation();
  }

  Widget _buildChild(Size md) {
    return Transform(
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
        child: widget.child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final md = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          _buildChild(md),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: _sheetSizeAnimation.value * md.height,
              width: double.maxFinite,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ClipPath(
                        clipper: BouncingBubbleClip(
                          _bouncingBubbleAnimation.value,
                        ),
                        child: CustomPaint(
                          painter: BouncingBubblePainter(
                            _bouncingBubbleAnimation.value,
                            widget.backgroundColor,
                          ),
                          child: SizedBox(
                            height: _sheetContentAnimation.value * md.height,
                            width: double.maxFinite,
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(
                                  _contentRadiusAnimation.value,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: ColoredBox(
                                color: widget.backgroundColor,
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(top: md.height * 0.04),
                                  child: SingleChildScrollView(
                                    child: SizedBox(
                                      height: md.height,
                                      child: widget.bottomSheet,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onVerticalDragStart: onVerticalDragStart,
                        onVerticalDragUpdate: onVerticalDragUpdate,
                        onVerticalDragEnd: onVerticalDragEnd,
                        child: CustomPaint(
                          foregroundPainter: ForegroundBubblePainter(
                            _controller.value,
                            widget.backgroundColor,
                          ),
                          child: Container(
                            height: notchSize.clamp(0, 1) * md.height,
                            width: double.maxFinite,
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: _controller.value <= 0.4
                          ? Alignment.center
                          : Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: _controller.value <= 0.3
                            ? GestureDetector(
                                onTap: () {
                                  _notifController(_LastState.open);
                                },
                                child: TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 300),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  builder: (context, value, child) => Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                  child: Text(
                                    'Next',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                        ),
                                  ),
                                ),
                              )
                            : _controller.value >= 0.9
                                ? GestureDetector(
                                    onTap: () {
                                      _notifController(_LastState.close);
                                    },
                                    child: Text(
                                      'Close',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                          ),
                                    ),
                                  )
                                : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
