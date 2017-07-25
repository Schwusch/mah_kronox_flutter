import 'package:flutter/material.dart';
import 'utils/Booking.dart';
import 'package:intl/intl.dart';
import 'redux/store.dart';

class FullScreenBooking extends StatefulWidget {
  final Booking booking;

  FullScreenBooking({this.booking});

  @override
  FullScreenBookingState createState() => new FullScreenBookingState();
}

class FullScreenBookingState extends State<FullScreenBooking> {
  DateFormat timeFormatter = new DateFormat("HH:mm", "sv_SE");

  @override
  Widget build(BuildContext context) {
    String teachers = "";
    Map signaturemap = scheduleStore.state.signatureMap;

    for (String teacher in widget.booking.signatures) {
      teachers += (signaturemap[teacher] ?? teacher) + ", ";
    }

    return new Scaffold(
      appBar: new AppBar(
        title: const Text("Information"),
      ),
      body: new Column(
        children: <Widget>[
          new ListTile(
            title: new Text("Kurs"),
            subtitle: new Text(widget.booking.course),
            isThreeLine: true,
          ),
          new ListTile(
            title: new Text("Moment"),
            subtitle: new Text(widget.booking.moment),
            isThreeLine: true,
          ),
          new ListTile(
            title: new Text("Lärare"),
            subtitle: new Text(teachers),
          ),
          new ListTile(
            title: new Text("Lokal"),
            subtitle: new Text(widget.booking.location),
          ),
          new ListTile(
            title: new Text("Start"),
            leading: new Icon(Icons.schedule),
            trailing: new Text(timeFormatter.format(widget.booking.start)),
          ),
          new ListTile(
              title: new Text("Slut"),
              leading: new Icon(Icons.schedule),
              trailing: new Text(timeFormatter.format(widget.booking.end))
          )
        ],
      ),
    );
  }
}
