import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:timefly/blocs/habit/habit_bloc.dart';
import 'package:timefly/blocs/habit/habit_event.dart';
import 'package:timefly/db/database_provider.dart';
import 'package:timefly/models/user.dart';

class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserLoadSuccess extends UserState {
  final User? user;

  const UserLoadSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class UserLoadingInProgress extends UserState {}

class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class UserLoginEvent extends UserEvent {
  final User user;

  const UserLoginEvent(this.user);

  @override
  List<Object?> get props => [user];
}

class UserLogoutEvent extends UserEvent {}

class UserLoadEvent extends UserEvent {}

class UserBloc extends Bloc<UserEvent, UserState> {
  final HabitsBloc habitsBloc;

  UserBloc(this.habitsBloc) : super(const UserLoadSuccess(null)) {
    on<UserLoginEvent>(_mapUserLoginToState);
    on<UserLogoutEvent>(_mapUserLogoutToState);
    on<UserLoadEvent>(_mapUserLoadState);
  }

  Future<void> _mapUserLoginToState(
      UserLoginEvent event, Emitter<UserState> emit) async {
    await DatabaseProvider.db.saveUser(event.user);
    emit(UserLoadSuccess(event.user));
    habitsBloc.add(HabitsLoad());
  }

  Future<void> _mapUserLogoutToState(
      UserLogoutEvent event, Emitter<UserState> emit) async {
    await DatabaseProvider.db.deleteUser();
    emit(const UserLoadSuccess(null));
    habitsBloc.add(HabitsLoad());
  }

  Future<void> _mapUserLoadState(
      UserLoadEvent event, Emitter<UserState> emit) async {
    final user = await DatabaseProvider.db.getCurrentUser();
    emit(UserLoadSuccess(user));
    habitsBloc.add(HabitsLoad());
  }
}
