import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

import 'package:mocu/constant.dart';

class YummyYucky extends StatefulWidget {
  const YummyYucky({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _YummyYuckyState createState() => _YummyYuckyState();
}

class _YummyYuckyState extends State<YummyYucky> {
  late final Map<dynamic, AnimationController> _animationController = {};
  late final Map<dynamic, Animation<double>> _animation = {};

  String _itemImageAssetName(dynamic name) {
    return "assets/images/$name.svg";
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const mainAxisCount = 4;

    const crossAxisCount = 2; // 1 kolom
    final itemWidth = screenWidth / crossAxisCount;
    final itemHeight = screenHeight / mainAxisCount;
    const increaseScreenHeight = 200;
    double sizeItem = (screenHeight - increaseScreenHeight) / mainAxisCount;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true, // Membuat body berada di belakang AppBar
        backgroundColor: softBrown,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title:Text("testing"),
          backgroundColor: Colors.transparent, // Latar belakang transparan
          elevation: 0, // Menghilangkan bayangan
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: GridView.builder(
                  shrinkWrap: true, 
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisExtent: (screenHeight - 200) / mainAxisCount,
                  ),
                  itemCount: crossAxisCount * mainAxisCount,
                  itemBuilder: (context, index) {

                      return DragTarget<int>(
                        builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected) {
                          return Text("test");
                        },
                        onWillAcceptWithDetails: (details) {
                          
                          return true;
                        },
                        onAcceptWithDetails: (details) {
                          
                        },
                      );
                    },
                  ),
                ),
            ],
          )
        ),
      ),
    );
  }
}