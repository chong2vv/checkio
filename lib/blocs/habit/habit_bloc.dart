import 'package:bloc/bloc.dart';
import 'package:timefly/blocs/habit/habit_event.dart';
import 'package:timefly/blocs/habit/habit_state.dart';
import 'package:timefly/db/database_provider.dart';
import 'package:timefly/models/habit.dart';

class HabitsBloc extends Bloc<HabitsEvent, HabitsState> {
  ///初始化状态为正在加载
  HabitsBloc() : super(HabitsLoadInProgress()) {
    on<HabitsLoad>(_mapHabitsLoadToState);
    on<HabitsAdd>(_mapHabitsAddToState);
    on<HabitUpdate>(_mapHabitUpdateToState);
  }

  void _mapHabitsLoadToState(
      HabitsLoad event, Emitter<HabitsState> emit) async {
    try {
      // 先尝试加载数据，不管是否登录
      List<Habit> habits = await DatabaseProvider.db.getAllHabits();
      print('Loaded habits: ${habits.length}');
      emit(HabitLoadSuccess(habits));
    } catch (e, stackTrace) {
      print('Error loading habits: $e');
      print('Stack trace: $stackTrace');
      // 如果出错，返回空列表而不是失败状态，避免页面显示错误
      emit(HabitLoadSuccess([]));
    }
  }

  Future<void> _mapHabitsAddToState(
      HabitsAdd event, Emitter<HabitsState> emit) async {
    if (state is HabitLoadSuccess) {
      final List<Habit> habits = List.from((state as HabitLoadSuccess).habits)
        ..add(event.habit);
      emit(HabitLoadSuccess(habits));
      try {
        final result = await DatabaseProvider.db.insert(event.habit);
        if (result == null) {
          print('Failed to insert habit: ${event.habit.id}');
        } else {
          print('Successfully inserted habit: ${event.habit.id}');
        }
      } catch (e) {
        print('Error inserting habit: $e');
        // 如果插入失败，从列表中移除
        final List<Habit> updatedHabits =
            List.from((state as HabitLoadSuccess).habits);
        updatedHabits.removeWhere((h) => h.id == event.habit.id);
        emit(HabitLoadSuccess(updatedHabits));
      }
    }
  }

  Future<void> _mapHabitUpdateToState(
      HabitUpdate event, Emitter<HabitsState> emit) async {
    if (state is HabitLoadSuccess) {
      final List<Habit> habits = (state as HabitLoadSuccess)
          .habits
          .map((habit) => habit.id == event.habit.id ? event.habit : habit)
          .toList();
      emit(HabitLoadSuccess(habits));
      try {
        final success = await DatabaseProvider.db.update(event.habit);
        if (!success) {
          print('Failed to update habit: ${event.habit.id}');
        } else {
          print('Successfully updated habit: ${event.habit.id}');
        }
      } catch (e) {
        print('Error updating habit: $e');
      }
    }
  }
}
