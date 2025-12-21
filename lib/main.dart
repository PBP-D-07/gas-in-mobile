import 'package:flutter/material.dart';
import 'package:gas_in/screens/pop_up_logo.dart';
import 'package:gas_in/theme/app_theme.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        title: 'gas.in',
        theme: AppTheme.getThemeData().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
          ).copyWith(secondary: Colors.deepPurpleAccent[400]),
        ),
        home: SplashScreen(),
      ),
    );
  }
}
