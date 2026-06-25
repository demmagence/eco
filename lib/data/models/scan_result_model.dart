import 'dart:convert';

class ContactInfo {
  final String name;
  final String phone;
  final String? description;

  const ContactInfo({
    required this.name,
    required this.phone,
    this.description,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'description': description,
    };
  }
}

class ScanResultModel {
  final String id;
  final String userId;
  final String imageUrl;
  final String scanType; // 'single' or 'multiple'
  final String? environmentCondition;
  final String? impactPrediction;
  final String? suggestions;
  final List<ContactInfo> contacts;
  final String? correctDisposal;
  final String? teacherMaterial;
  final String? trashClassification;
  final String? recyclingInfo;
  final String rawAiResponse;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;
  final String? locationName;

  const ScanResultModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    this.scanType = 'multiple',
    this.environmentCondition,
    this.impactPrediction,
    this.suggestions,
    required this.contacts,
    this.correctDisposal,
    this.teacherMaterial,
    this.trashClassification,
    this.recyclingInfo,
    required this.rawAiResponse,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.locationName,
  });

  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    List<ContactInfo> contactList = [];
    if (json['contacts'] != null) {
      final contactsData = json['contacts'] is String
          ? jsonDecode(json['contacts'] as String)
          : json['contacts'];
      if (contactsData is List) {
        contactList = contactsData
            .map((c) => ContactInfo.fromJson(c as Map<String, dynamic>))
            .toList();
      }
    }

    return ScanResultModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      imageUrl: json['image_url'] as String,
      scanType: json['scan_type'] as String? ?? 'multiple',
      environmentCondition: json['environment_condition'] as String?,
      impactPrediction: json['impact_prediction'] as String?,
      suggestions: json['suggestions'] as String?,
      contacts: contactList,
      correctDisposal: json['correct_disposal'] as String?,
      teacherMaterial: json['teacher_material'] as String?,
      trashClassification: json['trash_classification'] as String?,
      recyclingInfo: json['recycling_info'] as String?,
      rawAiResponse: json['raw_ai_response'] as String? ?? '',
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationName: json['location_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'image_url': imageUrl,
      'scan_type': scanType,
      'environment_condition': environmentCondition,
      'impact_prediction': impactPrediction,
      'suggestions': suggestions,
      'contacts': contacts.map((c) => c.toJson()).toList(),
      'correct_disposal': correctDisposal,
      'teacher_material': teacherMaterial,
      'trash_classification': trashClassification,
      'recycling_info': recyclingInfo,
      'raw_ai_response': rawAiResponse,
      'created_at': createdAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
    };
  }

  /// Create insert map (without id, let DB generate it)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'image_url': imageUrl,
      'scan_type': scanType,
      'environment_condition': environmentCondition,
      'impact_prediction': impactPrediction,
      'suggestions': suggestions,
      'contacts': contacts.map((c) => c.toJson()).toList(),
      'correct_disposal': correctDisposal,
      'teacher_material': teacherMaterial,
      'trash_classification': trashClassification,
      'recycling_info': recyclingInfo,
      'raw_ai_response': rawAiResponse,
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
    };
  }
}
