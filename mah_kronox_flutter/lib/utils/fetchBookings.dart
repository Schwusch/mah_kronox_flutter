import 'dart:async';
import 'package:flutter/services.dart';
import "package:dslink_schedule/ical.dart";
import 'Booking.dart';

Future<List<Booking>> fetchBookings(String program) async {
  var httpClient = createHttpClient();
  String ical = await httpClient.read("https://kronox.mah.se/setup/jsp/SchemaICAL.ics?startDatum=idag&intervallTyp=m&intervallAntal=6&sokMedAND=false&sprak=SV&resurser=p.${program}");

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

      } else if(match.contains("Sign: ")) {
        signatures = match.replaceAll("Sign: ", "").trim().split(" ");
        
      } else if(match.contains("Moment: ")) {
        moment = match.replaceAll("Moment: ", "");
      }
    }

    e.location = x.properties["LOCATION"];
    e.start = x.properties["DTSTART"];
    e.end = x.properties["DTEND"];
    e.uuid = x.properties["UID"];
    e.moment = moment;
    e.signatures = signatures;
    e.course = course;

    bookings.add(e);
  }

  return bookings;
}