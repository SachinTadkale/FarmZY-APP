import 'package:farmzy/core/constants/route_names.dart';
import 'package:farmzy/shared/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = location.startsWith(RouteNames.orders)
        ? 2
        : switch (location) {
            RouteNames.marketplace => 1,
            RouteNames.profile => 3,
            _ => 0,
          };

    return SafeArea(
      child: Scaffold(
        backgroundColor: colors.surface,

        /// AppBar with Drawer Button
        appBar: AppBar(
          backgroundColor: colors.surface,
          elevation: 0,
          centerTitle: true,
          title: const Text("FarmZY"),
          iconTheme: IconThemeData(color: colors.onSurface),
        ),

        /// Drawer
        drawer: AppDrawer(),

        /// Page Content
        body: widget.child,

        /// Bottom Navigation
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(
              top: BorderSide(
                color: colors.outline.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: colors.surface,
            elevation: 0,

            selectedItemColor: colors.primary,
            unselectedItemColor: colors.onSurface.withValues(alpha: 0.6),

            onTap: (index) {
              switch (index) {
                case 0:
                  context.go(RouteNames.home);
                  break;
                case 1:
                  context.go(RouteNames.marketplace);
                  break;
                case 2:
                  context.go(RouteNames.orders);
                  break;
                case 3:
                  context.go(RouteNames.profile);
                  break;
              }
            },

            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.store_outlined),
                activeIcon: Icon(Icons.store),
                label: "Marketplace",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_outlined),
                activeIcon: Icon(Icons.shopping_cart),
                label: "Orders",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
