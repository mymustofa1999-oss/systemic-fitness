// SF Phase 7e — Clinical Note model (mobile, read-only).
//
// Klien hanya melihat catatan yang sudah di-publish (`is_visible_to_client`
// = true di server). Manual fromJson sesuai konvensi mobile-new (no
// json_serializable / freezed).

class ClinicalNoteModel {
  final String id;
  final String? assessmentId;
  final String clientId;
  final String consultantId;
  final String title;
  final String content;
  final bool isVisibleToClient;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined display fields (di-populate oleh server)
  final String? consultantName;

  ClinicalNoteModel({
    required this.id,
    this.assessmentId,
    required this.clientId,
    required this.consultantId,
    required this.title,
    required this.content,
    required this.isVisibleToClient,
    required this.createdAt,
    required this.updatedAt,
    this.consultantName,
  });

  factory ClinicalNoteModel.fromJson(Map<String, dynamic> json) =>
      ClinicalNoteModel(
        id: json['id'] as String,
        assessmentId: json['assessment_id'] as String?,
        clientId: json['client_id'] as String,
        consultantId: json['consultant_id'] as String,
        title: (json['title'] as String?) ?? '',
        content: (json['content'] as String?) ?? '',
        isVisibleToClient:
            (json['is_visible_to_client'] as bool?) ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        consultantName: json['consultant_name'] as String?,
      );
}
