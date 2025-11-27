import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timefly/models/habit.dart';
import 'package:timefly/models/user.dart';

class DatabaseProvider {
  DatabaseProvider._();

  static final DatabaseProvider db = DatabaseProvider._();

  static const String RECORDS = 'records';

  ///my database
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await createDatabase();

    return _database!;
  }

  Future<Database> createDatabase() async {
    String dbPath = await getDatabasesPath();

    return await openDatabase(
      join(dbPath, 'habitDB.db'),
      version: 1,
      onCreate: (Database database, int version) async {
        print("Creating habit table");
        await database.execute(
          "CREATE TABLE habits ("
          "id TEXT,"
          "name TEXT,"
          "iconPath TEXT,"
          "mainColor INTEGER,"
          "mark TEXT,"
          "remindTimes TEXT,"
          "period INTEGER,"
          "completeTime INTEGER,"
          "completeDays TEXT,"
          "createTime INTEGER,"
          "modifyTime INTEGER,"
          "completed INTEGER,"
          "doNum INTEGER"
          ")",
        );
        await database.execute("CREATE TABLE records ("
            "time INTEGER,"
            "habitId TEXT,"
            "content TEXT"
            ")");

        await database.execute("CREATE TABLE user ("
            "username TEXT,"
            "phone TEXT,"
            "id TEXT"
            ")");
      },
    );
  }

  Future<User?> getCurrentUser() async {
    final db = await database;
    var users = await db.query("user");
    if (users.isEmpty) {
      return null;
    }
    return User.fromJson(users[0]);
  }

  Future<bool> saveUser(User user) async {
    final db = await database;
    var index = await db.insert('user', user.toJson());
    return index > 0;
  }

  Future<bool> deleteUser() async {
    final db = await database;
    var index = await db.delete(
      'user',
    );
    return index > 0;
  }

  Future<bool> updateUser(User user) async {
    final db = await database;
    int change = await db
        .update('user', user.toJson(), where: 'id = ?', whereArgs: [user.id]);
    return change > 0;
  }

  Future<List<Habit>> getAllHabits() async {
    final db = await database;
    var habits = await db.query('habits');
    List<Habit> newHabitList = [];

    for (Map<String, dynamic> element in habits) {
      final habitId = element["id"]?.toString();
      var records = await getHabitRecords(habitId);
      Habit habit = Habit.fromJson(element, records: records);
      newHabitList.add(habit);
    }
    newHabitList
        .sort((a, b) => (b.createTime ?? 0).compareTo(a.createTime ?? 0));
    return newHabitList;
  }

  ///获取带有打卡记录的所有习惯
  Future<List<Habit>> getHabitsWithRecords() async {
    final db = await database;
    var habits = await db.query('habits');
    List<Habit> newHabitList = [];

    for (Map<String, dynamic> element in habits) {
      final habitId = element["id"]?.toString();
      var records = await getHabitRecords(habitId);
      Habit habit = Habit.fromJson(element, records: records);
      newHabitList.add(habit);
    }
    newHabitList
        .sort((a, b) => (b.createTime ?? 0).compareTo(a.createTime ?? 0));
    return newHabitList;
  }

  Future<List<Habit>> getHabitsWithCompleteTime(int completeTime) async {
    final db = await database;
    var habits = await db
        .query('habits', where: 'completeTime = ?', whereArgs: [completeTime]);
    List<Habit> newHabitList = [];
    habits.forEach((element) {
      newHabitList.add(Habit.fromJson(element));
    });
    newHabitList
        .sort((a, b) => (b.createTime ?? 0).compareTo(a.createTime ?? 0));
    return newHabitList;
  }

  /// 根据 habitId和时间范围筛选出符合条件的记录
  Future<List<HabitRecord>> getHabitRecords(String? habitId,
      {DateTime? start, DateTime? end}) async {
    if (habitId == null) {
      return [];
    }
    final db = await database;
    var rawRecords =
        await db.query(RECORDS, where: 'habitId = ?', whereArgs: [habitId]);
    if (rawRecords.isEmpty) {
      return [];
    }
    if (end != null && start != null) {
      rawRecords = rawRecords.where((element) {
        final time = element['time'] as int? ?? 0;
        return time > start.millisecondsSinceEpoch &&
            time < end.millisecondsSinceEpoch;
      }).toList();
    }
    rawRecords.sort((a, b) {
      final aTime = a['time'] as int? ?? 0;
      final bTime = b['time'] as int? ?? 0;
      return bTime.compareTo(aTime);
    });
    return rawRecords
        .map((json) => HabitRecord.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  ///获取天数分类习惯个数，用于’我的一天‘页面分类
  Future<int> getPeriodHabitsSize(int period) async {
    final db = await database;
    var habits =
        await db.query('habits', where: 'period = ?', whereArgs: [period]);
    return habits.length;
  }

  Future<Habit?> insert(Habit habit) async {
    final db = await database;
    var queryHabits =
        await db.query('habits', where: 'id = ?', whereArgs: [habit.id]);
    bool exist = false;
    queryHabits.forEach((element) {
      if (element['id'] == habit.id) {
        exist = true;
      }
    });
    if (exist) {
      print('habit has exits');
      return null;
    }
    await db.insert('habits', habit.toJson());
    return habit;
  }

  Future<bool> insertHabitRecord(HabitRecord record) async {
    final db = await database;
    int index = await db.insert(RECORDS, record.toJson());
    return index > 0;
  }

  Future<bool> deleteHabitRecord(String habitId, int time) async {
    final db = await database;
    int index = await db.delete(RECORDS,
        where: 'habitId = ? and time = ?', whereArgs: [habitId, time]);
    return index > 0;
  }

  Future<bool> updateHabitRecord(HabitRecord habitRecord) async {
    final db = await database;
    int change = await db.update(RECORDS, habitRecord.toJson(),
        where: 'time = ?', whereArgs: [habitRecord.time]);
    return change > 0;
  }

  ///更新
  Future<bool> update(Habit habit) async {
    final db = await database;
    int change = await db.update('habits', habit.toJson(),
        where: 'id = ?', whereArgs: [habit.id]);
    return change > 0;
  }
}
