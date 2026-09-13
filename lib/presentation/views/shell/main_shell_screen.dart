import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/main_shell_viewmodel.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/app_top_bar.dart';
import '../contacts/contacts_list_screen.dart';
import '../home/home_dashboard_screen.dart';
import '../placeholder/history_placeholder_screen.dart';
import '../placeholder/settings_placeholder_screen.dart';

/// The authenticated app shell: persistent top bar, the four bottom-nav
/// tabs, and the bottom navigation bar itself.
///
/// Each tab keeps its own ViewModel/state alive via [IndexedStack] so
/// switching tabs doesn't reset scroll position or in-flight data —
/// important once Module 3/4 add live session timers here.
class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MainShellViewModel(),
      child: const _MainShellView(),
    );
  }
}

class _MainShellView extends StatelessWidget {
  const _MainShellView();

  static const _tabs = [
    HomeDashboardScreen(),
    ContactsListScreen(),
    HistoryPlaceholderScreen(),
    SettingsPlaceholderScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MainShellViewModel>();

    return Scaffold(
      appBar: AppTopBar(
        onSettingsTap: () => vm.selectTab(3),
      ),
      body: IndexedStack(
        index: vm.currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: vm.currentIndex,
        onTap: vm.selectTab,
      ),
    );
  }
}
