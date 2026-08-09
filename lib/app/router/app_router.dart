import 'package:delivo/app/router/app_routes.dart';
import 'package:delivo/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';

abstract final class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      AppRoutes.home => MaterialPageRoute<void>(
        builder: (_) => const HomePage(),
        settings: settings,
      ),
      _ => MaterialPageRoute<void>(
        builder: (_) => const HomePage(),
        settings: const RouteSettings(name: AppRoutes.home),
      ),
    };
  }
}
