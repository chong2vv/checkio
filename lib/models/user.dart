import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timefly/blocs/habit/habit_bloc.dart';
import 'package:timefly/blocs/habit/habit_event.dart';
import 'package:timefly/db/database_provider.dart';

class User {
  final String id;
  final String username;
  final String phone;

  const User({
    required this.id,
    required this.username,
    required this.phone,
  });

  static User? fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString();
    final username = json["username"]?.toString();
    final phone = json["phone"]?.toString();
    if (id == null || username == null || phone == null) {
      return null;
    }
    return User(id: id, username: username, phone: phone);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'phone': phone,
    };
  }

  User copyWith({String? id, String? username, String? phone}) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      phone: phone ?? this.phone,
    );
  }
}

class SessionUtils {
  static const String _avatarKeyPrefix = 'user_avatar_path';

  SessionUtils._();

  factory SessionUtils() => sharedInstance();

  static final SessionUtils _instance = SessionUtils._();

  static SessionUtils sharedInstance() => _instance;

  User? currentUser;
  HabitsBloc? habitsBloc;
  final ValueNotifier<String?> avatarPathNotifier =
      ValueNotifier<String?>(null);

  Future<void> init() async {
    currentUser = await DatabaseProvider.db.getCurrentUser();
    await _loadAvatarPath();
    if (currentUser != null) {
      // ignore: avoid_print
      print('init user -- ${currentUser!.toJson()}');
    }
  }

  void setBloc(HabitsBloc habitsBloc) {
    this.habitsBloc = habitsBloc;
  }

  Future<void> login(User user) async {
    await DatabaseProvider.db.deleteUser();
    currentUser = user;
    await DatabaseProvider.db.saveUser(user);
    await _loadAvatarPath();
    habitsBloc?.add(HabitsLoad());
  }

  Future<void> logout() async {
    currentUser = null;
    await DatabaseProvider.db.deleteUser();
    avatarPathNotifier.value = null;
    habitsBloc?.add(HabitsLoad());
  }

  Future<void> updateName(String name) async {
    final user = currentUser;
    if (user == null) {
      return;
    }
    currentUser = user.copyWith(username: name);
    await DatabaseProvider.db.updateUser(currentUser!);
  }

  Future<void> updateAvatarPath(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _avatarKeyFor(currentUser);
    if (path == null || path.isEmpty) {
      await prefs.remove(key);
      avatarPathNotifier.value = null;
    } else {
      await prefs.setString(key, path);
      avatarPathNotifier.value = path;
    }
  }

  Future<void> deleteCurrentAvatarFile() async {
    final currentPath = avatarPathNotifier.value;
    if (currentPath == null) {
      return;
    }
    final file = File(currentPath);
    if (await file.exists()) {
      await file.delete();
    }
    await updateAvatarPath(null);
  }

  bool isLogin() {
    return currentUser != null;
  }

  String? getUserId() {
    return currentUser?.id;
  }

  Future<void> _loadAvatarPath() async {
    final prefs = await SharedPreferences.getInstance();
    avatarPathNotifier.value = prefs.getString(_avatarKeyFor(currentUser));
  }

  String _avatarKeyFor(User? user) {
    final id = user?.id ?? 'guest';
    return '${_avatarKeyPrefix}_$id';
  }
}
