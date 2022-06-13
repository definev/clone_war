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
  var _prepareAcion = _Action.none;
  final _gridState = GlobalKey<GridLayoutState>();

  double _getScale() {
    switch (_prepareAcion) {
      case _Action.decrease:
        return 1.1;
      case _Action.increase:
        return 0.9;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onScaleStart: (details) {},
          onScaleUpdate: (details) {
            _Action action = _Action.values[_prepareAcion.index];
            if (details.scale < 0.95) {
              action = _Action.increase;
            } else if (details.scale > 1.05) {
              action = _Action.decrease;
            } else {
              action = _Action.none;
            }

            if (action != _prepareAcion) {
              _prepareAcion = action;
              setState(() {});
            }
          },
          onScaleEnd: (_) {
            switch (_prepareAcion) {
              case _Action.increase:
                _gridState.currentState?.increaseDepth();
                break;
              case _Action.decrease:
                _gridState.currentState?.decreaseDepth();
                break;
              default:
                return;
            }
            _prepareAcion = _Action.none;
            setState(() {});
          },
          child: TweenAnimationBuilder<double>(
            duration: Animations.short.ms,
            curve: Curves.easeOutBack,
            tween: Tween<double>(begin: 0, end: _getScale()),
            builder: (context, value, child) => Transform.scale(
              scale: value,
              child: child,
            ),
            child: GridLayout(key: _gridState),
          ),
        ),
      ),
    );
  }
}

class GridLayout extends StatefulWidget {
  const GridLayout({
    Key? key,
  }) : super(key: key);

  @override
  State<GridLayout> createState() => GridLayoutState();
}

enum _Action { increase, decrease, none }

class GridLayoutState extends State<GridLayout> {
  int _shownDepth = 0;
  _Action _lastAction = _Action.none;

  math.Point<int>? _magnifierPoints = null;

  void resetDepth() {
    sizes = [math.Point(getWidth(_shownDepth), getHeight(_shownDepth))];
    _shownDepth = 0;
    _lastAction = _Action.none;
    _borderPoints = [];
    _depthSpacingList = [];
    _calculatePoints();
  }

  void decreaseDepth() {
    if (_shownDepth <= 0 || _lastAction != _Action.none) return;
    setState(() {
      _lastAction = _Action.decrease;
      _shownDepth -= 1;
      final lastSize = _borderPoints.removeLast();
      _calculateBorderPoints();
      _borderPoints.add(lastSize);
    });
  }

