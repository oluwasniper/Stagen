import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ri.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/qr_record.dart';
import '../providers/qr_providers.dart';
import '../services/telemetry_service.dart';
import '../utils/app_router.dart';
import '../utils/route/app_path.dart';
import '../widgets/background_screen_widget.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSyncing = false;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> syncNow() async {
      if (_isSyncing) return;
      final messenger = ScaffoldMessenger.of(context);
      final l10n = AppLocalizations.of(context);
      setState(() => _isSyncing = true);
      try {
        await ref.read(scannedHistoryProvider.notifier).fetchRecords();
        await ref.read(generatedHistoryProvider.notifier).fetchRecords();
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(l10n.syncCompleted),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSyncing = false);
        }
      }
    }

    return BackgroundScreenWidget(
      screenTitle: AppLocalizations.of(context).history,
      actionButton: () => AppGoRouter.router.push(AppPath.settings),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _isSyncing ? null : syncNow,
                icon: _isSyncing
                    ? const SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync_rounded),
                label: Text(AppLocalizations.of(context).syncNow),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xffFDB623),
                ),
              ),
            ),
          ),
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xff333333).withValues(alpha: 0.84),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: TabBar(
              enableFeedback: true,
              padding: const EdgeInsets.only(top: 6, bottom: 6),
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                color: const Color(0xffFDB623),
              ),
              labelStyle: const TextStyle(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 19,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
              dividerColor: Colors.transparent,
              tabs: [
                SizedBox(
                  width: (MediaQuery.of(context).size.width * 7 / 4) - 12,
                  child: Tab(
                    text: AppLocalizations.of(context).scan,
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width * 8 / 4),
                  child: Tab(
                    text: AppLocalizations.of(context).create,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Scanned history tab
                _HistoryListView(
                  provider: scannedHistoryProvider,
                ),
                // Generated history tab
                _HistoryListView(
                  provider: generatedHistoryProvider,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryListView extends ConsumerWidget {
  final StateNotifierProvider<QRRecordListNotifier, AsyncValue<List<QRRecord>>>
      provider;

  const _HistoryListView({required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(provider);

    return historyAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xffFDB623)),
      ),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xffFDB623), size: 48),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).historyLoadFailed,
              style: const TextStyle(color: Color(0xffD9D9D9), fontSize: 16),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.read(provider.notifier).fetchRecords(),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFDB623)),
              child: Text(AppLocalizations.of(context).historyRetry,
                  style: const TextStyle(color: Color(0xff333333))),
            ),
          ],
        ),
      ),
      data: (records) {
        if (records.isEmpty) {
          return RefreshIndicator(
            color: const Color(0xffFDB623),
            backgroundColor: const Color(0xff333333),
            onRefresh: () {
              ref.read(telemetryServiceProvider).track(TelemetryEvents.historyRefreshed);
              return ref.read(provider.notifier).fetchRecords();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              children: [
                const SizedBox(height: 200),
                Center(
                  child: Text(
                    AppLocalizations.of(context).historyEmpty,
                    style:
                        const TextStyle(color: Color(0xffA4A4A4), fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: const Color(0xffFDB623),
          backgroundColor: const Color(0xff333333),
          onRefresh: () {
            ref.read(telemetryServiceProvider).track(TelemetryEvents.historyRefreshed);
            return ref.read(provider.notifier).fetchRecords();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              separatorBuilder: (context, index) => const SizedBox(height: 19),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                final dateStr =
                    DateFormat('dd MMM yyyy, h:mm a').format(record.createdAt);

                return GestureDetector(
                  onTap: () {
                    ref.read(telemetryServiceProvider).track(TelemetryEvents.historyItemViewed);
                    AppGoRouter.router.push(
                      AppPath.historyOpenFile,
                      extra: record,
                    );
                  },
                  child: Container(
                    height: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xff333333).withValues(alpha: 0.84),
                      borderRadius: BorderRadius.circular(6.0),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff000000).withValues(alpha: 0.25),
                          spreadRadius: 0,
                          blurRadius: 4,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Iconify(
                            Ri.qr_code_line,
                            size: 50,
                            color: const Color(0xffFDB623),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 7.0, bottom: 7.0, right: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        record.data,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (record.isPendingSync)
                                      Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xffFDB623)
                                              .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                            color: const Color(0xffFDB623),
                                            width: 0.6,
                                          ),
                                        ),
                                        child: Text(
                                          AppLocalizations.of(context)
                                              .pendingSync,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xffFDB623),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    GestureDetector(
                                      onTap: () {
                                        if (record.id != null) {
                                          ref.read(telemetryServiceProvider).track(TelemetryEvents.historyItemDeleted);
                                          ref
                                              .read(provider.notifier)
                                              .deleteRecord(record.id!);
                                        }
                                      },
                                      child: Iconify(
                                        Ri.delete_bin_5_fill,
                                        size: 24,
                                        color: const Color(0xffFDB623),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  dateStr,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xffA4A4A4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: 50 * index),
                      duration: const Duration(milliseconds: 350),
                    )
                    .slideX(
                      begin: 0.1,
                      end: 0,
                      delay: Duration(milliseconds: 50 * index),
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOut,
                    );
              },
            ),
          ),
        );
      },
    );
  }
}
