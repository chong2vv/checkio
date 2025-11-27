import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:timefly/blocs/habit/habit_bloc.dart';
import 'package:timefly/blocs/habit/habit_event.dart';
import 'package:timefly/blocs/habit/habit_state.dart';
import 'package:timefly/db/database_provider.dart';
import 'package:timefly/models/habit.dart';

class RecordState extends Equatable {
  const RecordState();

  @override
  List<Object> get props => [];
}

class RecordLoadSuccess extends RecordState {
  final List<HabitRecord> records;

  RecordLoadSuccess(this.records);

  @override
  List<Object> get props => [records];
}

class RecordLoadInProgress extends RecordState {}

class RecordLoadFailure extends RecordState {}

class RecordEvent extends Equatable {
  const RecordEvent();

  @override
  List<Object> get props => [];
}

///加载数据库数据事件
class RecordLoad extends RecordEvent {
  final String habitId;
  final DateTime start;
  final DateTime end;

  RecordLoad(this.habitId, this.start, this.end);

  @override
  List<Object> get props => [habitId, start, end];
}

///添加一个数据
class RecordAdd extends RecordEvent {
  final HabitRecord record;

  RecordAdd(this.record);

  @override
  List<Object> get props => [record];
}

class RecordDelete extends RecordEvent {
  final String habitId;
  final int time;

  RecordDelete(this.habitId, this.time);

  @override
  List<Object> get props => [habitId, time];
}

///更新
class RecordUpdate extends RecordEvent {
  final HabitRecord record;

  RecordUpdate(this.record);

  @override
  List<Object> get props => [record];
}

class RecordBloc extends Bloc<RecordEvent, RecordState> {
  final HabitsBloc habitsBloc;

  ///初始化状态为正在加载
  RecordBloc(this.habitsBloc) : super(RecordLoadInProgress()) {
    on<RecordLoad>(_mapRecordLoadToState);
    on<RecordAdd>(_mapRecordAddToState);
    on<RecordUpdate>(_mapRecordUpdateToState);
    on<RecordDelete>(_mapRecordDeleteToState);
  }

  Future<void> _mapRecordLoadToState(
      RecordLoad event, Emitter<RecordState> emit) async {
    try {
      List<HabitRecord> records;
      if (habitsBloc.state is HabitLoadSuccess) {
        Habit habit = (habitsBloc.state as HabitLoadSuccess)
            .habits
            .firstWhere((habit) => habit.id == event.habitId);
        records = habit.records;

        if (records.isNotEmpty) {
          records = records
              .where((element) =>
                  element.time > event.start.millisecondsSinceEpoch &&
                  element.time < event.end.millisecondsSinceEpoch)
              .toList();
          records.sort((a, b) => b.time - a.time);
        }
        emit(RecordLoadSuccess(records));
        return;
      }
      records = [];
      emit(RecordLoadSuccess(records));
    } catch (_) {
      emit(RecordLoadFailure());
    }
  }

  Future<void> _mapRecordAddToState(
      RecordAdd event, Emitter<RecordState> emit) async {
    try {
      if (state is RecordLoadSuccess) {
        final List<HabitRecord> records =
            List.from((state as RecordLoadSuccess).records)
              ..insert(0, event.record);
        DatabaseProvider.db.insertHabitRecord(event.record);
        if (habitsBloc.state is HabitLoadSuccess) {
          Habit currentHabit = (habitsBloc.state as HabitLoadSuccess)
              .habits
              .firstWhere((habit) => habit.id == event.record.habitId);
          habitsBloc.add(HabitUpdate(currentHabit.copyWith(
              records: List.from(currentHabit.records)..add(event.record))));
        }
        emit(RecordLoadSuccess(records));
      }
    } catch (e) {}
  }

  Future<void> _mapRecordUpdateToState(
      RecordUpdate event, Emitter<RecordState> emit) async {
    try {
      if (state is RecordLoadSuccess) {
        final List<HabitRecord> records = (state as RecordLoadSuccess)
            .records
            .map((record) =>
                record.time == event.record.time ? event.record : record)
            .toList();
        emit(RecordLoadSuccess(records));
        DatabaseProvider.db.updateHabitRecord(event.record);

        if (habitsBloc.state is HabitLoadSuccess) {
          Habit currentHabit = (habitsBloc.state as HabitLoadSuccess)
              .habits
              .firstWhere((habit) => habit.id == event.record.habitId);
          List<HabitRecord> currentHabitRecords =
              List<HabitRecord>.from(currentHabit.records);
          for (int i = 0; i < currentHabitRecords.length; i++) {
            if (currentHabitRecords[i].time == event.record.time) {
              currentHabitRecords[i] = event.record;
            }
          }
          habitsBloc.add(
              HabitUpdate(currentHabit.copyWith(records: currentHabitRecords)));
        }
      }
    } catch (e) {}
  }

  Future<void> _mapRecordDeleteToState(
      RecordDelete event, Emitter<RecordState> emit) async {
    try {
      if (state is RecordLoadSuccess) {
        final List<HabitRecord> records =
            List.from((state as RecordLoadSuccess).records)
              ..removeWhere((record) => record.time == event.time);
        emit(RecordLoadSuccess(records));
        DatabaseProvider.db.deleteHabitRecord(event.habitId, event.time);

        if (habitsBloc.state is HabitLoadSuccess) {
          Habit currentHabit = (habitsBloc.state as HabitLoadSuccess)
              .habits
              .firstWhere((habit) => habit.id == event.habitId);
          habitsBloc.add(HabitUpdate(currentHabit.copyWith(
              records: List.from(currentHabit.records)
                ..removeWhere((record) => record.time == event.time))));
        }
      }
    } catch (e) {}
  }
}
