import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timefly/app_theme.dart';
import 'package:timefly/blocs/theme/theme_event.dart';
import 'package:timefly/blocs/theme/theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc()
      : super(ThemeState(
            AppThemeMode.Light, AppThemeColorMode.Blue, AppFontMode.Roboto)) {
    AppTheme.appTheme
        .setThemeState(state.themeMode, state.themeColorMode, state.fontMode);
    on<ThemeChangeEvent>(_onThemeChange);
    on<ThemeLoadEvnet>(_onThemeLoad);
  }

  void _onThemeChange(ThemeChangeEvent event, Emitter<ThemeState> emit) {
    ThemeState newState =
        ThemeState(event.themeMode, event.themeColorMode, event.fontMode);
    AppTheme.appTheme.setThemeState(
        newState.themeMode, newState.themeColorMode, newState.fontMode);
    emit(newState);
  }

  Future<void> _onThemeLoad(
      ThemeLoadEvnet event, Emitter<ThemeState> emit) async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    final themeModeString = shared.getString(THEME_MODE);
    final colorModeString = shared.getString(COLOR_MODE);
    AppThemeMode appThemeMode = themeModeString != null
        ? getInitThemeMode(themeModeString)
        : AppThemeMode.Light;
    AppThemeColorMode colorMode = colorModeString != null
        ? getInitColorMode(colorModeString)
        : AppThemeColorMode.Blue;
    ThemeState newState =
        ThemeState(appThemeMode, colorMode, AppFontMode.Roboto);
    AppTheme.appTheme.setThemeState(
        newState.themeMode, newState.themeColorMode, newState.fontMode);
    emit(newState);
  }
}
