
class ScheduleMeta {
  final String givenName;
  final String name;
  final String type;
  final String description;

  ScheduleMeta({this.givenName, this.name, this.type, this.description});

  Map<String, dynamic> serialize() {
    return {
      "givenName": givenName,
      "name": name,
      "type": type,
      "description": description
    };
  }

  static ScheduleMeta deserialize(Map<String, dynamic> meta) {
    return meta != null ? new ScheduleMeta(
      givenName: meta["givenName"],
      name: meta["name"],
      type: meta["type"],
      description: meta["description"]
    ) : new ScheduleMeta();
  }
}