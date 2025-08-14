class CaseModel {
  final String id;
  final String title;
  final String? description;
  final String status;
  CaseModel({required this.id, required this.title, this.description, this.status = 'open'});
  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      id: json['id']?.toString() ?? json['record_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      status: json['status']?.toString() ?? 'open',
    );
  }
  Map<String, dynamic> toJson() {
    return {'title': title, if (description != null) 'description': description, 'status': status};
  }
}
