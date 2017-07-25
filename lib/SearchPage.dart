import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stream_friends/flutter_stream_friends.dart';
import 'redux/store.dart';
import 'redux/actions.dart';
import 'utils/ScheduleMeta.dart';
import 'utils/fetchBookings.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key, this.title}) : super(key: key);

  final String title;
  static final String path = "/searchpage";

  @override
  _SearchPageState createState() => new _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ValueChangedStreamCallback<String> onTextChanged =
      new ValueChangedStreamCallback<String>();
  final List<Map> searchResults = <Map>[];
  final TextEditingController _textController = new TextEditingController();
  Choice _selectedChoice = choices[0]; // The app's "state".
  StreamSubscription searchStream;
  bool loading = false;
  var _subscribtion;

  @override
  void initState() {
    super.initState();
    _subscribtion = scheduleStore.onChange.listen((_) {
      setState(() {});
    });
  }

  _SearchPageState() {
    searchStream = new Observable<String>(onTextChanged)
        // Use distinct() to ignore all keystrokes that don't have an impact on the input field's value (brake, ctrl, shift, ..)
        .distinct((String prev, String next) => prev == next)
        // Use debounce() to prevent calling the server on fast following keystrokes
        .debounce(const Duration(milliseconds: 250))
        .doOnEach((var _) {
          setState(() {
            loading = false;
            searchResults.clear();
          });
        })
        .where((String str) => str.isNotEmpty)
        .doOnEach((var _) {
          setState(() {
            loading = true;
          });
        })
        .flatMapLatest((String value) => fetchAutoComplete(value))
        .listen((List<Map> latestResult) {
          setState(() {
            loading = false;
            if (latestResult.isNotEmpty) {
              searchResults.addAll(latestResult);
            }
          });
        }, onError: (dynamic e) {
          debugPrint("ERROR: ${e.toString()}");
          setState(() {
            loading = false;
            searchResults.clear();
          });
        }, cancelOnError: false);
  }

  @override
  void dispose() {
    super.dispose();
    searchStream.cancel();
    _subscribtion.cancel();
  }

  Observable<dynamic> fetchAutoComplete(String searchString) {
    var httpClient = createHttpClient();
    return new Observable<String>.fromFuture(httpClient.read(
            "https://kronox.mah.se/ajax/ajax_autocompleteResurser.jsp?typ=${_selectedChoice.value}&term=${searchString}"))
        .map((String response) => JSON.decode(response));
  }

  void _select(Choice choice) {
    setState(() {
      // Causes the app to rebuild with the new _selectedChoice.
      _textController.clear();
      searchResults.clear();
      _selectedChoice = choice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new IconTheme(
        data: new IconThemeData(color: Theme.of(context).accentColor),
        child: new Scaffold(
            appBar: new AppBar(
              title: buildSearch(),
            ),
            body: loading
                ? new Center(child: new CircularProgressIndicator())
                : buildResults()));
  }

  Widget buildSearch() {
    return new Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: new Row(children: <Widget>[
        new Flexible(
          child: new TextField(
            style: new TextStyle(fontSize: 20.0),
            autofocus: true,
            onChanged: onTextChanged,
            decoration: new InputDecoration.collapsed(
                hintText: "Search for ${_selectedChoice.title}"),
            controller: _textController,
          ),
        ),
        new Container(
            child: new IconButton(
          icon: _textController.text.isEmpty
              ? new Icon(Icons.search)
              : new Icon(Icons.clear),
          onPressed:
              _textController.text.isEmpty ? null : _textController.clear,
        )),
        new PopupMenuButton<Choice>(
          // overflow menu
          onSelected: _select,
          itemBuilder: (BuildContext context) {
            return choices.map((Choice choice) {
              return new PopupMenuItem<Choice>(
                value: choice,
                child: new Text(choice.title),
              );
            }).toList();
          },
        ),
      ]),
    );
  }

  Widget buildResults() {
    return new Builder(builder: (BuildContext context) {
      return new Column(children: <Widget>[
        new Flexible(
            child: new ListView.builder(
          padding: new EdgeInsets.all(8.0),
          reverse: false,
          itemBuilder: (_, index) =>
              buildResultCard(searchResults[index], context),
          itemCount: searchResults.length,
        ))
      ]);
    });
  }

  Widget buildResultCard(Map result, BuildContext context) {
    String name = result["value"];
    String description =
        result["label"].replaceAll(new RegExp(r"<(?:.|\n)*?>"), "");
    TextEditingController controller = new TextEditingController(text: name);

    Function onPressed = () {
      showDialog(
          context: context,
          child: new AlertDialog(
            title: new Text("Namnge ditt schema"),
            content: new TextField(
              autofocus: true,
              controller: controller,
            ),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    String givenName = controller.text;
                    ScheduleMeta schedule = new ScheduleMeta(
                        givenName: givenName,
                        name: name,
                        type: _selectedChoice.value,
                        description: description);

                    scheduleStore
                        .dispatch(new AddScheduleAction(schedule: schedule));

                    scheduleStore.dispatch(
                        new SetCurrentScheduleAction(schedule: schedule));

                    fetchAllSchedules(scheduleStore.state.schedules)
                        .then((weeks) {
                      scheduleStore.dispatch(
                          new SetWeeksForCurrentScheduleAction(weeks: weeks));
                    });

                    Scaffold.of(context).showSnackBar(new SnackBar(
                          content: new Text("Lade till " + givenName),
                          action: new SnackBarAction(
                              label: "Ångra",
                              onPressed: () {
                                scheduleStore.dispatch(
                                    new RemoveScheduleAction(schedule: name));

                                Scaffold.of(context).showSnackBar(new SnackBar(
                                      content: new Text(
                                          "Ångrade tillägning av " + givenName),
                                    ));
                              }),
                        ));

                    Navigator.of(context).pop();
                  },
                  child: new Text("Lägg till")),
            ],
          ));
    };

    return new Card(
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new ListTile(
            leading: const Icon(Icons.schedule),
            title: new Text(name),
            subtitle: new Text(description),
            isThreeLine: true,
            dense: true,
          ),
          new ButtonTheme.bar(
            child: new ButtonBar(
              children: <Widget>[
                new FlatButton(
                    child: const Text('Lägg till schema'),
                    onPressed: scheduleStore.state.schedules
                            .any((schedule) => schedule.name == name)
                        ? null
                        : onPressed)
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Choice {
  const Choice({this.title, this.value});
  final String title;
  final String value;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Program', value: 'program'),
  const Choice(title: 'Kurs', value: 'kurs'),
];