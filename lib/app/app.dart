import 'package:delivo/app/router/app_router.dart';
import 'package:delivo/app/router/app_routes.dart';
import 'package:delivo/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class DelivoApp extends StatelessWidget {
  const DelivoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delivo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
