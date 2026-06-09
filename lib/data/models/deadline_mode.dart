class Deadline {
  final String id;
  final String title;
  final DateTime date;

  Deadline({
    required this.id,
    required this.title,
    required this.date,
  });


  // convert object to map (for DB)

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
    };
  }


  // to convert map to object

  factory Deadline.fromMap(Map<String, dynamic> map) {
    return Deadline(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
    );
  }




  Deadline copyWith({
    String? id,
    String? title,
    DateTime? date,
  }) {
    return Deadline(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
    );
  }
}