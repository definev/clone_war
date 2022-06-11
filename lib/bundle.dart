import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  runApp(const CloneWar());
}

class CloneWar extends StatelessWidget {
  const CloneWar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Clone War',
      home: GridLayoutChallenge(),
    );
  }
}

class GridLayoutChallenge extends StatefulWidget {
  const GridLayoutChallenge({Key? key}) : super(key: key);

  @override
  State<GridLayoutChallenge> createState() => _GridLayoutChallengeState();
}

class _GridLayoutChallengeState extends State<GridLayoutChallenge> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: GridLayout(
        color: Colors.white,
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
  int depth = 0;
  int shownDepth = 0;

  int initialHeight = 0;
  int initialWidth = 0;

  int _startColumnIndex() => 0;
  int _endColumnIndex() => width;
  int _startRowIndex() => 0;
  int _endRowIndex() => height;

  bool _isBorder(math.Point<int> spacingCell, int column, int row) {
    if (initialHeight == height && initialWidth == width) {
      return false;
    }
    if (column < spacingCell.x ~/ 2 || row < spacingCell.y ~/ 2) {
      return true;
    }

    int _halfEnd(int end) => end - end ~/ 2;

    if (column >= width - _halfEnd(spacingCell.x) || row >= height - _halfEnd(spacingCell.y)) {
      return true;
    }

    return false;
  }

  List<math.Point<int>> _points = [];
  void _calculatePoints() {
    _points = [];
    initialHeight = height;
    initialWidth = width;
    depth = 0;
    for (int column = _startColumnIndex(); column < _endColumnIndex(); column++) {
      for (int row = _startRowIndex(); row < _endRowIndex(); row++) {
        _points.add(math.Point(column, row));
      }
    }
  }

  math.Point<int> _spaceLevel() {
    final differHeight = height - initialHeight;
    final differWidth = width - initialWidth;

    return math.Point(
      math.max(differWidth, 0),
      math.max(differHeight, 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (availableSize != constraints.biggest || availableSize == Size.zero) {
          availableSize = constraints.biggest;
          _calculatePoints();
        }

        final remainSize = Size(
          (availableSize.width - width * tileSize(depth) + tileSpace) / 2,
          (availableSize.height - height * tileSize(depth) + tileSpace) / 2,
        );

        final spacingCell = _spaceLevel();

        return Stack(
          children: [
            Stack(
              key: ValueKey(depth),
              children: [
                for (int column = 0; column < width; column++)
                  for (int row = 0; row < height; row++)
                    if (_isBorder(spacingCell, column, row))
                      AnimatedPositioned(
                        duration: 500.ms,
                        curve: Curves.easeOutBack,
                        left: remainSize.width + column * tileSize(depth),
                        top: remainSize.height + row * tileSize(depth),
                        child: _gridTile(
                          row + column * height,
                          column: column,
                          row: row,
                        ),
                      ),
              ],
            ),
            Stack(
              children: [
                for (final point in _points.asMap().entries) _centerTile(point, remainSize, spacingCell),
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => setState(() {
                    if (depth <= 0) return;
                    depth -= 1;
                  }),
                  child: const Text('Minus'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() {
                    shownDepth += 1;
                    depth += 1;
                  }),
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _centerTile(
    MapEntry<int, math.Point<int>> point,
    Size remainSize,
    math.Point<int> spacingCell,
  ) {
    final column = point.value.x + spacingCell.x ~/ 2;
    final row = point.value.y + spacingCell.y ~/ 2;
    final coordinate = _calculateCoordinate(column, row);

    return AnimatedPositioned(
      duration: 500.ms,
      curve: Curves.easeOutBack,
      left: remainSize.width + (point.value.x + spacingCell.x ~/ 2) * tileSize(depth),
      top: remainSize.height + (point.value.y + spacingCell.y ~/ 2) * tileSize(depth),
      child: Animate(
        delay: _getDelay(
          column: column,
          row: row,
          coordinate: coordinate,
        ),
        effects: [
          // MoveEffect(
          //   duration: 200.ms,
          //   begin: Offset.zero,
          //   end: Offset(-tileSpace * coordinate.x.toDouble(), -tileSpace * coordinate.y.toDouble()),
          //   curve: Curves.easeOutBack,
          // ),
          MoveEffect(
            duration: 500.ms,
            begin: Offset(-tileSpace * coordinate.x.toDouble(), -tileSpace * coordinate.y.toDouble()),
            end: Offset.zero,
            curve: Curves.easeOutBack,
          ),
        ],
        child: _gridTile(
          point.key,
          column: point.value.x,
          row: point.value.y,
          center: true,
        ),
      ),
    );
  }

  // TODO: Change approach to List of Point for stable the state of widget
  Widget _gridTile(
    int index, {
    required int column,
    required int row,
    Color? color,
    bool center = false,
  }) {
    final coordinate = _calculateCoordinate(column, row);

    return Animate(
      delay: _getDelay(
        column: column,
        row: row,
        coordinate: coordinate,
      ),
      effects: center
          ? []
          : [
              MoveEffect(
                duration: 500.ms,
                begin: removed
                    ? Offset.zero
                    : Offset(-tileSpace * coordinate.x.toDouble(), -tileSpace * coordinate.y.toDouble()),
                end: removed
                    ? Offset(-tileSpace * coordinate.x.toDouble(), -tileSpace * coordinate.y.toDouble())
                    : Offset.zero,
                curve: Curves.easeOutBack,
              ),
              FadeEffect(
                begin: removed ? 1 : 0,
                end: removed ? 0 : 1,
                curve: Curves.easeOutBack,
              ),
            ],
      child: AnimatedContainer(
        duration: 500.ms,
        width: adaptiveSize(depth),
        height: adaptiveSize(depth),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color ?? widget.color,
        ),
      ),
    );
  }

  late bool removed = false;

  Size availableSize = Size.zero;
  double tileSpace = 12;
  double tileSize(int depth) => adaptiveSize(depth) + tileSpace;

  double adaptiveSize(int depth) => normalSize - depth * 8;
  double normalSize = 56;

  int get height => _calculateHeight(availableSize, tileSize(depth));
  int get width => _calculateWidth(availableSize, tileSize(depth));
  int _calculateHeight(Size size, double tileSize) => (size.height - tileSpace) ~/ tileSize;
  int _calculateWidth(Size size, double tileSize) => (size.width - tileSpace) ~/ tileSize;

  int get maxColumn => width % 2 == 0 ? width ~/ 2 - 1 : width ~/ 2;
  int get maxRow => height % 2 == 0 ? height ~/ 2 - 1 : height ~/ 2;

  double transitionDelay = 300;

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
    required int column,
    required int row,
    required math.Point<int> coordinate,
  }) {
    double transitionDelayUnit = transitionDelay / (maxColumn + maxRow);
    final center = calculateCenter(column, row);

    var delay = (coordinate.x.abs() + coordinate.y.abs());
    if (removed) {
      delay = delay;
    }

    return (delay * transitionDelayUnit).ms;
  }
}
