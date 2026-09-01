import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/canvas/canvas_screen.dart';
import '../features/catalog/brand_catalog_screen.dart';
import '../features/match/color_match_screen.dart';
import '../features/match/photo_eyedropper_screen.dart';
import '../features/swatch/swatch_capture_screen.dart';
import '../features/glaze/glaze_screen.dart';
import '../features/light_booth/light_booth_screen.dart';
import '../features/inventory/inventory_screen.dart';
import '../features/learn/learn_screen.dart';
import '../features/mix/mix_screen.dart';
import '../features/preview/preview_screen.dart';
import '../features/recipes/recipes_screen.dart';
import '../features/settings/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/mix',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/mix', builder: (_, __) => const MixScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/canvas', builder: (_, __) => const CanvasScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/recipes', builder: (_, __) => const RecipesScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/learn', builder: (_, __) => const LearnScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inventory',
                builder: (_, __) => const InventoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (_, __) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/preview',
        builder: (_, __) => const PreviewScreen(),
      ),
      GoRoute(
        path: '/glaze',
        builder: (_, __) => const GlazeScreen(),
      ),
      GoRoute(
        path: '/catalog',
        builder: (_, __) => const BrandCatalogScreen(),
      ),
      GoRoute(
        path: '/light-booth',
        builder: (_, __) => const LightBoothScreen(),
      ),
      GoRoute(
        path: '/match',
        builder: (_, __) => const ColorMatchScreen(),
        routes: [
          GoRoute(
            path: 'eyedropper',
            builder: (_, __) => const PhotoEyedropperScreen(),
          ),
          GoRoute(
            path: 'swatch',
            builder: (_, __) => const SwatchCaptureScreen(),
          ),
        ],
      ),
    ],
  );
});

class _AppShell extends StatelessWidget {
  const _AppShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.palette_outlined),
            selectedIcon: Icon(Icons.palette),
            label: 'Mix',
          ),
          NavigationDestination(
            icon: Icon(Icons.brush_outlined),
            selectedIcon: Icon(Icons.brush),
            label: 'Canvas',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Recipes',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Learn',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Stock',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
