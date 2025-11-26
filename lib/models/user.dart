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
  SessionUtils._();

  factory SessionUtils() => sharedInstance();

  static final SessionUtils _instance = SessionUtils._();

  static SessionUtils sharedInstance() => _instance;

  User? currentUser;
  HabitsBloc? habitsBloc;

  Future<void> init() async {
    currentUser = await DatabaseProvider.db.getCurrentUser();
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
    habitsBloc?.add(HabitsLoad());
  }

  Future<void> logout() async {
    currentUser = null;
    await DatabaseProvider.db.deleteUser();
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

  bool isLogin() {
    return currentUser != null;
  }

  String? getUserId() {
    return currentUser?.id;
  }
}
