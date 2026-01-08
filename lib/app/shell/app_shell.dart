import 'package:flutter/material.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/wishlist/presentation/wishlist.dart';
import '../../features/blog/presentation/blog.dart';
import '../../features/account/presentation/account.dart';
import '../widgets/app_bottom_nav_bar.dart';

/// App-level shell that owns the bottom navigation.
///
/// Only tab screens (e.g. Home/Search) live under this shell.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          SearchScreen(),
          WishlistScreen(),
          BlogScreen(),
          AccountScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
