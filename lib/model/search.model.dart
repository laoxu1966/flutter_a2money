class Tag {
  Tag({required this.classification, this.tags, this.isExpanded = false});

  int classification;
  List<String>? tags;
  bool isExpanded;

  factory Tag.fromJson(Map<String, dynamic> parsedJson) {
    return Tag(
      classification: parsedJson['classification'],
      tags: (parsedJson['tags'] ?? '').split(','),
      isExpanded: parsedJson['isExpanded'] ?? false,
    );
  }
}

class Hot {
  Hot({required this.hot, this.weight, this.created});

  String hot;
  int? weight;
  DateTime? created;

  factory Hot.fromJson(Map<String, dynamic> parsedJson) {
    return Hot(
      hot: parsedJson['hot'],
      weight: parsedJson['weight'],
      created: (DateTime.tryParse(parsedJson['created']) ?? DateTime.now()).toLocal(),
    );
  }
}
