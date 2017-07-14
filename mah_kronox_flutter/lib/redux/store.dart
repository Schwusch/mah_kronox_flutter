import 'app_state.dart';
import 'actions.dart';
import 'app_reducer.dart';
import 'package:redux/redux.dart' as redux;

class ThemeStore extends redux.Store<ThemeState, Action> {
  ThemeStore(
      {ThemeState initialState,
        redux.Reducer<ThemeState, Action> reducer})
      : super(reducer ?? new ThemeReducer(),
      initialState: initialState ?? new ThemeState.initial());
}

ThemeStore themeStore;