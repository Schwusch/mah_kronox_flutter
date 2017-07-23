
class ScheduleMeta {
  final String name;
  final String type;
  final String description;

  ScheduleMeta({this.name, this.type, this.description});

  Map<String, dynamic> serialize() {
    return {
      "name": name,
      "type": type,
      "description": description
    };
  }

  static ScheduleMeta deserialize(Map<String, dynamic> meta) {
    return new ScheduleMeta(
      name: meta["name"],
      type: meta["type"],
      description: meta["description"]
    );
  }
}