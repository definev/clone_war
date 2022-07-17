import 'package:flutter/material.dart';

class TouchHoverRegion extends StatefulWidget {
  const TouchHoverRegion({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  State<TouchHoverRegion> createState() => _TouchHoverRegionState();
}

class _TouchHoverRegionState extends State<TouchHoverRegion> {
  final List<_TouchHoverDectectorElement> _elements = [];

  TouchHoverDelegate? _delegate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: _onLongPressStart,
      onLongPressMoveUpdate: _onLongPressUpdate,
      onLongPressEnd: _onLongPressEnd,
      child: widget.child,
    );
  }

  void _onLongPressStart(LongPressStartDetails details) {
    _findSelectedChildFromOffset(details.localPosition);
  }

  void _onLongPressUpdate(LongPressMoveUpdateDetails details) {
    _findSelectedChildFromOffset(details.localPosition);
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    _findSelectedChildFromOffset(details.localPosition);
    _delegate?.onExit();
    _delegate = null;
  }

  void _findSelectedChildFromOffset(Offset offset) {
    final ancestor = context.findRenderObject();
    for (_TouchHoverDectectorElement element in List.from(_elements)) {
      if (element.containsOffset(ancestor, offset)) {
        if (_delegate != null) {
          if (_delegate!.key == element.widget.delegate.key) {
            return;
          } else {
            _delegate!.onExit();
          }
        }
        Future.microtask(() {
          _delegate = element.widget.delegate;
          _delegate!.onEnter();
        });
      }
    }
  }
}

class TouchHoverDectector extends ProxyWidget {
  const TouchHoverDectector({
    Key? key,
    required this.delegate,
    required Widget child,
  }) : super(key: key, child: child);

  final TouchHoverDelegate delegate;

  @override
  ProxyElement createElement() => _TouchHoverDectectorElement(this);
}

class _TouchHoverDectectorElement extends ProxyElement {
  _TouchHoverDectectorElement(TouchHoverDectector widget) : super(widget);

  _TouchHoverRegionState? _ancestorState;

  @override
  TouchHoverDectector get widget => super.widget as TouchHoverDectector;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    _ancestorState = parent?.findAncestorStateOfType<_TouchHoverRegionState>();
    _ancestorState?._elements.add(this);
  }

  @override
  void unmount() {
    _ancestorState?._elements.remove(this);
    _ancestorState = null;
    super.unmount();
  }

  bool containsOffset(RenderObject? ancestor, Offset offset) {
    final RenderBox box = renderObject as RenderBox;
    final rect = box.localToGlobal(Offset.zero, ancestor: ancestor) & box.size;
    return rect.contains(offset);
  }

  @override
  void notifyClients(covariant ProxyWidget oldWidget) {}
}

class TouchHoverDelegate {
  final Object key;
  final VoidCallback onEnter;
  final VoidCallback onExit;

  const TouchHoverDelegate({
    required this.key,
    required this.onEnter,
    required this.onExit,
  });
}
