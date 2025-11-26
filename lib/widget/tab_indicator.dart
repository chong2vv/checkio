import 'package:flutter/material.dart';

class BorderTabIndicator extends Decoration {
  BorderTabIndicator({
    this.indicatorHeight,
    this.textScaleFactor,
  }) : super();

  final double? indicatorHeight;
  final double? textScaleFactor;

  @override
  _BorderPainter createBoxPainter([VoidCallback? onChanged]) {
    return _BorderPainter(this, indicatorHeight, textScaleFactor, onChanged);
  }
}

class _BorderPainter extends BoxPainter {
  _BorderPainter(
    this.decoration,
    this.indicatorHeight,
    this.textScaleFactor,
    VoidCallback? onChanged,
  )   : assert(indicatorHeight == null || indicatorHeight >= 0),
        super(onChanged);

  final BorderTabIndicator decoration;
  final double? indicatorHeight;
  final double? textScaleFactor;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null) return;
    final indicatorHeightValue = indicatorHeight ?? 36.0;
    final textScaleFactorValue = textScaleFactor ?? 1.0;
    final horizontalInset = 16 - 4 * textScaleFactorValue;
    final rect = Offset(offset.dx + horizontalInset,
            (size.height / 2) - indicatorHeightValue / 2 - 1) &
        Size(size.width - 2 * horizontalInset, indicatorHeightValue);
    final paint = Paint();
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(56)),
      paint,
    );
  }
}
