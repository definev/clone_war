import 'dart:math' as math;

import 'package:clone_war/resources/resources.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GridLayoutChallenge extends StatefulWidget {
  const GridLayoutChallenge({Key? key}) : super(key: key);

  @override
  State<GridLayoutChallenge> createState() => _GridLayoutChallengeState();
}

class _GridLayoutChallengeState extends State<GridLayoutChallenge> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: GridLayout(
          color: Colors.white,
        ),
      ),
    );
  }
}

class GridLayout extends StatefulWidget {
  final Color color;

  const GridLayout({
    Key? key,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  State<GridLayout> createState() => _GridLayoutState();
}

class _GridLayoutState extends State<GridLayout> {
  int _shownDepth = 0;
  int _lastShownDepth = 0;
  int get shownDepth => removed ? _shownDepth - 1 : _shownDepth;

  double get _adaptiveRadius => 8 - shownDepth * 2;
  void resetDepth() {
    sizes = [math.Point(width, height)];
    _shownDepth = 0;
    removed = false;
    _borderPoints = [];
    _calculatePoints();
  }

  void decreaseDepth() {
    if (shownDepth <= 0) return;
    setState(() {
      _lastShownDepth = _shownDepth;
      _markAsRemoved();
      Future.delayed((200 * timeDilation).ms, () {
        _markAsRemovedDone();
        setState(() {});
        Future.delayed((400 * timeDilation).ms, () {
          sizes.removeLast();
          _calculateBorderPoints();
          setState(() {});
        });
      });
    });
  }

  void increaseDepth() {
    setState(() {
      _lastShownDepth = _shownDepth;
      _shownDepth += 1;
      sizes.add(math.Point(width, height));
      _calculateBorderPoints();
    });
  }

  int widthAt(int depth) => sizes[depth].x;
  int heightAt(int depth) => sizes[depth].y;

  // The spacing of the grid by depth
  List<math.Point<int>> sizes = [const math.Point(0, 0)];

  List<math.Point<int>> _points = [];
  void _calculatePoints() {
    _points = [];

    for (int column = 0; column < width; column++) {
      for (int row = 0; row < height; row++) {
        _points.add(math.Point(column, row));
      }
    }
  }

  List<List<math.Point<int>>> _borderPoints = [];
  // Spacing + (Size of depth - size of previous depth)
  List<math.Point<int>> _getBorderPointsAtDepth(int depth) {
    Set<math.Point<int>> points = {};

    final spacing = _spaceBetweenLevel(_shownDepth, depth);
    final size = sizes[depth];
    final prevSize = sizes[depth - 1];
    final sizeSpacing = _spaceBetweenLevel(depth, depth - 1);

    final leftBound = sizeSpacing.x ~/ 2;
    final rightBound = sizeSpacing.x ~/ 2 + prevSize.x;
    final topBound = sizeSpacing.y ~/ 2;
    final bottomBound = sizeSpacing.y ~/ 2 + prevSize.y;

    for (int column = 0; column < size.x; column++) {
      for (int row = 0; row < topBound; row++) {
        points.add(math.Point(column, row));
      }
      for (int row = bottomBound; row < size.y; row++) {
        points.add(math.Point(column, row));
      }
    }

    for (int row = 0; row < size.y; row++) {
      for (int column = 0; column < leftBound; column++) {
        points.add(math.Point(column, row));
      }
      for (int column = rightBound; column < size.x; column++) {
        points.add(math.Point(column, row));
      }
    }

    return points.map((e) => math.Point(e.x + spacing.x ~/ 2, e.y + spacing.y ~/ 2)).toList();
  }

  void _calculateBorderPoints() {
    _borderPoints = [];
    for (int depth = 1; depth <= shownDepth; depth += 1) {
      final points = _getBorderPointsAtDepth(depth);
      _borderPoints.add(points);
    }
  }

  math.Point<int> _spaceBetweenLevel(int currDepth, int depth) {
    final differHeight = heightAt(currDepth) - heightAt(depth);
    final differWidth = widthAt(currDepth) - widthAt(depth);
    return math.Point(math.max(differWidth, 0), math.max(differHeight, 0));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (availableSize != constraints.biggest || availableSize == Size.zero) {
          availableSize = constraints.biggest;
          resetDepth();
        }

        final remainSize = Size(
          (availableSize.width - width * tileSize(shownDepth) + spacingTile(shownDepth)) / 2,
          (availableSize.height - height * tileSize(shownDepth) + spacingTile(shownDepth)) / 2,
        );

        return Stack(
          children: [
            for (final points in _borderPoints.asMap().entries) //
              _borderTileStack(points, remainSize),
            _centerTileStack(remainSize),
            Row(
              children: [
                ElevatedButton(
                  onPressed: decreaseDepth,
                  child: const Text('Minus'),
                ),
                ElevatedButton(
                  onPressed: increaseDepth,
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _centerTileStack(Size remainSize) {
    return Stack(
      key: const ValueKey('center-tile-stack'),
      children: [
        for (final point in _points.asMap().entries) _centerTile(point, remainSize),
      ],
    );
  }

  Widget _centerTile(MapEntry<int, math.Point<int>> point, Size remainSize) {
    final spacingCell = _spaceBetweenLevel(shownDepth, 0);
    final column = point.value.x + spacingCell.x ~/ 2;
    final row = point.value.y + spacingCell.y ~/ 2;
    final coordinate = _calculateCoordinate(column, row);
    final lastShownDepth = _shownDepth;
    final beginDepth = _lastShownDepth;
    final endDepth = shownDepth;
    final transitionPosition = _transitionPosition(coordinate, endDepth);

    bool shouldRepaint() {
      return removed || _shownDepth != lastShownDepth;
    }

    return AnimatedPositioned(
      duration: 400.ms,
      curve: Curves.easeOutBack,
      left: remainSize.width + column * tileSize(endDepth),
      top: remainSize.height + row * tileSize(endDepth),
      child: Animate(
        key: ValueKey('center : $coordinate | $availableSize | ${shouldRepaint()}'),
        effects: [
          CustomEffect(
            duration: 500.ms,
            curve: beginDepth == endDepth ? Curves.linear : Curves.easeOutBack,
            begin: adaptiveSize(beginDepth),
            end: adaptiveSize(endDepth),
            builder: (context, value, child) => SizedBox(
              height: adaptiveSize(endDepth),
              width: adaptiveSize(endDepth),
              child: Center(
                child: Container(
                  width: value,
                  height: value,
                  decoration: BoxDecoration(
                    image: point.key < Images.all.length
                        ? DecorationImage(
                            image: AssetImage(Images.all[point.key]),
                            fit: BoxFit.cover,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(_adaptiveRadius),
                    border: Border.all(
                      color: point.key < Images.all.length ? Colors.white.withOpacity(0) : Colors.white,
                      width: point.key < Images.all.length ? 0 : 1,
                    ),
                  ),
                  child: point.key < Images.all.length ? null : const Center(child: Icon(CupertinoIcons.add)),
                ),
              ),
            ),
          ),
          const ThenEffect(),
          MoveEffect(
            delay: _getDelay(
              coordinate: coordinate,
              transitionDelay: removed ? 100 : 300,
            ),
            duration: removed ? 500.ms : 300.ms,
            begin: removed ? Offset.zero : transitionPosition,
            end: removed ? transitionPosition : Offset.zero,
            curve: Curves.easeOutBack,
          ),
        ],
      ),
    );
  }

  Widget _borderTileStack(MapEntry<int, List<math.Point<int>>> points, Size remainSize) {
    return Stack(
      key: ValueKey('border-tile-stack : ${points.key} | ${points.key == _shownDepth ? removed : false}'),
      children: _borderTile(points, remainSize),
    );
  }

  List<Widget> _borderTile(MapEntry<int, List<math.Point<int>>> points, Size remainSize) {
    final list = <Widget>[];

    for (final pointEntry in points.value.asMap().entries) {
      final coordinate = _calculateCoordinate(pointEntry.value.x, pointEntry.value.y);
      final imagePosition = pointEntry.key + _points.length;
      final delay = _getDelay(coordinate: coordinate, removed: removed);

      list.add(
        AnimatedPositioned(
          duration: 400.ms,
          curve: Curves.easeOutBack,
          left: remainSize.width + pointEntry.value.x * tileSize(removed ? _shownDepth : shownDepth),
          top: remainSize.height + pointEntry.value.y * tileSize(removed ? _shownDepth : shownDepth),
          child: Animate(
            key: ValueKey('border ${points.key}: $coordinate | $_shownDepth | $removed'),
            effects: [
              CustomEffect(
                duration: 500.ms,
                curve: Curves.easeOutBack,
                begin: adaptiveSize(removed ? _shownDepth : _shownDepth - 1),
                end: adaptiveSize(removed ? _shownDepth : shownDepth),
                builder: (context, value, child) => Container(
                  width: value,
                  height: value,
                  decoration: BoxDecoration(
                    image: imagePosition < Images.all.length
                        ? DecorationImage(
                            image: AssetImage(Images.all[imagePosition]),
                            fit: BoxFit.cover,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(_adaptiveRadius),
                    border: Border.all(
                      color: imagePosition < Images.all.length ? Colors.white.withOpacity(0) : Colors.white,
                      width: imagePosition < Images.all.length ? 0 : 1,
                    ),
                  ),
                  child: imagePosition < Images.all.length ? null : const Center(child: Icon(CupertinoIcons.add)),
                ),
              ),
              FadeEffect(
                duration: 500.ms,
                delay: delay,
                curve: Curves.easeOutBack,
                begin: removed ? 1 : 0,
                end: removed ? 0 : 1,
              ),
              MoveEffect(
                duration: 300.ms,
                delay: delay,
                begin: removed ? Offset.zero : _transitionPosition(coordinate, removed ? _shownDepth : shownDepth),
                end: removed ? _transitionPosition(coordinate, removed ? shownDepth : _shownDepth) : Offset.zero,
                curve: Curves.easeOutBack,
              ),
            ],
          ),
        ),
      );
    }

    return list;
  }

  bool removed = false;
  void _markAsRemoved() => removed = true;
  void _markAsRemovedDone() {
    _shownDepth -= 1;
    removed = false;
  }

  Size availableSize = Size.zero;
  double spacingTile(int depth) => 12 - depth * 2;
  double tileSize(int depth) => adaptiveSize(depth) + spacingTile(depth);

  double adaptiveSize(int depth) => normalSize - depth * 16;
  double normalSize = 56;

  int get height => _calculateDimension(availableSize.height, shownDepth);
  int get width => _calculateDimension(availableSize.width, shownDepth);
  int _calculateDimension(double base, int depth) => (base - spacingTile(depth)) ~/ tileSize(depth);

  int get maxColumn => width % 2 == 0 ? width ~/ 2 - 1 : width ~/ 2;
  int get maxRow => height % 2 == 0 ? height ~/ 2 - 1 : height ~/ 2;

  math.Point<int> calculateCenter(int column, int row) {
    int widthCenter = 0;
    int heightCenter = 0;

    final halfWidth = width ~/ 2;
    if (width % 2 == 0) {
      if (halfWidth > column) {
        widthCenter = halfWidth;
      } else {
        widthCenter = halfWidth - 1;
      }
    } else {
      widthCenter = halfWidth;
    }

    final halfHeight = height ~/ 2;
    if (height % 2 == 0) {
      if (halfHeight > row) {
        heightCenter = halfHeight;
      } else {
        heightCenter = halfHeight - 1;
      }
    } else {
      heightCenter = halfHeight;
    }

    return math.Point(widthCenter, heightCenter);
  }

  math.Point<int> _calculateCoordinate(int column, int row) {
    var center = calculateCenter(column, row);

    int columnDistance = center.x - column;
    int rowDistance = center.y - row;

    return math.Point(columnDistance, rowDistance);
  }

  Duration _getDelay({
    required math.Point<int> coordinate,
    int transitionDelay = 300,
    bool removed = false,
  }) {
    double transitionDelayUnit = transitionDelay / (maxColumn + maxRow);

    var delay = (coordinate.x.abs() + coordinate.y.abs());
    if (removed) {
      delay = ((maxColumn + maxRow) - delay).abs();
    }
    return (delay * transitionDelayUnit).ms;
  }

  Offset _transitionPosition(math.Point<int> coordinate, int shownDepth) {
    return Offset(
      -spacingTile(shownDepth) * coordinate.x.toDouble(),
      -spacingTile(shownDepth) * coordinate.y.toDouble(),
    );
  }
}
