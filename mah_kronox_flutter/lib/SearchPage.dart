import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stream_friends/flutter_stream_friends.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SearchPageState createState() => new _SearchPageState();
}


class _SearchPageState extends State<SearchPage> {
  final ValueChangedStreamCallback<String> onTextChanged = new ValueChangedStreamCallback<String>();
  List searchResults;
  bool hasError = false;
  bool isLoading = false;

  _SearchPageState() {
    new Observable<String>(onTextChanged)
    // Use distinct() to ignore all keystrokes that don't have an impact on the input field's value (brake, ctrl, shift, ..)
        .distinct((String prev, String next) => prev == next)
    // Use debounce() to prevent calling the server on fast following keystrokes
        .debounce(const Duration(milliseconds: 250))
    // Use call(onData) to clear the previous results / errors and begin showing the loading state
        .doOnEach((var _) {
      setState(() {
        hasError = false;
        isLoading = true;
        searchResults = null;
      });
    })
        .flatMapLatest((String value) => fetchAutoComplete(value))
        .listen((List latestResult) {
      debugPrint(latestResult.toString());
      // If a result has been returned, disable the loading and error states and save the latest result
      setState(() {
        isLoading = false;
        hasError = false;
        searchResults = latestResult;
      });
    }, onError: (dynamic e) {
      debugPrint("ERROR: ${e.toString()}");
      setState(() {
        isLoading = false;
        hasError = true;
        searchResults = null;
      });
    }, cancelOnError: false);
  }

  Observable<dynamic> fetchAutoComplete(String searchString) {
    var httpClient = createHttpClient();
    return  new Observable<String>.fromFuture(
        httpClient.read("https://kronox.mah.se/ajax/ajax_autocompleteResurser.jsp?typ=program&term=${searchString}")
    )
        .map((String response) => JSON.decode(response));
  }

  @override
  Widget build(BuildContext context) {

    return new IconTheme(
        data: new IconThemeData(color: Theme.of(context).accentColor),
        child: new Scaffold(
          appBar: new AppBar(
            title: new Text(widget.title),
            actions: <Widget> [
              new IconButton(
                icon: new Icon(Icons.android),
                tooltip: "Test button to show another view",
                onPressed: () {
                  Navigator.of(context).pushNamed('/schedule');
                },
              )],
          ),
          body: buildSearch(),
          floatingActionButton: new FloatingActionButton(
              child: new Icon(Icons.info),
              onPressed: () => showAboutDialog(
                  context: context,
                  applicationName: "MAH Schema",
                  applicationVersion: "0.0.1",
              )),
        )
    );
  }

  Widget buildSearch() {
    return new Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: new Column(
        children: <Widget>[
          new Row(
              children: <Widget>[
                new Flexible(
                  child: new TextField(
                    onChanged: onTextChanged,
                    decoration: new InputDecoration.collapsed(
                        hintText: "Search for program or course"),
                  ),
                ),
                new Container(
                    margin: new EdgeInsets.symmetric(horizontal: 4.0),
                    child: new Icon(Icons.search)
                ),
              ]
          ),
          new Text(
              searchResults == null ? "Nothing..." : searchResults.length == 0 ? "No results" : searchResults[0]["label"].replaceAll(new RegExp(r"<(?:.|\n)*?>"), "")
          )
        ],
      )
    );
  }
}
