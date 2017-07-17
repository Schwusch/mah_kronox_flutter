import 'package:redux/redux.dart' as redux;
import 'app_state.dart';
import 'actions.dart';

T orElseNull<T>() => null;

class ThemeReducer extends redux.Reducer<ThemeState, Action> {
  final Map<Type, Function> _mapper = const <Type, Function>{ChangeThemeAction: _changeThemeAction};

  @override
  ThemeState reduce(ThemeState state, Action action) {
    Function reducer = _mapper[action.runtimeType];
    // I do believe in my heart that "reducer" IS A FUNCTION
    // ignore: invocation_of_non_function
    return reducer != null ? reducer(state, action) : state;
  }
}

ThemeState _changeThemeAction(ThemeState state, ChangeThemeAction action) {
  return state.apply(
      primaryColor: action.primaryColor,
      brightness: action.brightness,
      accentColor: action.accentColor);
}

class ScheduleReducer extends redux.Reducer<ScheduleState, Action> {
  final Map<Type, Function> _mapper = const <Type, Function>{
    AddScheduleAction: _addScheduleAction,
    RemoveScheduleAction: _removeScheduleAction
  };

  @override
  ScheduleState reduce(ScheduleState state, Action action) {
    Function reducer = _mapper[action.runtimeType];
    // ignore: invocation_of_non_function
    return reducer != null ? reducer(state, action) : state;
  }
}

ScheduleState _addScheduleAction(ScheduleState state, AddScheduleAction action) {
  return state.apply(schedules: state.schedules.toList()..add(action.schedule));
}

ScheduleState _removeScheduleAction(ScheduleState state, RemoveScheduleAction action) {
  return state.apply(schedules: state.schedules.toList()..remove(action.schedule));
}