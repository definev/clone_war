import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum GridType { inner, border, full }

class GridLayoutChallenge extends StatefulWidget {
  const GridLayoutChallenge({Key? key}) : super(key: key);

  @override
  State<GridLayoutChallenge> createState() => _GridLayoutChallengeState();
}

class _GridLayoutChallengeState extends State<GridLayoutChallenge> {
  int depth = 3;
  int shownDepth = 3;
  bool animate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => setState(() {
              if (depth <= 0 || animate) return;
              depth -= 1;
              animate = true;
            }),
            icon: const Icon(Icons.minimize),
          ),
          IconButton(
            onPressed: () => setState(() {
              if (shownDepth >= 4 || animate) return;
              shownDepth += 1;
              depth += 1;
              animate = true;
            }),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Stack(
        children: [
          for (int currDepth = 0; currDepth < shownDepth; currDepth++) _buildGridLayoutLayer(currDepth),
        ],
      ),
    );
  }

  Widget _buildGridLayoutLayer(int currDepth) {
    return GridLayout(
      key: ValueKey('grid-layout-$currDepth'),
      type: currDepth == 0 ? GridType.border : GridType.border,
      depth: math.Point(currDepth + 1, currDepth + 1),
      level: depth,
      removed: currDepth >= depth,
      onAnimationFinished: () => setState(() => animate = false),
      onRemoveFinished: () => setState(() => shownDepth = depth),
      color: [Colors.amber, Colors.tealAccent, Colors.blueAccent, Colors.white][currDepth % 4],
    );
  }
}

class GridLayout extends StatefulWidget {
  final GridType type;
  final math.Point<int> depth;
  final int level;
  final Color color;
  final bool removed;
  final VoidCallback onRemoveFinished;
  final VoidCallback onAnimationFinished;

  const GridLayout({
    Key? key,
    required this.type,
    required this.depth,
    required this.level,
    required this.onRemoveFinished,
    required this.onAnimationFinished,
    this.color = Colors.white,
    this.removed = false,
  }) : super(key: key);

  @override
  State<GridLayout> createState() => _GridLayoutState();
}

class _GridLayoutState extends State<GridLayout> {
  int _startColumnIndex() => widget.type == GridType.inner ? widget.depth.x : 0;
  int _endColumnIndex() => widget.type == GridType.inner ? width - widget.depth.x : width;
  int _startRowIndex() => widget.type == GridType.inner ? widget.depth.y : 0;
  int _endRowIndex() => widget.type == GridType.inner ? height - widget.depth.y : height;
  bool _showTile(int column, int row) {
    switch (widget.type) {
      case GridType.border:
        if (column < widget.depth.x - 1 ||
            row < widget.depth.y - 1 ||
            column > _endColumnIndex() - widget.depth.x ||
            row > _endRowIndex() - widget.depth.y) {
          return false;
        }
        return column < widget.depth.x ||
            row < widget.depth.y ||
            column >= _endColumnIndex() - widget.depth.x ||
            row >= _endRowIndex() - widget.depth.y;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        availableSize = constraints.biggest;
        final remainSize = Size(
          (availableSize.width - width * tileSize + tileSpace) / 2,
          (availableSize.height - height * tileSize + tileSpace) / 2,
        );

        return Stack(
          children: [
            // TODO: This not work for GridType.full
            for (int column = _startColumnIndex(); column < _endColumnIndex(); column++)
              for (int row = _startRowIndex(); row < _endRowIndex(); row++)
                if (_showTile(column, row))
                  AnimatedPositioned(
                    duration: 200.ms,
                    left: remainSize.width + column * tileSize,
                    top: remainSize.height + row * tileSize,
                    child: _gridTile(column, row),
                  ),
          ],
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant GridLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.removed != widget.removed) {
      removed = widget.removed;
      setState(() {});
    }
  }

  // TODO: Change approach to List of Point for stable the state of widget
  Widget _gridTile(int column, int row) {
    final coordinate = _calculateCoordinate(column, row);

    return Animate(
      key: ValueKey('$coordinate: $removed'),
      delay: _getDelay(
        column: column,
        row: row,
        coordinate: coordinate,
      ),
      onComplete: (_) {
        widget.onAnimationFinished();
        if (removed) {
          widget.onRemoveFinished();
        }
      },
      effects: [
        MoveEffect(
          duration: 1000.ms,
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
        const ThenEffect(),
      ],
      child: AnimatedContainer(
        duration: 200.ms,
        width: normalSize,
        height: normalSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: widget.color,
        ),
      ),
    );
  }

  late bool removed = widget.removed;

  Size availableSize = Size.zero;
  double tileSpace = 12;
  double get tileSize => normalSize + tileSpace;

  // TODO(definev): This must be dynamic base on the depth level
  double get normalSize => 56;

  int get height => (availableSize.height - 12) ~/ tileSize;
  int get width => (availableSize.width - 12) ~/ tileSize;

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
      delay = center.x + center.y - delay;
    }

    return (delay * transitionDelayUnit).ms;
  }
}
