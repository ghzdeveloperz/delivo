import 'package:delivo/app/router/app_routes.dart';
import 'package:delivo/features/gallery_access/presentation/gallery_preview_page.dart';
import 'package:delivo/features/home/presentation/pages/home_page.dart';
import 'package:delivo/features/onboarding/presentation/gallery_permission_page.dart';
import 'package:flutter/material.dart';

abstract final class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      AppRoutes.home => MaterialPageRoute<void>(
        builder: (_) => const HomePage(),
        settings: settings,
      ),
      AppRoutes.galleryPermission => MaterialPageRoute<void>(
        builder: (_) => const GalleryPermissionPage(),
        settings: settings,
      ),
      AppRoutes.galleryPreview => MaterialPageRoute<void>(
        builder: (_) => const GalleryPreviewPage(),
        settings: settings,
      ),
      _ => MaterialPageRoute<void>(
        builder: (_) => const HomePage(),
        settings: const RouteSettings(name: AppRoutes.home),
      ),
    };
  }
}
