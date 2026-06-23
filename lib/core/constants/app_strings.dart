class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'Eco';
  static const String appTagline = 'Jaga Lingkungan, Mulai dari Scan';

  // Auth
  static const String signInWithGoogle = 'Masuk dengan Google';
  static const String signOut = 'Keluar';
  static const String loginTitle = 'Selamat Datang';
  static const String loginSubtitle = 'Masuk untuk mulai menjaga lingkungan';

  // Navigation
  static const String dashboard = 'Dashboard';
  static const String camera = 'Kamera';
  static const String history = 'Riwayat';
  static const String profile = 'Profil';

  // Dashboard
  static const String welcomeBack = 'Selamat datang,';
  static const String weather = 'Cuaca';
  static const String airQuality = 'Kualitas Udara';
  static const String scanStats = 'Statistik Scan';
  static const String dailyTip = 'Tips Harian';
  static const String environmentNews = 'Berita Lingkungan';
  static const String nearbyTps = 'TPS Terdekat';
  static const String totalScans = 'Total Scan';
  static const String memberSince = 'Anggota sejak';
  static const String humidity = 'Kelembapan';
  static const String temperature = 'Suhu';
  static const String wind = 'Angin';

  // AQI Levels
  static const String aqiGood = 'Baik';
  static const String aqiFair = 'Sedang';
  static const String aqiModerate = 'Tidak Sehat (Sensitif)';
  static const String aqiPoor = 'Tidak Sehat';
  static const String aqiVeryPoor = 'Sangat Tidak Sehat';

  // Camera
  static const String takePhoto = 'Ambil Foto';
  static const String pickFromGallery = 'Pilih dari Galeri';
  static const String openChatbot = 'Buka Chatbot';
  static const String cameraHint = 'Arahkan kamera ke lingkungan sekitar';

  // Scan Result
  static const String analyzing = 'Menganalisis gambar...';
  static const String environmentCondition = 'Kondisi Lingkungan';
  static const String impactPrediction = 'Prediksi Dampak';
  static const String suggestions = 'Saran Penanganan';
  static const String contactAgencies = 'Hubungi Instansi';
  static const String save = 'Simpan';
  static const String share = 'Bagikan';
  static const String scanResult = 'Hasil Analisis';

  // Chatbot
  static const String chatbotTitle = 'Eco Assistant';
  static const String chatbotWelcome =
      'Halo! Saya Eco Assistant. Tanya apa saja tentang lingkungan 🌿';
  static const String typeMessage = 'Ketik pesan...';
  static const String send = 'Kirim';

  // History
  static const String scanHistory = 'Scan';
  static const String chatHistory = 'Chat';
  static const String noScanHistory = 'Belum ada riwayat scan';
  static const String noChatHistory = 'Belum ada riwayat chat';
  static const String deleteConfirm = 'Hapus item ini?';

  // Profile
  static const String editProfile = 'Edit Profil';
  static const String logoutConfirm = 'Yakin ingin keluar?';
  static const String cancel = 'Batal';
  static const String confirm = 'Konfirmasi';
  static const String yes = 'Ya';
  static const String no = 'Tidak';

  // Errors
  static const String errorGeneral = 'Terjadi kesalahan. Silakan coba lagi.';
  static const String errorNetwork = 'Tidak ada koneksi internet.';
  static const String errorLocation = 'Tidak dapat mengakses lokasi.';
  static const String errorCamera = 'Tidak dapat mengakses kamera.';
  static const String errorLogin = 'Gagal masuk. Silakan coba lagi.';
  static const String retry = 'Coba Lagi';

  // AQI level label
  static String getAqiLabel(int aqi) {
    switch (aqi) {
      case 1:
        return aqiGood;
      case 2:
        return aqiFair;
      case 3:
        return aqiModerate;
      case 4:
        return aqiPoor;
      case 5:
        return aqiVeryPoor;
      default:
        return aqiGood;
    }
  }
}
