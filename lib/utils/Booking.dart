class Booking {
  DateTime start;
  DateTime end;
  String location;
  String uuid;
  String course;
  String moment;
  List<String> signatures;

  int get hashCode => uuid?.hashCode;
  operator ==(dynamic o) => uuid == o.uuid;

  Map<String, dynamic> serialize() {
    return {
      "start": start.toIso8601String(),
      "end": end.toIso8601String(),
      "location": location,
      "uuid": uuid,
      "course": course,
      "moment": moment,
      "signatures": signatures
    };
  }

  static Booking deserialize(Map<String, dynamic> booking) {
    Booking deserialized = new Booking();

    deserialized.start = DateTime.parse(booking["start"]);
    deserialized.end = DateTime.parse(booking["end"]);
    deserialized.location = booking["location"];
    deserialized.uuid = booking["uuid"];
    deserialized.course = booking["course"];
    deserialized.moment = booking["moment"];
    deserialized.signatures = booking["signatures"];

    return deserialized;
  }
}
