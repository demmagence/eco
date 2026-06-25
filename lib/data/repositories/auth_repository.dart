import 'package:eco/data/services/api_service.dart';
import 'package:eco/data/models/user_model.dart';

class AuthRepository {
  /// Login dengan username dan password. Menyimpan JWT ke SharedPreferences.
  Future<UserModel> signIn({
    required String username,
    required String password,
  }) async {
    final response = await ApiService.post('/auth/login', {
      'username': username,
      'password': password,
    });

    final data = ApiService.decodeResponse(response);
    final token = data['token'] as String;
    final userData = data['user'] as Map<String, dynamic>;

    await ApiService.saveToken(token);
    await ApiService.saveUser(userData);

    return UserModel.fromJson(userData);
  }

  /// Registrasi user baru dengan username dan password.
  Future<UserModel> signUp({
    required String username,
    required String password,
    required String displayName,
    String? email,
  }) async {
    final response = await ApiService.post('/auth/register', {
      'username': username,
      'password': password,
      'display_name': displayName,
      if (email != null && email.isNotEmpty) 'email': email,
    });

    final data = ApiService.decodeResponse(response);
    final token = data['token'] as String;
    final userData = data['user'] as Map<String, dynamic>;

    await ApiService.saveToken(token);
    await ApiService.saveUser(userData);

    return UserModel.fromJson(userData);
  }

  /// Sign out
  Future<void> signOut() async {
    await ApiService.signOut();
  }

  /// Periksa status autentikasi dari penyimpanan lokal.
  bool get isAuthenticated => ApiService.isAuthenticated;

  /// Dapatkan profil user dari API (data terbaru dari server).
  Future<UserModel?> getUserProfile() async {
    if (!ApiService.isAuthenticated) return null;

    try {
      final response = await ApiService.get('/profile');
      final data = ApiService.decodeResponse(response);
      await ApiService.saveUser(data);
      return UserModel.fromJson(data);
    } catch (_) {
      // Fallback ke data lokal dari SharedPreferences jika offline
      return _localUser;
    }
  }

  /// Dapatkan UserModel dari data lokal (SharedPreferences) sebagai fallback.
  UserModel? get _localUser {
    final id = ApiService.currentUserId;
    if (id == null) return null;

    return UserModel(
      id: id,
      username: ApiService.currentUserUsername ?? '',
      email: ApiService.currentUserEmail ?? '',
      displayName: ApiService.currentUserDisplayName ?? '',
      photoUrl: ApiService.currentUserPhotoUrl,
      createdAt: ApiService.currentUserCreatedAt != null
          ? DateTime.tryParse(ApiService.currentUserCreatedAt!) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Mengembalikan null karena tidak ada stream auth state seperti Supabase.
  /// Pemeriksaan autentikasi dilakukan secara synchronous via isAuthenticated.
  UserModel? get currentUser => _localUser;
}
