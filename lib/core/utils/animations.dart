import 'package:flutter/material.dart';

class FadeSlideTransition extends StatelessWidget {
  final Widget child;
  final int delayMilliseconds;
  final Duration duration;
  final Offset beginOffset;

  const FadeSlideTransition({
    super.key,
    required this.child,
    this.delayMilliseconds = 200,
    this.duration = const Duration(milliseconds: 500),
    this.beginOffset = const Offset(0, 0.05),
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: delayMilliseconds)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: duration,
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: beginOffset * (1 - value),
                  child: child,
                ),
              );
            },
            child: child,
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

class ScaleAnimation extends StatelessWidget {
  final Widget child;
  final int delayMilliseconds;

  const ScaleAnimation({
    super.key,
    required this.child,
    this.delayMilliseconds = 200,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: delayMilliseconds)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.8, end: 1),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: child,
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}