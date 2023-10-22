import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class SpringCard extends StatefulWidget {
  const SpringCard({super.key});

  @override
  State<SpringCard> createState() => _SpringCardState();
}

class _SpringCardState extends State<SpringCard> with TickerProviderStateMixin {
  late final _dxController = AnimationController.unbounded(vsync: this) //
    ..addListener(_onDxChanged);
  void _onDxChanged() => position.value = Offset(_dxController.value, position.value.dy);
  late final _dyController = AnimationController.unbounded(vsync: this) //
    ..addListener(_onDyChanged);
  void _onDyChanged() => position.value = Offset(position.value.dx, _dyController.value);

  late final position = ValueNotifier<Offset>(Offset.zero) //
    ..addListener(() => setState(() {}));
  Offset anchor = Offset.zero;

  SpringSimulation _createSpringSimulation(double start, double end, double velocity) => SpringSimulation(
      SpringDescription.withDampingRatio(mass: 0.5, stiffness: 100.0, ratio: 1.1), start, end, velocity);

  void withSpringTween(Offset prev, Offset next) {
    final dxSimulation = _createSpringSimulation(prev.dx, next.dx, 10);
    final dyYimulation = _createSpringSimulation(prev.dy, next.dy, 10);
    _dxController.animateWith(dxSimulation);
    _dyController.animateWith(dyYimulation);
  }

  void _cancelAnimation() {
    _dxController.stop();
    _dyController.stop();
  }

  @override
  void dispose() {
    _dxController.dispose();
    _dyController.dispose();
    position.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        _cancelAnimation();
        anchor = details.localPosition;
        position.value = details.localPosition - anchor;
      },
      onPanDown: (details) => anchor = details.localPosition,
      onPanCancel: () => withSpringTween(position.value, Offset.zero),
      onPanUpdate: (details) => position.value = details.localPosition - anchor,
      onPanEnd: (details) {
        anchor = Offset.zero;
        withSpringTween(position.value, Offset.zero);
      },
      child: Transform.translate(
        offset: position.value,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber, Colors.orange.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(10, 10),
              ),
            ],
            borderRadius: BorderRadius.circular(10),
          ),
          child: const SizedBox(height: 200, width: 300),
        ),
      ),
    );
  }
}
