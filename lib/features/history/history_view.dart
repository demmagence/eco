import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/core/constants/app_strings.dart';
import 'package:eco/core/widgets/loading_indicator.dart';
import 'package:eco/features/history/history_viewmodel.dart';
import 'package:eco/features/history/widgets/scan_history_tab.dart';
import 'package:eco/features/history/widgets/chat_history_tab.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryViewModel>().loadHistory();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.onSurfaceVariant,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: AppStrings.scanHistory),
              Tab(text: AppStrings.chatHistory),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: Consumer<HistoryViewModel>(
            builder: (context, historyVM, child) {
              if (historyVM.isLoading) {
                return const LoadingIndicator();
              }

              return TabBarView(
                controller: _tabController,
                children: [
                  ScanHistoryTab(
                    scans: historyVM.scanHistory,
                    onDelete: historyVM.deleteScan,
                    onRefresh: historyVM.refresh,
                  ),
                  ChatHistoryTab(
                    sessions: historyVM.chatSessions,
                    onDelete: historyVM.deleteChatSession,
                    onRefresh: historyVM.refresh,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
