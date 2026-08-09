import 'package:delivo/app/router/app_routes.dart';
import 'package:delivo/features/deletion_review/presentation/pages/marked_for_deletion_page.dart';
import 'package:delivo/features/favorites/presentation/pages/favorites_page.dart';
import 'package:delivo/features/gallery_access/presentation/gallery_preview_page.dart';
import 'package:delivo/features/home/presentation/pages/home_page.dart';
import 'package:delivo/features/onboarding/presentation/gallery_permission_page.dart';
import 'package:delivo/features/photo_folders/presentation/pages/photo_folder_details_page.dart';
import 'package:delivo/features/photo_folders/presentation/pages/photo_folders_page.dart';
import 'package:delivo/features/triage/presentation/pages/triage_page.dart';
import 'package:flutter/material.dart';

abstract final class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(
    RouteSettings settings,
  ) {
    return switch (settings.name) {
      AppRoutes.home => MaterialPageRoute<void>(
          builder: (_) => const HomePage(),
          settings: settings,
        ),
      AppRoutes.galleryPermission =>
        MaterialPageRoute<void>(
          builder: (_) =>
              const GalleryPermissionPage(),
          settings: settings,
        ),
      AppRoutes.galleryPreview =>
        MaterialPageRoute<void>(
          builder: (_) =>
              const GalleryPreviewPage(),
          settings: settings,
        ),
      AppRoutes.triage =>
        MaterialPageRoute<void>(
          builder: (_) => const TriagePage(),
          settings: settings,
        ),
      AppRoutes.favorites =>
        MaterialPageRoute<void>(
          builder: (_) => const FavoritesPage(),
          settings: settings,
        ),
      AppRoutes.markedForDeletion =>
        MaterialPageRoute<void>(
          builder: (_) =>
              const MarkedForDeletionPage(),
          settings: settings,
        ),
      AppRoutes.photoFolders =>
        MaterialPageRoute<void>(
          builder: (_) =>
              const PhotoFoldersPage(),
          settings: settings,
        ),
      AppRoutes.photoFolderDetails =>
        MaterialPageRoute<void>(
          builder: (_) => PhotoFolderDetailsPage(
            folderId: settings.arguments! as String,
          ),
          settings: settings,
        ),
      _ => MaterialPageRoute<void>(
          builder: (_) => const HomePage(),
          settings: const RouteSettings(
            name: AppRoutes.home,
          ),
        ),
    };
  }
}
