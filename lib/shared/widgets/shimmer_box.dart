import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';

/// A simple pulsing placeholder used instead of blocking spinners,
/// per the design spec's "skeleton loading" guidance (section 10).
class ShimmerBox extends StatefulWidget {
  final double height;
  final double? width;
  final double radius;

  const ShimmerBox({
    super.key,
    this.height = 16,
    this.width,
    this.radius = AppRadius.small,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  // NOTE for test authors: this repeats forever by design (it's a looping
  // shimmer), which means it never "settles". A widget test that triggers
  // a metadataPending LinkItem (e.g. testing the Save Link flow) and then
  // calls tester.pumpAndSettle() will hang/time out while this is on
  // screen. Use tester.pump(const Duration(...)) with an explicit
  // duration instead of pumpAndSettle() in tests that can hit this state.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: base.withValues(alpha: 0.4 + _controller.value * 0.3),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        );
      },
    );
  }
}
