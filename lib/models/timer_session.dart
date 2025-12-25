class TimerSession {
  String id;
  String name;
  int durationSeconds;
  DateTime startTime;
  DateTime? endTime;

  TimerSession({
    required this.id,
    required this.name,
    required this.durationSeconds,
    required this.startTime,
    this.endTime,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'durationSeconds': durationSeconds,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
      };

  factory TimerSession.fromJson(Map<String, dynamic> json) => TimerSession(
        id: json['id'],
        name: json['name'],
        durationSeconds: json['durationSeconds'],
        startTime: DateTime.parse(json['startTime']),
        endTime:
            json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      );
}

