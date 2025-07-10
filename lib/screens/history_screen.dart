import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ri.dart';
import 'package:intl/intl.dart';

import '../models/history_items.dart';
import '../services/history_service.dart';
import '../utils/app_router.dart';
import '../utils/route/app_path.dart';
import '../widgets/background_screen_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final HistoryService _historyService = HistoryService();
  List<HistoryItem> _historyItems = [];

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _initHistoryService();
    super.initState();
  }

  Future<void> _initHistoryService() async {
    await _historyService.init();
    // Add dummy data if the box is empty
    if (_historyService.getAllItems().isEmpty) {
      await _addDummyData();
    }
    _loadHistoryItems();
  }

  Future<void> _addDummyData() async {
    final now = DateTime.now();
    final dummyItems = [
      HistoryItem(
        type: HistoryItemType.transactionId,
        value: 'TXN-123456789',
        date: now.subtract(const Duration(days: 1)),
      ),
      HistoryItem(
        type: HistoryItemType.transactionAmount,
        value: 'NGN 50,000.00',
        date: now.subtract(const Duration(days: 2)),
      ),
      HistoryItem(
        type: HistoryItemType.transactionStatus,
        value: 'Successful',
        date: now.subtract(const Duration(days: 3)),
      ),
      HistoryItem(
        type: HistoryItemType.qrCode,
        value: 'https://example.com/receipt/123456',
        date: now.subtract(const Duration(days: 4)),
      ),
      HistoryItem(
        type: HistoryItemType.transactionType,
        value: 'Bank Transfer',
        date: now.subtract(const Duration(days: 5)),
      ),
    ];

    for (var item in dummyItems) {
      await _historyService.addItem(item);
    }
  }

  void _loadHistoryItems() {
    setState(() {
      _historyItems = _historyService.getAllItems();
    });
  }

  Future<void> _deleteHistoryItem(int index) async {
    await _historyService.deleteItem(index);
    _loadHistoryItems();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  IconData _getIconForType(HistoryItemType type) {
    switch (type) {
      case HistoryItemType.qrCode:
        return Icons.qr_code;
      case HistoryItemType.transactionId:
        return Icons.receipt_long;
      case HistoryItemType.transactionAmount:
        return Icons.attach_money;
      case HistoryItemType.transactionStatus:
        return Icons.check_circle;
      case HistoryItemType.transactionType:
        return Icons.swap_horiz;
      case HistoryItemType.transactionDate:
        return Icons.calendar_today;
      case HistoryItemType.transactionCategory:
        return Icons.category;
      default:
        return Icons.history;
    }
  }

  Color _getColorForType(HistoryItemType type) {
    switch (type) {
      case HistoryItemType.transactionStatus:
        return Colors.green;
      case HistoryItemType.transactionAmount:
        return Colors.blue;
      case HistoryItemType.transactionType:
        return Colors.orange;
      default:
        return const Color(0xffFDB623);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScreenWidget(
      screenTitle: AppLocalizations.of(context).history,
      actionButton: () => AppGoRouter.router.push(AppPath.settings),
      body: Column(
        children: [
          Container(
            height: 60,
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Color(0xff333333).withOpacity(0.84),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: TabBar(
              enableFeedback: true,
              padding: EdgeInsets.only(top: 6, bottom: 6),
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                color: Color(0xffFDB623),
              ),
              labelStyle: TextStyle(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              unselectedLabelStyle: TextStyle(
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
                _buildHistoryList(),
                _buildHistoryList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: ListView.separated(
        physics: BouncingScrollPhysics(),
        separatorBuilder: (context, index) {
          return SizedBox(height: 19);
        },
        itemCount: _historyItems.length,
        itemBuilder: (context, index) {
          final item = _historyItems[index];
          return GestureDetector(
            onTap: () {
              AppGoRouter.router.push(AppPath.historyOpenFile);
            },
            child: Container(
              height: 80,
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Color(0xff333333).withOpacity(0.84),
                borderRadius: BorderRadius.circular(6.0),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xff000000).withOpacity(0.25),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                      _getIconForType(item.type),
                      size: 40,
                      color: _getColorForType(item.type),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 7.0,
                        bottom: 7.0,
                        right: 10,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.type.toString().split('.').last,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      item.value,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _deleteHistoryItem(index),
                                child: Iconify(
                                  Ri.delete_bin_5_fill,
                                  size: 30,
                                  color: Color(0xffFDB623),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            DateFormat('dd MMM yyyy, h:mm a').format(item.date),
                            style: TextStyle(
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
          );
        },
      ),
    );
  }

  void onQRCodeScanned(String qrData) async {
    await _historyService.addItem(HistoryItem(
      type: HistoryItemType.qrCode,
      value: qrData,
      date: DateTime.now(),
    ));
  }

  void onTransactionComplete(String transactionId, double amount) async {
    await _historyService.addItem(HistoryItem(
      type: HistoryItemType.transactionId,
      value: transactionId,
      date: DateTime.now(),
    ));

    await _historyService.addItem(HistoryItem(
      type: HistoryItemType.transactionAmount,
      value: 'NGN ${amount.toStringAsFixed(2)}',
      date: DateTime.now(),
    ));
  }
}
