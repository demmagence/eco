import 'dart:convert';
import 'dart:typed_data';
import 'package:eco/data/models/scan_result_model.dart';
import 'package:eco/data/services/api_service.dart';

class ScanRepository {
  /// Upload image bytes to the server, returns a relative URL path.
  Future<String> uploadImage(Uint8List imageBytes) async {
    final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final response = await ApiService.uploadFile(
      '/scans/upload',
      imageBytes,
      'image',
      fileName,
      'image/jpeg',
    );

    final body = await response.stream.toBytes();
    final data = jsonDecode(utf8.decode(body)) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['error'] ?? 'Gagal mengunggah gambar scan.');
    }

    final relativePath = data['image_url'] as String;
    // Return a full accessible URL
    return ApiService.resolveUrl(relativePath);
  }

  /// Save scan result to database
  Future<ScanResultModel> saveScanResult(ScanResultModel result) async {
    final body = {
      'image_url': result.imageUrl,
      'scan_type': result.scanType,
      'environment_condition': result.environmentCondition,
      'impact_prediction': result.impactPrediction,
      'suggestions': result.suggestions,
      'contacts': jsonEncode(result.contacts.map((c) => c.toJson()).toList()),
      'correct_disposal': result.correctDisposal,
      'teacher_material': result.teacherMaterial,
      'trash_classification': result.trashClassification,
      'recycling_info': result.recyclingInfo,
      'raw_ai_response': result.rawAiResponse,
      if (result.latitude != null) 'latitude': result.latitude,
      if (result.longitude != null) 'longitude': result.longitude,
      if (result.locationName != null) 'location_name': result.locationName,
    };

    final response = await ApiService.post('/scans', body);
    final data = ApiService.decodeResponse(response);
    return _fromApiJson(data);
  }

  /// Get all scan results for current user
  Future<List<ScanResultModel>> getScanHistory() async {
    final response = await ApiService.get('/scans');
    final list = jsonDecode(utf8.decode(response.bodyBytes)) as List;
    return list.map((json) => _fromApiJson(json as Map<String, dynamic>)).toList();
  }

  /// Delete scan result
  Future<void> deleteScan(String id) async {
    await ApiService.delete('/scans/$id');
  }

  /// Get total scan count for current user
  Future<int> getScanCount() async {
    final response = await ApiService.get('/scans/count');
    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return (data['count'] as num?)?.toInt() ?? 0;
  }

  /// Convert API JSON (which stores contacts as a JSON string) to ScanResultModel
  static ScanResultModel _fromApiJson(Map<String, dynamic> json) {
    // contacts from MySQL is stored as a JSON string, parse it
    List<ContactInfo> contacts = [];
    final rawContacts = json['contacts'];
    if (rawContacts != null) {
      final decoded = rawContacts is String
          ? jsonDecode(rawContacts)
          : rawContacts;
      if (decoded is List) {
        contacts = decoded
            .map((c) => ContactInfo.fromJson(c as Map<String, dynamic>))
            .toList();
      }
    }

    // Resolve image_url to full URL if it's a relative path
    final imageUrl = json['image_url'] as String? ?? '';
    final resolvedUrl = imageUrl.startsWith('http')
        ? imageUrl
        : ApiService.resolveUrl(imageUrl);

    return ScanResultModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      imageUrl: resolvedUrl,
      scanType: json['scan_type'] as String? ?? 'multiple',
      environmentCondition: json['environment_condition'] as String?,
      impactPrediction: json['impact_prediction'] as String?,
      suggestions: json['suggestions'] as String?,
      contacts: contacts,
      correctDisposal: json['correct_disposal'] as String?,
      teacherMaterial: json['teacher_material'] as String?,
      trashClassification: json['trash_classification'] as String?,
      recyclingInfo: json['recycling_info'] as String?,
      rawAiResponse: json['raw_ai_response'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationName: json['location_name'] as String?,
    );
  }
}
