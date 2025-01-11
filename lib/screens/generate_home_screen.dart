import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:revolutionary_stuff/utils/app_router.dart';
import 'package:revolutionary_stuff/utils/route/app_path.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ri.dart';

class GenerateHomeScreen extends StatelessWidget {
  const GenerateHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff3D3D3D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: Padding(
          padding: EdgeInsets.only(left: 46),
          child: Text(
            "Generate QR",
            style: TextStyle(
              color: Color(0xffD9D9D9),
              fontSize: 27,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              AppGoRouter.router.push(AppPath.settings);
            },
            child: Container(
              margin: EdgeInsets.only(right: 31),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xff333333),
              ),
              child: Iconify(
                Ri.menu_3_line,
                size: 30,
                color: Color(0xffFDB623),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 90,
        ),
        child: SizedBox(
          child: GridView.builder(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemCount: 12,
              itemBuilder: (_, index) {
                return FlutterLogo();
                // return Stack(
                //   children: [
                //     ClipRRect(
                //       borderRadius: BorderRadius.circular(15),
                //       child: Container(
                //           color: Color(0xff333333), child: FlutterLogo()),
                //     ),
                //   ],
                // );
                // return Container(
                //   margin: const EdgeInsets.all(43),
                //   padding: const EdgeInsets.all(42),
                //   color: Color(0xff333333),
                //   child: Text("Text", style: TextStyle(color: Colors.black)),
                // );
              }),
        ),
      ),
    );
  }
}
