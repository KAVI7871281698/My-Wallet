import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SwipeButton extends StatefulWidget {
  final String text;
  final Future<void> Function() onSwipe;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Color thumbColor;
  final IconData thumbIcon;

  const SwipeButton({
    super.key,
    required this.text,
    required this.onSwipe,
    this.backgroundColor,
    this.gradient,
    this.thumbColor = Colors.white,
    this.thumbIcon = Icons.arrow_forward_ios_rounded,
  });

  @override
  State<SwipeButton> createState() => _SwipeButtonState();
}

class _SwipeButtonState extends State<SwipeButton> {
  double _dragPosition = 0;
  bool _isSwiped = false;
  final double _buttonHeight = 55.h;
  final double _thumbSize = 45.h; // Inside the button

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // max drag is total width minus thumb size minus left and right padding (5w each)
        final maxDrag = constraints.maxWidth - _thumbSize - 10.w;
        if (maxDrag <= 0) return const SizedBox();

        final Color effectiveBgColor =
            widget.backgroundColor ?? Theme.of(context).primaryColor;
            
        final Gradient effectiveGradient = widget.gradient ??
            LinearGradient(
              colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            );

        return Container(
          height: _buttonHeight,
          width: constraints.maxWidth,
          decoration: BoxDecoration(
            color: widget.backgroundColor != null && !_isSwiped ? effectiveBgColor : (_isSwiped ? Colors.green : null),
            gradient: widget.backgroundColor == null && !_isSwiped ? effectiveGradient : null,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Background Text
              Center(
                child: Text(
                  _isSwiped ? "Processing..." : widget.text,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.surface,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Draggable Thumb
              AnimatedPositioned(
                duration: _dragPosition == 0
                    ? const Duration(milliseconds: 200)
                    : Duration.zero,
                curve: Curves.easeOut,
                left: 5.w + _dragPosition,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_isSwiped) return;
                    setState(() {
                      _dragPosition += details.delta.dx;
                      if (_dragPosition < 0) _dragPosition = 0;
                      if (_dragPosition > maxDrag) _dragPosition = maxDrag;
                    });
                  },
                  onHorizontalDragEnd: (details) async {
                    if (_isSwiped) return;
                    if (_dragPosition > maxDrag * 0.75) {
                      // Trigger swipe
                      setState(() {
                        _dragPosition = maxDrag;
                        _isSwiped = true;
                      });

                      // Await the function
                      await widget.onSwipe();

                      // Reset after completion
                      if (mounted) {
                        setState(() {
                          _dragPosition = 0;
                          _isSwiped = false;
                        });
                      }
                    } else {
                      // Snap back
                      setState(() {
                        _dragPosition = 0;
                      });
                    }
                  },
                  child: Container(
                    height: _thumbSize,
                    width: _thumbSize,
                    decoration: BoxDecoration(
                      color: widget.thumbColor,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withAlpha(20),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _isSwiped
                        ? CircularProgressIndicator(
                            strokeWidth: 2,
                            color: effectiveBgColor,
                          )
                        : Icon(
                            widget.thumbIcon,
                            color: effectiveBgColor,
                            size: 20.sp,
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
