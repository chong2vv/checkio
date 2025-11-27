import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/material.dart';

class FluidFillIconData {
  final List<ui.Path> paths;

  FluidFillIconData(this.paths);
}

class FluidFillIcons {
  static final platform = FluidFillIconData([
    ui.Path()
      ..moveTo(0, -6)
      ..lineTo(10, -6),
    ui.Path()
      ..moveTo(5, 0)
      ..lineTo(-5, 0),
    ui.Path()
      ..moveTo(-10, 6)
      ..lineTo(0, 6),
  ]);
  // 精致的窗口/列表视图 - 带圆角的卡片式布局
  static final window = FluidFillIconData([
    // 左上卡片
    ui.Path()..addRRect(RRect.fromLTRBXY(-12, -12, -2, -2, 2.5, 2.5)),
    // 右上卡片
    ui.Path()..addRRect(RRect.fromLTRBXY(2, -12, 12, -2, 2.5, 2.5)),
    // 左下卡片
    ui.Path()..addRRect(RRect.fromLTRBXY(-12, 2, -2, 12, 2.5, 2.5)),
    // 右下卡片
    ui.Path()..addRRect(RRect.fromLTRBXY(2, 2, 12, 12, 2.5, 2.5)),
    // 内部装饰线（让卡片更精致）
    ui.Path()
      ..moveTo(-7, -12)
      ..lineTo(-7, -2),
    ui.Path()
      ..moveTo(7, -12)
      ..lineTo(7, -2),
  ]);
  static final arrow = FluidFillIconData([
    ui.Path()
      ..moveTo(-10, 6)
      ..lineTo(10, 6)
      ..moveTo(10, 6)
      ..lineTo(3, 0)
      ..moveTo(10, 6)
      ..lineTo(3, 12),
    ui.Path()
      ..moveTo(10, -6)
      ..lineTo(-10, -6)
      ..moveTo(-10, -6)
      ..lineTo(-3, 0)
      ..moveTo(-10, -6)
      ..lineTo(-3, -12),
  ]);
  // 温馨的用户头像 - 带微笑的圆形头像
  static final user = FluidFillIconData([
    // 头部圆形
    ui.Path()..addOval(Rect.fromLTRB(-8, -14, 8, 2)),
    // 身体（半圆）
    ui.Path()
      ..moveTo(-10, 2)
      ..arcTo(Rect.fromLTRB(-10, 2, 10, 18), math.pi, math.pi, false),
    // 微笑（更明显的弧形）
    ui.Path()
      ..moveTo(-5, -4)
      ..quadraticBezierTo(0, 0, 5, -4),
  ]);

  // 温馨的家 - 带窗户和门的房子
  static final home = FluidFillIconData([
    // 房子主体
    ui.Path()..addRRect(RRect.fromLTRBXY(-10, 0, 10, 12, 2, 2)),
    // 屋顶
    ui.Path()
      ..moveTo(-12, 0)
      ..lineTo(12, 0)
      ..lineTo(0, -14)
      ..close(),
    // 门
    ui.Path()..addRRect(RRect.fromLTRBXY(-3, 4, 3, 12, 1.5, 1.5)),
    // 左窗户
    ui.Path()..addRRect(RRect.fromLTRBXY(-8, 2, -4, 6, 1, 1)),
    // 右窗户
    ui.Path()..addRRect(RRect.fromLTRBXY(4, 2, 8, 6, 1, 1)),
  ]);

  // 温馨的进度图表 - 圆润的柱状图带上升趋势
  static final progress = FluidFillIconData([
    // 底部基线
    ui.Path()
      ..moveTo(-12, 10)
      ..lineTo(12, 10),
    // 第一个柱子（圆角矩形）
    ui.Path()..addRRect(RRect.fromLTRBXY(-10, 6, -6, 10, 1.5, 1.5)),
    // 第二个柱子（稍高）
    ui.Path()..addRRect(RRect.fromLTRBXY(-4, 2, 0, 10, 1.5, 1.5)),
    // 第三个柱子（更高）
    ui.Path()..addRRect(RRect.fromLTRBXY(2, -2, 6, 10, 1.5, 1.5)),
    // 第四个柱子（最高）
    ui.Path()..addRRect(RRect.fromLTRBXY(8, -6, 12, 10, 1.5, 1.5)),
    // 上升趋势线（平滑曲线）
    ui.Path()
      ..moveTo(-8, 8)
      ..quadraticBezierTo(0, 0, 10, -4),
  ]);
}
