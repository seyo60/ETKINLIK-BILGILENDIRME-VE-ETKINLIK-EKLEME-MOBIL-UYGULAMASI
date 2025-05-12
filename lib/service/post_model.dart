class PostModel {
  final String image, title, statement, time, type;

  PostModel(
      {required this.image,
      required this.title,
      required this.statement,
      required this.time,
      required this.type});

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
        image: json['image'],
        title: json['image'],
        statement: json['image'],
        time: json['image'],
        type: json['type']);
  }
}
