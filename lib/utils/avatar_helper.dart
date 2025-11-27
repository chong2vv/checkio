import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:timefly/models/user.dart';
import 'package:timefly/utils/flash_helper.dart';

class AvatarHelper {
  AvatarHelper._();

  static final ImagePicker _picker = ImagePicker();

  static Future<void> pickAndSaveAvatar(BuildContext context) async {
    final session = SessionUtils.sharedInstance();
    if (!session.isLogin()) {
      FlashHelper.toast(context, '请先登录以修改头像');
      return;
    }
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        return;
      }
      final directory = await getApplicationDocumentsDirectory();
      final filename =
          'avatar_${DateTime.now().millisecondsSinceEpoch}${p.extension(image.path)}';
      final String targetPath = p.join(directory.path, filename);
      await File(image.path).copy(targetPath);
      await session.updateAvatarPath(targetPath);
    } catch (e) {
      FlashHelper.toast(context, '选择头像失败，请重试');
      debugPrint('pick avatar error: $e');
    }
  }
}

