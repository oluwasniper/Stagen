import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ri.dart';
import 'package:revolutionary_stuff/utils/app_router.dart';
import 'package:revolutionary_stuff/utils/route/app_path.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:revolutionary_stuff/widgets/background_screen_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    return BackgroundScreenWidget(
      screenTitle: AppLocalizations.of(context)!.history,
      actionButton: () => AppGoRouter.router.push(AppPath.settings),
      body: Column(
        children: [
          // give the tab bar a height [can change hheight to preferred height]
          Container(
            height: 60,
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Color(0xff333333).withOpacity(0.84),
              borderRadius: BorderRadius.circular(
                6.0,
              ),
            ),
            child: TabBar(
              enableFeedback: true,

              padding: EdgeInsets.only(
                top: 6,
                bottom: 6,
              ),
              controller: _tabController,
              // give the indicator a decoration (color and border radius)
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  6.0,
                ),
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
                // first tab [you can add an icon using the icon property]
                SizedBox(
                  width: (MediaQuery.of(context).size.width * 7 / 4) - 12,
                  child: Tab(
                    text: AppLocalizations.of(context)!.scan,
                  ),
                ),

                // second tab [you can add an icon using the icon property]

                SizedBox(
                  // width: (MediaQuery.of(context).size.width * 7 / 4) - 12,
                  width: (MediaQuery.of(context).size.width * 8 / 4),
                  child: Tab(
                    text: AppLocalizations.of(context)!.create,
                  ),
                ),
              ],
            ),
          ),
          // tab bar view here
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // first tab bar view widget
                _scanCreateMock(),

                // second tab bar view widget
                _scanCreateMock(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Padding _scanCreateMock() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: ListView.separated(
          physics: BouncingScrollPhysics(),
          separatorBuilder: (context, index) {
            return SizedBox(
              height: 19,
            );
          },
          itemCount: 15,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // AppGoRouter.router.push("/history/openFile");
                // AppGoRouter.router.push(AppPath.openFile);
                AppGoRouter.router.push(AppPath.historyOpenFile);
              },
              child: Container(
                height: 60,
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Color(0xff333333).withOpacity(0.84),
                  borderRadius: BorderRadius.circular(
                    6.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff000000).withOpacity(0.25),
                      spreadRadius: 0,
                      blurRadius: 4,
                      offset: Offset(0, 4), // changes position of shadow
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
                        color: Color(0xffFDB623),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 7.0, bottom: 7.0, right: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            // add the url and the delete button

                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width *
                                        (2 / 3) -
                                    14,
                                child: Text(
                                  'https://itunes.com',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Iconify(
                                Ri.delete_bin_5_fill,
                                size: 30,
                                color: Color(0xffFDB623),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                '16 Dec 2022, 9:30 pm',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xffA4A4A4),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
