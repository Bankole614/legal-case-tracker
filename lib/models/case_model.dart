// lib/models/case_model.dart
import 'package:flutter/foundation.dart';

class CaseModel {
  final String id;
  final String title;
  final String? description;
  final String? caseType;
  final String? status;
  final String? ownerId;     // client who owns the case
  final String? assignedTo;  // lawyer id
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? nextCourtDate;
  final String? courtLocation;
  final Map<String, dynamic>? meta; // any extra fields (attachments, tags...)

  CaseModel({
    required this.id,
    required this.title,
    this.description,
    this.caseType,
    this.status,
    this.ownerId,
    this.assignedTo,
    DateTime? createdAt,
    this.updatedAt,
    this.nextCourtDate,
    this.courtLocation,
    this.meta,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Tolerant factory to support API envelopes and various key names.
  factory CaseModel.fromJson(Map<String, dynamic> raw) {
    // Normalize envelope { data: { ... } }
    final Map<String, dynamic> json;
    if (raw['data'] is Map<String, dynamic>) {
      json = Map<String, dynamic>.from(raw['data'] as Map);
    } else {
      json = Map<String, dynamic>.from(raw);
    }

    // parse dates tolerantly (ISO string or epoch seconds/ms)
    DateTime? _parseDate(dynamic v) {
      if (v == null) return null;
      try {
        if (v is DateTime) return v;
        if (v is int) {
          // guess ms vs s
          if (v > 9999999999) return DateTime.fromMillisecondsSinceEpoch(v);
          return DateTime.fromMillisecondsSinceEpoch(v * 1000);
        }
        if (v is String) {
          final s = v.trim();
          if (s.isEmpty) return null;
          return DateTime.parse(s);
        }
      } catch (_) {
        return null;
      }
      return null;
    }

    final created = _parseDate(json['created_at'] ?? json['createdAt'] ?? json['created']);
    final updated = _parseDate(json['updated_at'] ?? json['updatedAt'] ?? json['updated']);

    // Next court date might come as 'next_court_date', 'court_date', 'hearing_date'
    final nextDate = _parseDate(json['next_court_date'] ?? json['court_date'] ?? json['hearing_date'] ?? json['nextDate']);

    return CaseModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? 'Untitled Case').toString(),
      description: json['description']?.toString(),
      caseType: json['case_type']?.toString() ?? json['type']?.toString(),
      status: json['status']?.toString(),
      ownerId: json['owner_id']?.toString() ?? json['client_id']?.toString(),
      assignedTo: json['assigned_to']?.toString() ?? json['lawyer_id']?.toString(),
      createdAt: created ?? DateTime.now(),
      updatedAt: updated,
      nextCourtDate: nextDate,
      courtLocation: json['court_location']?.toString(),
      meta: json['meta'] is Map ? Map<String, dynamic>.from(json['meta'] as Map) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      if (caseType != null) 'case_type': caseType,
      if (status != null) 'status': status,
      if (ownerId != null) 'owner_id': ownerId,
      if (assignedTo != null) 'assigned_to': assignedTo,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (nextCourtDate != null) 'next_court_date': nextCourtDate!.toIso8601String(),
      if (courtLocation != null) 'court_location': courtLocation,
      if (meta != null) 'meta': meta,
    };
  }

  CaseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? caseType,
    String? status,
    String? ownerId,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? nextCourtDate,
    String? courtLocation,
    Map<String, dynamic>? meta,
  }) {
    return CaseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      caseType: caseType ?? this.caseType,
      status: status ?? this.status,
      ownerId: ownerId ?? this.ownerId,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nextCourtDate: nextCourtDate ?? this.nextCourtDate,
      courtLocation: courtLocation ?? this.courtLocation,
      meta: meta ?? this.meta,
    );
  }

  /// Short display subtitle for lists
  String get subtitle {
    if (description != null && description!.isNotEmpty) return description!;
    if (caseType != null && caseType!.isNotEmpty) return caseType!;
    return status ?? '';
  }

  @override
  String toString() => 'CaseModel(id: $id, title: $title)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CaseModel &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              title == other.title;

  @override
  int get hashCode => id.hashCode ^ title.hashCode;
}
