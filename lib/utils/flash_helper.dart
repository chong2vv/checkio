import 'package:flutter/material.dart';

import '../app_theme.dart';

class FlashHelper {
  static Future<void> toast(BuildContext context, String message) async {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              constraints: BoxConstraints(minHeight: 48),
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  gradient: AppTheme.appTheme.containerGradient(),
                  boxShadow: AppTheme.appTheme.coloredBoxShadow()),
              child: Text(
                message,
                style: AppTheme.appTheme.headline1(
                    textColor: Colors.white,
                    fontWeight: FontWeight.normal,
                    fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    await Future.delayed(Duration(milliseconds: 2000));

    overlayEntry.remove();
  }
}