  void increaseDepth() {
    if (_lastAction != _Action.none || _shownDepth > 3) return;
    setState(() {
      _lastAction = _Action.increase;
      _shownDepth += 1;

      if (sizes.length - 1 < _shownDepth) {
        sizes.add(math.Point(getWidth(_shownDepth), getHeight(_shownDepth)));
      }

      if (_depthSpacingList.length < _shownDepth) {
        _depthSpacingList.add(
          math.Point(
            sizes[_shownDepth].x - sizes[_shownDepth - 1].x,
            sizes[_shownDepth].y - sizes[_shownDepth - 1].y,
          ),
        );
      }

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

  int _div2(int size) => size ~/ 2;

  List<List<math.Point<int>>> _borderPoints = [];
  // Spacing + (Size of depth - size of previous depth)
  List<math.Point<int>> _getBorderPointsAtDepth(int depth) {
    Set<math.Point<int>> points = {};

    final spacing = _spaceBetweenDepth(_shownDepth, depth);
    final size = sizes[depth];
    final preSize = sizes[depth - 1];
    final sizeSpacing = _spaceBetweenDepth(depth, depth - 1);

    final leftBound = sizeSpacing.x;
    final rightBound = preSize.x + sizeSpacing.x;
    final topBound = sizeSpacing.y;
    final bottomBound = preSize.y + sizeSpacing.y;

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

    return points.map((e) => math.Point(e.x + _div2(spacing.x), e.y + _div2(spacing.y))).toList();
  }

  void _calculateBorderPoints() {
    _borderPoints = [];
    for (int depth = 1; depth <= _shownDepth; depth += 1) {
      final points = _getBorderPointsAtDepth(depth);
      _borderPoints.add(points);
    }
  }

  List<math.Point<int>> _depthSpacingList = [];
  math.Point<int> _spaceBetweenDepth(int currDepth, int depth) {
    List<math.Point<int>> relativeSpacingList = [];
    for (int i = depth; i < currDepth; i++) {
      relativeSpacingList.add(_depthSpacingList[i]);
    }

    return relativeSpacingList.fold(
      const math.Point(0, 0),
      (acc, e) => math.Point(acc.x + e.x ~/ 2, acc.y + e.y ~/ 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (availableSize != constraints.biggest || availableSize == Size.zero) {
          availableSize = constraints.biggest;
          resetDepth();
        }

        final borderPointsEntries = _borderPoints.asMap().entries;

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanUpdate: (_) {
            print('UPDATE!');
          },
          child: Stack(
            children: [
              const Positioned.fill(child: ColoredBox(color: Colors.transparent)),
              Stack(
                children: [
                  for (int i = borderPointsEntries.length - 1; i >= 0; i--) //
                    _borderTileStack(borderPointsEntries.elementAt(i)),
                ],
              ),
              RepaintBoundary(child: _centerTileStack()),
            ],
          ),
        );
      },
    );
  }

  Widget _centerTileStack() {
    final remainSize = Size(
      (availableSize.width - getWidth(_shownDepth) * _tileSize(_shownDepth) + _spacingTile(_shownDepth)) / 2,
      (availableSize.height - getHeight(_shownDepth) * _tileSize(_shownDepth) + _spacingTile(_shownDepth)) / 2,
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
        case _Action.none:
          return _shownDepth;
      }
    }();
    final endDepth = _shownDepth;
    final spacingCell = _spaceBetweenDepth(endDepth, 0);
    final column = point.value.x + spacingCell.x;
    final row = point.value.y + spacingCell.y;
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
        case _Action.none:
          return Offset.zero;
      }
    }();
    final moveEnd = () {
      switch (_lastAction) {
        case _Action.decrease:
          return Offset.zero;
        case _Action.increase:
          return transitionPosition * 0.2;
        case _Action.none:
          return transitionPosition;
      }
    }();

