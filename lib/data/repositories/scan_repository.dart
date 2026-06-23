import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eco/data/models/scan_result_model.dart';
import 'package:eco/data/services/supabase_service.dart';
import 'package:uuid/uuid.dart';

class ScanRepository {
  final _uuid = const Uuid();

  /// Upload image to Supabase Storage and return the public URL
  Future<String> uploadImage(Uint8List imageBytes) async {
    final fileName = '${SupabaseService.currentUserId}/${_uuid.v4()}.jpg';

    await SupabaseService.scanImagesBucket.uploadBinary(
      fileName,
      imageBytes,
      fileOptions: const FileOptions(
        contentType: 'image/jpeg',
        upsert: true,
      ),
    );

    final publicUrl =
        SupabaseService.scanImagesBucket.getPublicUrl(fileName);
    return publicUrl;
  }

  /// Save scan result to database
  Future<ScanResultModel> saveScanResult(ScanResultModel result) async {
    final response = await SupabaseService.scanResults
        .insert(result.toInsertJson())
        .select()
        .single();

    return ScanResultModel.fromJson(response);
  }

  /// Get all scan results for current user
  Future<List<ScanResultModel>> getScanHistory() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return [];

    final response = await SupabaseService.scanResults
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ScanResultModel.fromJson(json))
        .toList();
  }

  /// Get scan result by ID
  Future<ScanResultModel?> getScanById(String id) async {
    final response = await SupabaseService.scanResults
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response != null) {
      return ScanResultModel.fromJson(response);
    }
    return null;
  }

  /// Delete scan result
  Future<void> deleteScan(String id) async {
    await SupabaseService.scanResults.delete().eq('id', id);
  }

  /// Get total scan count for current user
  Future<int> getScanCount() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return 0;

    final response = await SupabaseService.scanResults
        .select('id')
        .eq('user_id', userId);

    return (response as List).length;
  }
}
