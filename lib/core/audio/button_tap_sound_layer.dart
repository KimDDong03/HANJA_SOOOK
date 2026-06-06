import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_audio_controller.dart';

class AppButtonTapSoundLayer extends ConsumerStatefulWidget {
  const AppButtonTapSoundLayer({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppButtonTapSoundLayer> createState() =>
      _AppButtonTapSoundLayerState();
}

class _AppButtonTapSoundLayerState
    extends ConsumerState<AppButtonTapSoundLayer> {
  static const _maxTapMovement = 18.0;

  Offset? _buttonDownPosition;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        _buttonDownPosition = _hasEnabledButtonAt(event.position)
            ? event.position
            : null;
      },
      onPointerUp: (event) {
        final downPosition = _buttonDownPosition;
        _buttonDownPosition = null;
        if (downPosition == null ||
            (event.position - downPosition).distance > _maxTapMovement ||
            !_hasEnabledButtonAt(event.position)) {
          return;
        }
        unawaited(ref.read(appAudioControllerProvider).playButtonTap());
      },
      onPointerCancel: (_) {
        _buttonDownPosition = null;
      },
      child: widget.child,
    );
  }

  bool _hasEnabledButtonAt(Offset globalPosition) {
    var found = false;

    void visit(Element element) {
      if (found) {
        return;
      }
      if (_isEnabledButtonWidget(element.widget) &&
          _containsGlobalPosition(element, globalPosition)) {
        found = true;
        return;
      }
      element.visitChildren(visit);
    }

    context.visitChildElements(visit);
    return found;
  }

  bool _containsGlobalPosition(Element element, Offset globalPosition) {
    final renderObject = element.renderObject;
    if (renderObject is! RenderBox ||
        !renderObject.attached ||
        !renderObject.hasSize) {
      return false;
    }
    final topLeft = renderObject.localToGlobal(Offset.zero);
    return (topLeft & renderObject.size).contains(globalPosition);
  }

  bool _isEnabledButtonWidget(Widget widget) {
    if (widget is ButtonStyleButton) {
      return widget.enabled;
    }
    if (widget is IconButton) {
      return widget.onPressed != null;
    }
    if (widget is FloatingActionButton) {
      return widget.onPressed != null;
    }
    if (widget is InkResponse) {
      return widget.onTap != null ||
          widget.onLongPress != null ||
          widget.onDoubleTap != null;
    }
    if (widget is ListTile) {
      return widget.enabled &&
          (widget.onTap != null || widget.onLongPress != null);
    }
    if (widget is Switch) {
      return widget.onChanged != null;
    }
    if (widget is Checkbox) {
      return widget.onChanged != null;
    }
    return false;
  }
}
