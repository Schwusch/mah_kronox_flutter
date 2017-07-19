import 'Booking.dart';

class Day {
  List<Booking> bookings;
  String date;

  Day({this.bookings, this.date});

  Map<String, dynamic> serialize() {
    return {
      "bookings": bookings.map((booking) => booking.serialize()).toList(growable: false),
      "date": date
    };
  }

  static Day deserialize(Map<String, dynamic> day) {
    return new Day(
      bookings: day["bookings"].map((booking) => Booking.deserialize(booking)),
      date: day["date"]
    );
  }
}