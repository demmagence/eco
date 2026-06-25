import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:eco/app.dart';
import 'package:eco/data/services/api_service.dart';
import 'package:eco/features/auth/auth_viewmodel.dart';
import 'package:eco/features/dashboard/dashboard_viewmodel.dart';
import 'package:eco/features/camera/camera_viewmodel.dart';
import 'package:eco/features/history/history_viewmodel.dart';
import 'package:eco/features/profile/profile_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Indonesian locale data so DateFormat('...', 'id_ID') works
  await initializeDateFormatting('id_ID', null);

  // Initialize ApiService (loads JWT token from SharedPreferences)
  await ApiService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => CameraViewModel()),
        ChangeNotifierProvider(create: (_) => HistoryViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ],
      child: const EcoApp(),
    ),
  );
}
