import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class RiveoCard extends StatefulWidget {
  const RiveoCard({
    super.key,
    required this.hiddenChild,
    required this.child,
    this.radius = 20,
    this.padding = const EdgeInsets.fromLTRB(20, 70, 20, 20),
    required this.onHorizontalSwipe,
    required this.onVerticalDrag,
  });

  final double radius;
  final Widget hiddenChild;
  final Widget child;
  final EdgeInsets padding;
  final ValueChanged<AxisDirection> onHorizontalSwipe;
  final ValueChanged<double> onVerticalDrag;

  @override
  State<RiveoCard> createState() => _RiveoCardState();
}

class _RiveoCardState extends State<RiveoCard> with SingleTickerProviderStateMixin {
  Rect getRect(double width, double height) => Rect.fromLTRB(
      widget.padding.left, widget.padding.top, width - widget.padding.right, height - widget.padding.bottom);

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: 300.ms);
    _controller.addListener(() => setState(() => widget.onVerticalDrag(_animation.value)));
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.ease,
      reverseCurve: Curves.easeInOutCubicEmphasized,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: widget.padding,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.radius),
                  child: widget.hiddenChild,
                ),
              ),
            ),
            Positioned.fill(
              child: ShaderBuilder(
                assetKey: 'shaders/vert_riveo_page_curl.frag',
                (context, shader, child) {
                  return AnimatedSampler(
                    (image, size, canvas) {
                      final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
                      final rect = getRect(
                        image.width.toDouble() / devicePixelRatio,
                        image.height.toDouble() / devicePixelRatio,
                      );

                      shader
                        ..setImageSampler(0, image)
                        // Size
                        ..setFloat(0, image.width.toDouble() / devicePixelRatio)
                        ..setFloat(1, image.height.toDouble() / devicePixelRatio)
                        // Container
                        ..setFloat(2, rect.left)
                        ..setFloat(3, rect.top)
                        ..setFloat(4, rect.right)
                        ..setFloat(5, rect.bottom)
                        // Progress
                        ..setFloat(6, _animation.value)
                        // Radius
                        ..setFloat(7, max(widget.radius, 0))
                        // Cylinder radius
                        ..setFloat(8, rect.height / pi - 10);

                      canvas
                        ..save()
                        ..drawRect(
                          Offset.zero & size,
                          Paint()..shader = shader,
                        )
                        ..restore();
                    },
                    child: child!,
                  );
                },
                child: Padding(
                  padding: widget.padding,
                  child: GestureDetector(
                    onVerticalDragDown: (details) => _controller.stop(),
                    onVerticalDragUpdate: (details) {
                      _controller.value = min(
                        _controller.value + -details.delta.dy / (constraints.maxHeight - widget.padding.vertical),
                        1.2,
                      );
                    },
                    onVerticalDragEnd: (details) {
                      final primaryVelocity = details.primaryVelocity ?? 0;
                      if (primaryVelocity < -400) {
                        _controller.forward();
                      } else if (primaryVelocity > 400) {
                        _controller.reverse();
                      } else if (_controller.value > 0.5) {
                        _controller.forward();
                      } else {
                        _controller.reverse();
                      }
                    },
                    onHorizontalDragEnd: (details) {
                      final primaryVelocity = details.primaryVelocity ?? 0;
                      if (primaryVelocity > 400) {
                        widget.onHorizontalSwipe(AxisDirection.right);
                      } else if (primaryVelocity < -400) {
                        widget.onHorizontalSwipe(AxisDirection.left);
                      }
                    },
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
