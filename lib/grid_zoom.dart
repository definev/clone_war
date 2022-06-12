import 'dart:math' as math;

import 'package:clone_war/resources/resources.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
        child: GridLayout(),
      ),
    );
  }
}

class GridLayout extends StatefulWidget {
  const GridLayout({
    Key? key,
  }) : super(key: key);

  @override
  State<GridLayout> createState() => _GridLayoutState();
}

enum _Action { increase, decrease, done }

class _GridLayoutState extends State<GridLayout> {
  int _shownDepth = 0;
  _Action _lastAction = _Action.done;

  double get _adaptiveRadius => 8 - _shownDepth * 2;
  void resetDepth() {
    sizes = [math.Point(getWidth(_shownDepth), getHeight(_shownDepth))];
    _shownDepth = 0;
    _lastAction = _Action.done;
    _borderPoints = [];
    _calculatePoints();
  }

  void decreaseDepth() {
    if (_shownDepth <= 0 || _lastAction != _Action.done) return;
    setState(() {
      _lastAction = _Action.decrease;
      _shownDepth -= 1;
      final lastSize = _borderPoints.removeLast();
      _calculateBorderPoints();
      _borderPoints.add(lastSize);
    });
  }

  void increaseDepth() {
    if (_lastAction != _Action.done) return;
    setState(() {
      _lastAction = _Action.increase;
      _shownDepth += 1;
      if (sizes.length - 1 >= _shownDepth) return;
      sizes.add(math.Point(getWidth(_shownDepth), getHeight(_shownDepth)));
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

    final width = getWidth(_shownDepth);
    final height = getHeight(_shownDepth);

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

    for (int row = 0; row < size.y; row++) {
      for (int column = 0; column < leftBound; column++) {
        points.add(math.Point(column, row));
      }
      for (int column = rightBound; column < size.x; column++) {
        points.add(math.Point(column, row));
      }
    }

    for (int column = 0; column < size.x; column++) {
      for (int row = 0; row < topBound; row++) {
        points.add(math.Point(column, row));
      }
      for (int row = bottomBound; row < size.y; row++) {
        points.add(math.Point(column, row));
      }
    }

    return points.map((e) => math.Point(e.x + spacing.x ~/ 2, e.y + spacing.y ~/ 2)).toList();
  }

  void _calculateBorderPoints() {
    _borderPoints = [];
    for (int depth = 1; depth <= _shownDepth; depth += 1) {
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

        return Stack(
          children: [
            Stack(
              children: [
                for (final points in _borderPoints.asMap().entries) //
                  _borderTileStack(points),
              ],
            ),
            _centerTileStack(),
            Row(
              mainAxisSize: MainAxisSize.min,
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

  Widget _centerTileStack() {
    final remainSize = Size(
      (availableSize.width - getWidth(_shownDepth) * _tileSize(_shownDepth) + spacingTile(_shownDepth)) / 2,
      (availableSize.height - getHeight(_shownDepth) * _tileSize(_shownDepth) + spacingTile(_shownDepth)) / 2,
    );
    return Stack(
      key: const ValueKey('center-tile-stack'),
      children: [
        for (final point in _points.asMap().entries) _centerTile(point, remainSize),
      ],
    );
  }

  Widget _centerTile(MapEntry<int, math.Point<int>> point, Size remainSize) {
    final beginDepth = () {
      switch (_lastAction) {
        case _Action.decrease:
          return _shownDepth;
        case _Action.increase:
          return _shownDepth - 1;
        case _Action.done:
          return _shownDepth;
      }
    }();
    final endDepth = _shownDepth;
    final spacingCell = _spaceBetweenLevel(endDepth, 0);
    final column = point.value.x + spacingCell.x ~/ 2;
    final row = point.value.y + spacingCell.y ~/ 2;
    final coordinate = _calculateCoordinate(column, row, endDepth);

    final tileSize = _tileSize(endDepth);

    final moveDelay = () {
      if (_lastAction == _Action.decrease) return null;
      return _getDelay(coordinate: coordinate, depth: endDepth);
    }();
    final transitionPosition = _transitionPosition(coordinate, endDepth, scale: 1);
    final moveBegin = () {
      switch (_lastAction) {
        case _Action.decrease:
          return Offset.zero;
        case _Action.increase:
          return Offset.zero;
        case _Action.done:
          return Offset.zero;
      }
    }();
    final moveEnd = () {
      switch (_lastAction) {
        case _Action.decrease:
          return Offset.zero;
        case _Action.increase:
          return transitionPosition * 0.2;
        case _Action.done:
          return transitionPosition;
      }
    }();

    final beginTileSize = adaptiveSize(beginDepth);
    final endTileSize = adaptiveSize(endDepth);

    return AnimatedPositioned(
      duration: Animations.medium.ms,
      curve: Curves.easeOutBack,
      left: remainSize.width + column * tileSize,
      top: remainSize.height + row * tileSize,
      child: Animate(
        key: ValueKey('center : ${point.key} ${point.value} | $_shownDepth'),
        effects: [
          CustomEffect(
            duration: _lastAction == _Action.decrease ? Animations.short.ms : Animations.medium.ms,
            curve: Curves.easeOutBack,
            begin: beginTileSize,
            end: endTileSize,
            builder: (context, value, child) => Container(
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
          MoveEffect(
            delay: moveDelay,
            duration: Animations.short.ms,
            begin: moveBegin,
            end: moveEnd,
            curve: Curves.easeOutBack,
          ),
          const ThenEffect(),
          MoveEffect(
            duration: Animations.short.ms,
            begin: Offset.zero,
            end: -moveEnd,
            curve: Curves.easeOutBack,
          ),
          const ThenEffect(),
          CallbackEffect(
            callback: () {
              if (_lastAction == _Action.increase) {
                setState(() {
                  _lastAction = _Action.done;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _borderTileStack(MapEntry<int, List<math.Point<int>>> points) {
    final isLastDepth = points.key == _shownDepth && _lastAction == _Action.decrease;
    final endDepth = () {
      switch (_lastAction) {
        case _Action.decrease:
          return isLastDepth ? _shownDepth + 1 : _shownDepth;
        case _Action.increase:
          return _shownDepth;
        case _Action.done:
          return _shownDepth;
      }
    }();
    final remainSize = Size(
      (availableSize.width - getWidth(endDepth) * _tileSize(endDepth) + spacingTile(endDepth)) / 2,
      (availableSize.height - getHeight(endDepth) * _tileSize(endDepth) + spacingTile(endDepth)) / 2,
    );

    return Stack(
      key: ValueKey('border-tile-stack : ${points.key} | $isLastDepth'),
      children: _borderTile(points, remainSize),
    );
  }

  int _calculateUsedImage(MapEntry<int, List<math.Point<int>>> points) {
    int total = 0;
    for (int index = 0; index < points.key; index++) {
      total += _borderPoints[index].length;
    }
    return _points.length + total;
  }

  List<Widget> _borderTile(MapEntry<int, List<math.Point<int>>> points, Size remainSize) {
    final list = <Widget>[];
    final isLastDepth = points.key == _shownDepth && _lastAction == _Action.decrease;
    final beginDepth = () {
      switch (_lastAction) {
        case _Action.decrease:
          return isLastDepth ? _shownDepth + 1 : _shownDepth;
        case _Action.increase:
          return _shownDepth;
        case _Action.done:
          return _shownDepth;
      }
    }();
    final endDepth = () {
      switch (_lastAction) {
        case _Action.decrease:
          return isLastDepth ? _shownDepth + 1 : _shownDepth;
        case _Action.increase:
          return _shownDepth;
        case _Action.done:
          return _shownDepth;
      }
    }();

    final tileSize = _tileSize(endDepth);

    final usedImage = _calculateUsedImage(points);

    for (final pointEntry in points.value.asMap().entries) {
      final imagePosition = pointEntry.key + usedImage;

      final coordinate = _calculateCoordinate(pointEntry.value.x, pointEntry.value.y, endDepth);

      final moveDelay = isLastDepth ? null : _getDelay(coordinate: coordinate, depth: endDepth);
      final transitionPosition = _transitionPosition(
        coordinate,
        _shownDepth,
        scale: isLastDepth ? 5 : 1,
        additionX: isLastDepth ? -remainSize.width / 2 : 0,
        additionY: isLastDepth ? -remainSize.height / 2 : 0,
      );
      final moveBegin = () {
        switch (_lastAction) {
          case _Action.decrease:
            return Offset.zero;
          case _Action.increase:
            return transitionPosition;
          case _Action.done:
            return transitionPosition;
        }
      }();
      final moveEnd = isLastDepth ? transitionPosition : Offset.zero;

      list.add(
        AnimatedPositioned(
          key: ValueKey('point : ${pointEntry.key} | depth : ${points.key}'),
          duration: Animations.medium.ms,
          curve: Curves.easeOutBack,
          left: remainSize.width + pointEntry.value.x * tileSize,
          top: remainSize.height + pointEntry.value.y * tileSize,
          child: Animate(
            effects: [
              CustomEffect(
                duration: _lastAction == _Action.decrease ? Animations.medium.ms : Animations.medium.ms,
                curve: Curves.easeOutBack,
                begin: adaptiveSize(beginDepth),
                end: adaptiveSize(endDepth),
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
                duration: Animations.medium.ms,
                delay: moveDelay,
                curve: isLastDepth ? Curves.decelerate : Curves.easeOutBack,
                begin: () {
                  switch (_lastAction) {
                    case _Action.decrease:
                      return 1.0;
                    default:
                      return 0.0;
                  }
                }(),
                end: isLastDepth ? 0.8 : 1.0,
              ),
              if (isLastDepth) ...[
                MoveEffect(
                  duration: Animations.medium.ms,
                  delay: moveDelay,
                  begin: moveBegin,
                  end: moveEnd,
                  curve: Curves.easeOutBack,
                ),
                const ThenEffect(),
                CallbackEffect(
                  callback: () {
                    if (isLastDepth) {
                      _lastAction = _Action.done;
                      if (sizes.length - 1 > _shownDepth) {
                        sizes.removeLast();
                        _calculateBorderPoints();
                        setState(() {});
                      }
                    }
                  },
                )
              ] else ...[
                MoveEffect(
                  delay: moveDelay,
                  duration: Animations.short.ms,
                  begin: moveBegin,
                  end: moveEnd,
                  curve: Curves.easeOutBack,
                ),
                const ThenEffect(),
                MoveEffect(
                  duration: Animations.short.ms,
                  begin: Offset.zero,
                  end: -moveEnd,
                  curve: Curves.easeOutBack,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return list;
  }

  Size availableSize = Size.zero;
  double spacingTile(int depth) => 12 - depth * 2;
  double _tileSize(int depth) => adaptiveSize(depth) + spacingTile(depth);

  double adaptiveSize(int depth) => normalSize - depth * 16;
  double normalSize = 56;

  int getHeight(int depth) => _calculateDimension(availableSize.height, depth);
  int getWidth(int depth) => _calculateDimension(availableSize.width, depth);
  int _calculateDimension(double base, int depth) => (base - spacingTile(depth)) ~/ _tileSize(depth);

  int getMaxColumn(int depth) => getWidth(depth) % 2 == 0 ? getWidth(depth) ~/ 2 - 1 : getWidth(depth) ~/ 2;
  int getMaxRow(int depth) => getHeight(depth) % 2 == 0 ? getHeight(depth) ~/ 2 - 1 : getHeight(depth) ~/ 2;

  math.Point<int> calculateCenter(int column, int row, int depth) {
    int widthCenter = 0;
    int heightCenter = 0;

    final width = getWidth(depth);
    final height = getHeight(depth);

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

  math.Point<int> _calculateCoordinate(int column, int row, int depth) {
    var center = calculateCenter(column, row, depth);

    int columnDistance = center.x - column;
    int rowDistance = center.y - row;

    return math.Point(columnDistance, rowDistance);
  }

  Duration _getDelay({
    required math.Point<int> coordinate,
    required int depth,
    int transitionDelay = Animations.short,
  }) {
    final maxColumn = getMaxColumn(depth);
    final maxRow = getMaxRow(depth);

    double transitionDelayUnit = transitionDelay / (maxColumn + maxRow);

    var delay = (coordinate.x.abs() + coordinate.y.abs());

    return (delay * transitionDelayUnit).ms;
  }

  Offset _transitionPosition(
    math.Point<int> coordinate,
    int depth, {
    double scale = 1,
    double additionX = 0,
    double additionY = 0,
  }) {
    return Offset(
      additionX - spacingTile(depth) * scale * coordinate.x.toDouble(),
      additionY - spacingTile(depth) * scale * coordinate.y.toDouble(),
    );
  }
}

class Animations {
  static const medium = 500;
  static const short = 300;
}
