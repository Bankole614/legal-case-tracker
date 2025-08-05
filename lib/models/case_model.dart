class LegalCase {
  final String id;
  final String title;
  final String description;
  final String caseType;
  final DateTime createdAt;
  final DateTime? nextCourtDate;

  LegalCase({
    required this.id,
    required this.title,
    required this.description,
    required this.caseType,
    required this.createdAt,
    this.nextCourtDate,
  });

  factory LegalCase.fromJson(Map<String, dynamic> json) {
    return LegalCase(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      caseType: json['caseType'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      nextCourtDate: json['nextCourtDate'] != null
          ? DateTime.parse(json['nextCourtDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'caseType': caseType,
      'createdAt': createdAt.toIso8601String(),
      'nextCourtDate': nextCourtDate?.toIso8601String(),
    };
  }
}