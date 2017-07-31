import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import "package:dslink_schedule/ical.dart";
import 'Booking.dart';
import 'Week.dart';
import 'Day.dart';
import 'weekOfYear.dart';
import 'ScheduleMeta.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';
import '../redux/store.dart';
import '../redux/actions.dart';

Future<Map<String, List<Week>>> fetchAllSchedules(
    List<ScheduleMeta> programs) async {
  var allBookings = await fetchAllBookings(programs);
  return buildWeeksStructureMap(allBookings);
}

Future<Map<ScheduleMeta, List<Booking>>> fetchAllBookings(
    List<ScheduleMeta> programs) async {
  List<Future<Tuple2<ScheduleMeta, List<Booking>>>> futures = [];

  for (ScheduleMeta program in programs) {
    futures.add(fetchBookings(program));
  }

  List<Tuple2<ScheduleMeta, List<Booking>>> tuples = await Future.wait(futures);
  Map<ScheduleMeta, List<Booking>> bookingMap = new Map();

  for (Tuple2<ScheduleMeta, List<Booking>> tuple in tuples) {
    bookingMap[tuple.item1] = tuple.item2;
  }

  return bookingMap;
}

Future<Tuple2<ScheduleMeta, List<Booking>>> fetchBookings(
    ScheduleMeta program) async {
  var httpClient = createHttpClient();
  String ical = await httpClient.read(
      "https://kronox.mah.se/setup/jsp/SchemaICAL.ics?startDatum=idag&intervallTyp=m&intervallAntal=6&sokMedAND=false&sprak=SV&resurser=${program.type[0]}.${program.name}");

  List tokens = tokenizeCalendar(ical);
  CalendarObject root = parseCalendarObjects(tokens);
  var vevents = root.properties["VEVENT"];

  if (vevents == null) {
    vevents = [];
  }

  var bookings = <Booking>[];
  for (CalendarObject x in vevents) {
    Booking e = new Booking();
    String summary = x.properties["SUMMARY"].toString();

    String course = "";
    List<String> signatures = [];
    String moment = "";
    RegExp exp = new RegExp(r".*?\:\s.*?(?=Sign:|Moment:|Program:)|.*");
    Iterable<Match> matches = exp.allMatches(summary);

    for (Match m in matches) {
      String match = m.group(0);
      if (match.contains("Kurs.grp: ")) {
        course = match.replaceAll("Kurs.grp: ", "");
      } else if (match.contains("Sign: ")) {
        signatures = match.replaceAll("Sign: ", "").trim().split(" ");
      } else if (match.contains("Moment: ")) {
        moment = match.replaceAll("Moment: ", "");
      }
    }

    DateTime start = x.properties["DTSTART"];
    DateTime end = x.properties["DTEND"];

    e.location = x.properties["LOCATION"];
    e.start = start.toLocal();
    e.end = end.toLocal();
    e.uuid = x.properties["UID"];
    e.moment = moment;
    e.signatures = signatures;
    e.course = course;

    bookings.add(e);
  }

  return new Tuple2(program, bookings);
}

getAllSignaturesFromBookings(List<Booking> bookings) async {
  Set<String> signatures = new Set<String>();

  for (Booking booking in bookings) {
    for (String signature in booking.signatures) {
      signatures.add(signature);
    }
  }

  List<Future<String>> futures = [];

  for (String signature in signatures) {
    futures.add(getSignature(signature));
  }

  List<String> signatureTuples = await Future.wait(futures);
  Map<String, String> signatureMap = new Map();

  for (String str in signatureTuples) {
    List<String> splitted = str.split(", ");
    signatureMap[splitted[0]] = splitted[1];
  }

  scheduleStore.dispatch(new SetSignatureMap(signatures: signatureMap));
}

Future<String> getSignature(String signature) async {
  var http = createHttpClient();
  String response = await http.read(
      "https://kronox.mah.se/ajax/ajax_autocompleteResurser.jsp?typ=signatur&endastForkortningar=true&term=${signature}");
  List decoded = JSON.decode(response);
  String html = decoded[0]["label"];

  String name = html.replaceAll(new RegExp(r"<(?:.|\n)*?>"), "");
  return name;
}

Map<String, List<Week>> buildWeeksStructureMap(
    Map<ScheduleMeta, List<Booking>> bookingsMap) {
  Map<String, List<Week>> weekMap = new Map();
  List<Booking> allBookings = [];

  bookingsMap.forEach((key, value) {
    allBookings.addAll(value);
    weekMap[key.name] = buildWeeksStructure(value);
  });

  getAllSignaturesFromBookings(allBookings);

  weekMap["all"] = buildWeeksStructure(allBookings);

  return weekMap;
}

List<Week> buildWeeksStructure(List<Booking> bookings) {
  List<Week> weeks = <Week>[];
  //DateFormat timeFormatter = new DateFormat("HH:mm", "sv_SE");
  DateFormat dateFormatter = new DateFormat("d MMM ''yy", "sv");
  DateFormat weekdayFormatter = new DateFormat("EEEE", "sv");

  if (bookings.isNotEmpty) {
    // Sort bookings by DateTime
    bookings.sort((a, b) => a.start.compareTo(b.start));

    Booking lastBooking = bookings.first;

    Day day = new Day(
        bookings: <Booking>[lastBooking],
        date: dateFormatter.format(lastBooking.start),
        weekday: weekdayFormatter.format(lastBooking.start));

    Week week =
        new Week(days: <Day>[day], number: weekOfYear(lastBooking.start));

    weeks.add(week);

    for (Booking booking in bookings) {
      if (weekOfYear(booking.start) != week.number) {
        day = new Day(
            bookings: <Booking>[booking],
            date: dateFormatter.format(booking.start),
            weekday: weekdayFormatter.format(booking.start));

        week = new Week(days: <Day>[day], number: weekOfYear(booking.start));

        weeks.add(week);
      } else if (lastBooking.start.day != booking.start.day ||
          lastBooking.start.month != booking.start.month) {
        day = new Day(
            bookings: <Booking>[booking],
            date: dateFormatter.format(booking.start),
            weekday: weekdayFormatter.format(booking.start));

        week.days.add(day);
      } else if (lastBooking.uuid != booking.uuid) {
        day.bookings.add(booking);
      }

      lastBooking = booking;
    }
  }
  return weeks;
}