    final beginTileSize = _adaptiveSize(beginDepth);
    final endTileSize = _adaptiveSize(endDepth);

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
            builder: (context, value, child) => Listener(
              onPointerHover: (_) {
                // print('Hovering $column $row');
              },
              onPointerSignal: (details) {
                print('$details');
              },
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
                child: point.key < Images.all.length
                    ? null
                    : const FittedBox(
                        child: Center(
                          child: Icon(CupertinoIcons.add),
                        ),
                      ),
              ),
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
                setState(() => _lastAction = _Action.none);
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
        case _Action.none:
          return _shownDepth;
      }
    }();
    final remainSize = Size(
      (availableSize.width - getWidth(endDepth) * _tileSize(endDepth) + _spacingTile(endDepth)) / 2,
      (availableSize.height - getHeight(endDepth) * _tileSize(endDepth) + _spacingTile(endDepth)) / 2,
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
    final isCenter = _lastAction == _Action.increase && points.key < _shownDepth - 1;

    final beginDepth = () {
      if (isCenter) return _shownDepth - 1;

      switch (_lastAction) {
        case _Action.decrease:
          return isLastDepth ? _shownDepth + 1 : _shownDepth;
        case _Action.increase:
          return _shownDepth;
        case _Action.none:
          return _shownDepth;
      }
    }();
    final endDepth = () {
      if (isCenter) return _shownDepth;

      switch (_lastAction) {
        case _Action.decrease:
          return isLastDepth ? _shownDepth + 1 : _shownDepth;
        case _Action.increase:
          return _shownDepth;
        case _Action.none:
          return _shownDepth;
      }
    }();

    final beginTileSize = _adaptiveSize(beginDepth);
    final endTileSize = _adaptiveSize(endDepth);

    final tileSize = _tileSize(endDepth);

    final usedImage = _calculateUsedImage(points);

    for (final pointEntry in points.value.asMap().entries) {
      final imagePosition = pointEntry.key + usedImage;

      final coordinate = _calculateCoordinate(pointEntry.value.x, pointEntry.value.y, endDepth);

      final moveDelay = isLastDepth ? null : _getDelay(coordinate: coordinate, depth: endDepth);
      final transitionPosition = _transitionPosition(
        coordinate,
        _shownDepth,
        additionX: isLastDepth ? -remainSize.width / 2 : 0,
        additionY: isLastDepth ? -remainSize.height / 2 : 0,
      );
      final moveBegin = () {
        if (isCenter) return Offset.zero;

        switch (_lastAction) {
          case _Action.decrease:
            return Offset.zero;
          case _Action.increase:
            return transitionPosition;
          case _Action.none:
            return Offset.zero;
        }
      }();
      final moveEnd = () {
        if (isCenter) return transitionPosition * 0.4;

        return isLastDepth ? transitionPosition : Offset.zero;
      }();

      list.add(
        AnimatedPositioned(
          duration: Animations.medium.ms,
          curve: Curves.easeOutBack,
          left: remainSize.width + pointEntry.value.x * tileSize,
          top: remainSize.height + pointEntry.value.y * tileSize,
          child: Animate(
            key: ValueKey('point : ${pointEntry.key} | depth : ${points.key} | $isCenter'),
            effects: [
              CustomEffect(
                duration: _lastAction == _Action.decrease ? Animations.medium.ms : Animations.medium.ms,
                curve: Curves.easeOutBack,
                begin: beginTileSize,
                end: endTileSize,
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
                  child: imagePosition < Images.all.length
                      ? null
                      : const FittedBox(
                          child: Center(
                            child: Icon(CupertinoIcons.add),
                          ),
                        ),
                ),
              ),
              FadeEffect(
                duration: Animations.medium.ms,
                delay: isCenter ? null : moveDelay,
                curve: Curves.decelerate,
                begin: () {
                  if (isCenter) return 1.0;
                  switch (_lastAction) {
                    case _Action.decrease:
                      return 1.0;
                    case _Action.increase:
                      return 0.0;
                    case _Action.none:
                      return 1.0;
                  }
                }(),
                end: isCenter
                    ? 1.0
                    : isLastDepth
                        ? 0.04
                        : 1.0,
              ),
              if (isCenter) ...[
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
              ] else if (isLastDepth) ...[
                MoveEffect(
                  duration: Animations.medium.ms,
                  delay: moveDelay,
                  begin: moveBegin,
                  end: moveEnd,
                  curve: Curves.easeOutExpo,
                ),
                const ThenEffect(),
                CallbackEffect(
                  callback: () {
                    if (isLastDepth) {
                      _lastAction = _Action.none;
                      if (sizes.length - 1 > _shownDepth) {
                        _calculateBorderPoints();
                      }
                      setState(() {});
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
  double _spacingTile(int depth) => 12 - depth * 2;
  double _tileSize(int depth) => _adaptiveSize(depth) + _spacingTile(depth);

  double _adaptiveSize(int depth) => _baseSize - depth * 5;
  final double _baseSize = 56;
  final double _adaptiveRadius = 8;

  int getHeight(int depth) => _calculateDimension(availableSize.height, depth);
  int getWidth(int depth) => _calculateDimension(availableSize.width, depth);
  int _calculateDimension(double base, int depth) => (base - _spacingTile(depth)) ~/ _tileSize(depth);

  int getMaxColumn(int depth) => getWidth(depth) % 2 == 0 ? _div2(getWidth(depth)) - 1 : _div2(getWidth(depth));
  int getMaxRow(int depth) => getHeight(depth) % 2 == 0 ? _div2(getHeight(depth)) - 1 : _div2(getHeight(depth));

  math.Point<int> calculateCenter(int column, int row, int depth) {
    int widthCenter = 0;
    int heightCenter = 0;

    final width = getWidth(depth);
    final height = getHeight(depth);

    final halfWidth = _div2(width);
    if (width % 2 == 0) {
      if (halfWidth > column) {
        widthCenter = halfWidth;
      } else {
        widthCenter = halfWidth - 1;
      }
    } else {
      widthCenter = halfWidth;
    }

    final halfHeight = _div2(height);
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
      additionX - _spacingTile(depth) * scale * coordinate.x.toDouble(),
      additionY - _spacingTile(depth) * scale * coordinate.y.toDouble(),
    );
  }
}

class Animations {
  static const medium = 500;
  static const short = 300;
}
