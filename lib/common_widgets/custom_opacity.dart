import 'dart:async';
import 'package:flutter/material.dart';

class CustomOpacityWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double opacity;
  final bool isRepeatable;

  const CustomOpacityWidget({
    super.key,
    required this.child,
    this.onTap,
    this.opacity = 0.6,
    this.isRepeatable = false,
  });

  @override
  State<CustomOpacityWidget> createState() => _CustomOpacityWidgetState();
}

class _CustomOpacityWidgetState extends State<CustomOpacityWidget> {
  bool _isPressed = false;
  Timer? _repeatTimer;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);

    if (widget.isRepeatable && widget.onTap != null) {
      widget.onTap?.call();
      _repeatTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        widget.onTap?.call();
      });
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _repeatTimer?.cancel();
    _repeatTimer = null;

    if (!widget.isRepeatable) {
      widget.onTap?.call();
    }
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  @override
  void dispose() {
    _repeatTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.translucent,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 50),
        opacity: _isPressed ? widget.opacity : 1.0,
        child: widget.child,
      ),
    );
  }
}
