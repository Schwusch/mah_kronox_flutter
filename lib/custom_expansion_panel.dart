import 'package:flutter/material.dart';

class _SaltedKey<S, V> extends LocalKey {
  const _SaltedKey(this.salt, this.value);

  final S salt;
  final V value;

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType)
      return false;
    final _SaltedKey<S, V> typedOther = other;
    return salt == typedOther.salt
        && value == typedOther.value;
  }

  @override
  int get hashCode => hashValues(runtimeType, salt, value);

  @override
  String toString() {
    final String saltString = S == String ? '<\'$salt\'>' : '<$salt>';
    final String valueString = V == String ? '<\'$value\'>' : '<$value>';
    return '[$saltString $valueString]';
  }
}

class CustomExpansionPanelList extends StatelessWidget{

  const CustomExpansionPanelList({
    Key key,
    this.children: const <ExpansionPanel>[],
    this.expansionCallback,
    this.animationDuration: kThemeAnimationDuration
  }) : assert(children != null),
        assert(animationDuration != null),
        super(key: key);

  /// The children of the expansion panel list. They are laid out in a similar
  /// fashion to [ListBody].
  final List<ExpansionPanel> children;

  /// The callback that gets called whenever one of the expand/collapse buttons
  /// is pressed. The arguments passed to the callback are the index of the
  /// to-be-expanded panel in the list and whether the panel is currently
  /// expanded or not.
  ///
  /// This callback is useful in order to keep track of the expanded/collapsed
  /// panels in a parent widget that may need to react to these changes.
  final ExpansionPanelCallback expansionCallback;

  /// The duration of the expansion animation.
  final Duration animationDuration;

  bool _isChildExpanded(int index) {
    return children[index].isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final List<MergeableMaterialItem> items = <MergeableMaterialItem>[];
    const EdgeInsets kExpandedEdgeInsets = const EdgeInsets.symmetric(
        vertical: 5.0
    );

    for (int i = 0; i < children.length; i += 1) {
      if (_isChildExpanded(i) && i != 0 && !_isChildExpanded(i - 1))
        items.add(new MaterialGap(key: new _SaltedKey<BuildContext, int>(context, i * 2 - 1)));

      final Row header = new Row(
          children: <Widget>[
            new Expanded(
                child: new AnimatedContainer(
                    duration: animationDuration,
                    curve: Curves.fastOutSlowIn,
                    margin: _isChildExpanded(i) ? kExpandedEdgeInsets : EdgeInsets.zero,
                    child: children[i].headerBuilder(
                        context,
                        children[i].isExpanded
                    )
                )
            ),
            new SizedBox(
                height: 50.0,
                width: 50.0,
                child: new FlatButton(
                    child: new Icon(_isChildExpanded(i) ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                    onPressed: () {
                      if (expansionCallback != null) {
                        expansionCallback(i, _isChildExpanded(i));
                      }
                    }
                )
            )
          ]
      );

      items.add(
          new MaterialSlice(
              key: new _SaltedKey<BuildContext, int>(context, i * 2),
              child: new Column(
                  children: <Widget>[
                    header,
                    new AnimatedCrossFade(
                      firstChild: new Container(height: 0.0),
                      secondChild: children[i].body,
                      firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
                      secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
                      sizeCurve: Curves.fastOutSlowIn,
                      crossFadeState: _isChildExpanded(i) ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      duration: animationDuration,
                    )
                  ]
              )
          )
      );

      if (_isChildExpanded(i) && i != children.length - 1)
        items.add(new MaterialGap(key: new _SaltedKey<BuildContext, int>(context, i * 2 + 1)));
    }

    return new MergeableMaterial(
        hasDividers: true,
        children: items
    );
  }
}