import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stream_friends/flutter_stream_friends.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key, this.title}) : super(key: key);

  final String title;
  static final String path = "/searchpage";

  @override
  _SearchPageState createState() => new _SearchPageState();
}


class _SearchPageState extends State<SearchPage> {
  final ValueChangedStreamCallback<String> onTextChanged = new ValueChangedStreamCallback<String>();
  final List<ListTile> searchResults = <ListTile>[];
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
        searchResults.clear();
      });
    })
        .flatMapLatest((String value) => fetchAutoComplete(value))
        .listen((List latestResult) {
      debugPrint(latestResult.toString());
      // If a result has been returned, disable the loading and error states and save the latest result
      setState(() {
        isLoading = false;
        hasError = false;
        if(latestResult.isNotEmpty) {
          searchResults.addAll(
              latestResult.map((result) =>
                new ListTile(
                    title: new Text(result["label"].replaceAll(new RegExp(r"<(?:.|\n)*?>"), "")),
                    leading: new Icon(Icons.add),
                )
              )
          );
        }
      });
    }, onError: (dynamic e) {
      debugPrint("ERROR: ${e.toString()}");
      setState(() {
        isLoading = false;
        hasError = true;
        searchResults.clear();
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
          ),
          body: new Column(
              children: <Widget>[
                new Flexible(
                    child: new ListView.builder(
                      padding: new EdgeInsets.all(8.0),
                      reverse: false,
                      itemBuilder: (_, index) => searchResults[index],
                      itemCount: searchResults.length,
                    )
                ),
                new Divider(height: 1.0),
                new Container(
                  decoration: new BoxDecoration(
                      color: Theme.of(context).cardColor),
                  child: buildSearch(),
                ),
              ]
          ),
        )
    );
  }

  Widget buildSearch() {
    return new Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: new Row(
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
    );
  }
}
