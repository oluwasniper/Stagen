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
import '../utils/app_motion.dart';
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
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> syncNow() async {
      if (_isSyncing) return;
      final messenger = ScaffoldMessenger.of(context);
      final l10n = AppLocalizations.of(context);
      setState(() => _isSyncing = true);
      try {
        await Future.wait([
          ref.read(scannedHistoryProvider.notifier).fetchRecords(),
          ref.read(generatedHistoryProvider.notifier).fetchRecords(),
        ]);
        if (mounted) {
          messenger.showSnackBar(SnackBar(
            content: Text(l10n.syncCompleted),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xff333333),
          ));
        }
      } finally {
        if (mounted) setState(() => _isSyncing = false);
      }
    }

    return BackgroundScreenWidget(
      screenTitle: AppLocalizations.of(context).history,
      actionButton: () => AppGoRouter.router.push(AppPath.settings),
      body: Column(
        children: [
          // Sync row
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

          // Tab bar
          Container(
            height: 52,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xff333333).withValues(alpha: 0.84),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              enableFeedback: true,
              padding: const EdgeInsets.all(5),
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xffFDB623),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xffFDB623).withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: const Color(0xff1A1A1A),
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: AppLocalizations.of(context).scan),
                Tab(text: AppLocalizations.of(context).create),
              ],
            ),
          ),

          const SizedBox(height: 4),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _HistoryListView(provider: scannedHistoryProvider),
                _HistoryListView(provider: generatedHistoryProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// List view
// ---------------------------------------------------------------------------

class _HistoryListView extends ConsumerWidget {
  final StateNotifierProvider<QRRecordListNotifier, AsyncValue<List<QRRecord>>>
      provider;

  const _HistoryListView({required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(provider);

    return historyAsync.when(
      loading: () => const _SkeletonList(),
      error: (error, _) => _ErrorView(
        onRetry: () => ref.read(provider.notifier).fetchRecords(),
      ),
      data: (records) {
        if (records.isEmpty) {
          return _EmptyView(
            onRefresh: () {
              ref
                  .read(telemetryServiceProvider)
                  .track(TelemetryEvents.historyRefreshed);
              return ref.read(provider.notifier).fetchRecords();
            },
          );
        }

        return RefreshIndicator(
          color: const Color(0xffFDB623),
          backgroundColor: const Color(0xff333333),
          onRefresh: () {
            ref
                .read(telemetryServiceProvider)
                .track(TelemetryEvents.historyRefreshed);
            return ref.read(provider.notifier).fetchRecords();
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return _HistoryTile(
                record: record,
                index: index,
                onDelete: record.id != null
                    ? () async {
                        AppHaptics.medium(context);
                        AppSounds.click();
                        ref
                            .read(telemetryServiceProvider)
                            .track(TelemetryEvents.historyItemDeleted);
                        return ref
                            .read(provider.notifier)
                            .deleteRecord(record.id!);
                      }
                    : null,
                onTap: () {
                  AppHaptics.light(context);
                  AppSounds.click();
                  ref
                      .read(telemetryServiceProvider)
                      .track(TelemetryEvents.historyItemViewed);
                  AppGoRouter.router.push(
                    AppPath.historyOpenFile,
                    extra: record,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Individual tile with swipe-to-delete
// ---------------------------------------------------------------------------

class _HistoryTile extends StatelessWidget {
  final QRRecord record;
  final int index;
  final Future<bool> Function()? onDelete;
  final VoidCallback onTap;

  const _HistoryTile({
    required this.record,
    required this.index,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final motion = AppMotion.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateStr = DateFormat.yMMMd(locale).add_jm().format(record.createdAt);

    final tile = Dismissible(
      key: ValueKey(record.id ?? record.data),
      direction: onDelete != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 26),
      ),
      confirmDismiss: (_) async {
        if (onDelete == null) return false;
        return await onDelete!();
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 68,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xff333333).withValues(alpha: 0.84),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // QR icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Iconify(
                  Ri.qr_code_line,
                  size: 36,
                  color: const Color(0xffFDB623),
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8, right: 14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              record.label?.isNotEmpty == true
                                  ? record.label!
                                  : record.data,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (record.isPendingSync)
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Icon(
                                Icons.cloud_off_rounded,
                                size: 14,
                                color: const Color(0xffFDB623)
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xff888888),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Chevron
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withValues(alpha: 0.25),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return tile
        .animate()
        .fadeIn(
          delay: motion.delay(Duration(milliseconds: 40 * index)),
          duration: motion.duration(const Duration(milliseconds: 320)),
        )
        .slideX(
          begin: motion.reduceMotion ? 0 : 0.08,
          end: 0,
          delay: motion.delay(Duration(milliseconds: 40 * index)),
          duration: motion.duration(const Duration(milliseconds: 320)),
          curve: motion.curve(AppMotion.enter),
        );
  }
}

// ---------------------------------------------------------------------------
// Skeleton loading
// ---------------------------------------------------------------------------

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 20),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) => _SkeletonTile(index: index),
    );
  }
}

class _SkeletonTile extends StatelessWidget {
  final int index;
  const _SkeletonTile({required this.index});

  @override
  Widget build(BuildContext context) {
    final motion = AppMotion.of(context);
    final tile = Container(
      height: 68,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xff333333).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12,
                  width: double.infinity,
                  margin: const EdgeInsets.only(right: 60),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 9,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (motion.reduceMotion) return tile;

    return tile.animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(
          delay: Duration(milliseconds: 80 * index),
          duration: motion.duration(const Duration(milliseconds: 1200)),
          color: Colors.white.withValues(alpha: 0.04),
        );
  }
}

// ---------------------------------------------------------------------------
// Empty & error states
// ---------------------------------------------------------------------------

class _EmptyView extends StatelessWidget {
  final Future<void> Function() onRefresh;
  const _EmptyView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xffFDB623),
      backgroundColor: const Color(0xff333333),
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          const SizedBox(height: 100),
          Column(
            children: [
              Icon(
                Icons.history_rounded,
                size: 52,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).historyEmpty,
                style: const TextStyle(
                  color: Color(0xff888888),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Color(0xffFDB623), size: 48),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).historyLoadFailed,
            style: const TextStyle(color: Color(0xffD9D9D9), fontSize: 16),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffFDB623)),
            child: Text(
              AppLocalizations.of(context).historyRetry,
              style: const TextStyle(color: Color(0xff1A1A1A)),
            ),
          ),
        ],
      ),
    );
  }
}
