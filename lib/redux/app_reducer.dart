import 'dart:convert';
import 'package:redux/redux.dart' as redux;
import 'app_state.dart';
import 'actions.dart';
import '../utils/fileStorage.dart';

T orElseNull<T>() => null;

class ThemeReducer extends redux.Reducer<ThemeState, Action> {
  final Map<Type, Function> _mapper = const <Type, Function>{
    ChangeThemeAction: _changeThemeAction
  };

  @override
  ThemeState reduce(ThemeState state, Action action) {
    Function reducer = _mapper[action.runtimeType];
    // I do believe in my heart that "reducer" IS A FUNCTION
    // ignore: invocation_of_non_function
    return reducer != null ? reducer(state, action) : state;
  }
}

ThemeState _changeThemeAction(ThemeState state, ChangeThemeAction action) {
  ThemeState newState = state.apply(
      primaryColor: action.primaryColor,
      brightness: action.brightness,
      accentColor: action.accentColor);
  saveThemeStateToFile(JSON.encode(newState.serialize()));
  return newState;
}

class ScheduleReducer extends redux.Reducer<ScheduleState, Action> {
  final Map<Type, Function> _mapper = const <Type, Function>{
    AddScheduleAction: _addScheduleAction,
    RemoveScheduleAction: _removeScheduleAction,
    SetCurrentScheduleAction: _setCurrentScheduleAction,
    SetWeeksForCurrentScheduleAction: _setWeeksForCurrentScheduleAction,
    SetSignatureMap: _setSignatureMapAction,
    AddSignature: _addSignatureAction,
  };

  @override
  ScheduleState reduce(ScheduleState state, Action action) {
    Function reducer = _mapper[action.runtimeType];
    // ignore: invocation_of_non_function
    return reducer != null ? reducer(state, action) : state;
  }
}

ScheduleState _setCurrentScheduleAction(
    ScheduleState state, SetCurrentScheduleAction action) {
  ScheduleState newState = state.apply(currentSchedule: action.schedule);
  saveScheduleStateToFile(JSON.encode(newState.serialize()));
  return newState;
}

ScheduleState _addScheduleAction(
    ScheduleState state, AddScheduleAction action) {
  ScheduleState newState =
      state.apply(schedules: state.schedules.toList()..add(action.schedule));
  saveScheduleStateToFile(JSON.encode(newState.serialize()));
  return newState;
}

ScheduleState _removeScheduleAction(
    ScheduleState state, RemoveScheduleAction action) {
  ScheduleState newState = state.apply(
      schedules: state.schedules.toList()
        ..removeWhere((schedule) => schedule.name == action.schedule),
      weeksMap: state.weeksMap..remove(action.schedule),
  );
  saveScheduleStateToFile(JSON.encode(newState.serialize()));
  return newState;
}

ScheduleState _setWeeksForCurrentScheduleAction(
    ScheduleState state, SetWeeksForCurrentScheduleAction action) {
  ScheduleState newState = state.apply(weeksMap: action.weeks);
  saveScheduleStateToFile(JSON.encode(newState.serialize()));
  return newState;
}

ScheduleState _setSignatureMapAction(
    ScheduleState state, SetSignatureMap action) {
  ScheduleState newState = state.apply(signatureMap: action.signatures);
  saveScheduleStateToFile(JSON.encode(newState.serialize()));
  return newState;
}

ScheduleState _addSignatureAction (ScheduleState state, AddSignature action) {
  ScheduleState newState = state.apply(signatureMap: state.signatureMap..addAll(action.signatures));
  saveScheduleStateToFile(JSON.encode(newState.serialize()));
  return newState;
}

class IgnoreReducer extends redux.Reducer<ScheduleState, Action> {
  final Map<Type, Function> _mapper = const <Type, Function>{
    AddHiddenBooking: _addHiddenBooking,
    RemoveHiddenBooking: _removeHiddenBooking
  };

  @override
  ScheduleState reduce(ScheduleState state, Action action) {
    Function reducer = _mapper[action.runtimeType];
    // ignore: invocation_of_non_function
    return reducer != null ? reducer(state, action) : state;
  }
}

IgnoreState _addHiddenBooking (IgnoreState state, AddHiddenBooking action) {
  return state..hiddenBookings.add(action.booking.uuid);
}

IgnoreState _removeHiddenBooking (IgnoreState state, RemoveHiddenBooking action) {
  return state..hiddenBookings.remove(action.booking.uuid);
}