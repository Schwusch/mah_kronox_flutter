import 'Booking.dart';

class Day {
  List<Booking> bookings;
  String date;
  String weekday;

  Day({this.bookings, this.date, this.weekday});

  Map<String, dynamic> serialize() {
    return {
      "bookings": bookings
          .map((booking) => booking.serialize())
          .toList(growable: false),
      "date": date,
      "weekday": weekday
    };
  }

  static Day deserialize(Map<String, dynamic> day) {
    return new Day(
        bookings: day["bookings"]
            .map((booking) => Booking.deserialize(booking))
            .toList(),
        date: day["date"],
        weekday: day["weekday"]);
  }
}
