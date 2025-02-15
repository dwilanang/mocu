import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:mocu/constant.dart';
import 'package:mocu/helper/helper.dart';

class MatchingPlay extends StatefulWidget {
  const MatchingPlay({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MatchingPlayState createState() => _MatchingPlayState();
}

class _MatchingPlayState extends State<MatchingPlay> with SingleTickerProviderStateMixin {
  
  List<int> itemsLeft = [], itemsRight = [];
  final Map<int, bool> itemMatch = {};

  late final AnimationController _controller;
  bool _animationLoaded = false;

  @override
  void initState() {
    super.initState();

    itemsLeft = List<int>.generate(4, (i) => i+1);
    itemsRight = List<int>.generate(4, (i) => i+1);
    
    shuffleArrays(itemsLeft, itemsRight);

    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _itemImageAssetName(dynamic name){

    return "assets/images/matching/$name.svg";
  }

  String _itemAnimationAssetName(dynamic name){

    return "assets/animation/matching/$name.json";
  }

  Widget _emptyBox(){
    return const SizedBox(width: 0, height: 0);
  }

  @override
  Widget build(BuildContext context) {
  
     // Mendapatkan ukuran layar
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Jumlah baris dan kolom yang diinginkan
    const crossAxisCount = 1; // 2 kolom
    const mainAxisCount = 4; // 3 baris

    // Menghitung tinggi dan lebar item
    final itemWidth = screenWidth / crossAxisCount;
    final itemHeight = screenHeight / mainAxisCount;

    return Scaffold(
        body:  SafeArea(
          child: Stack(
            children:
              [
                  SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child:  SvgPicture.asset(
                          _itemImageAssetName("background"),
                          fit: BoxFit.cover
                        )
                      )
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 50.0, bottom: 50.0),
                          child: Text(
                              "mesozoik era",
                              style: TextStyle(
                                  fontFamily: fontFamilyDynaPuff,
                                  fontSize: 25,
                                  color: darkBrown,
                                ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: GridView.builder(
                                  shrinkWrap: true, // Membuat GridView menyesuaikan tinggi kontennya
                                  physics: const NeverScrollableScrollPhysics(), // Menonaktifkan scroll di dalam GridView
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount, // Jumlah kolom
                                    childAspectRatio: itemWidth / itemHeight, // Rasio lebar-tinggi item
                                  ),
                                  itemCount: crossAxisCount * mainAxisCount, // Jumlah item
                                  itemBuilder: (context, index) {
                                    int itemLeft = itemsLeft[index]; 

                                    return Container(
                                      // padding: const EdgeInsets.all(25.0),
                                      margin: const EdgeInsets.all(5.0),
                                      decoration: BoxDecoration(
                                        color: white,
                                        shape: BoxShape.circle, // Bentuk oval
                                      ),
                                      child: Draggable<int>(
                                          // Data is the value this Draggable stores.
                                          data: itemLeft,
                                          // onDragStarted: _audio.soundClick,
                                          feedback: Lottie.asset(
                                            _itemAnimationAssetName(itemLeft),
                                            width: 100.0,
                                            height: 100.0,
                                          ),
                                          childWhenDragging: _emptyBox(),
                                          child: itemMatch[itemLeft] == true ? _emptyBox() : Lottie.asset(
                                              _itemAnimationAssetName(itemLeft),
                                              fit: BoxFit.contain,
                                              controller: _controller,
                                              onLoaded: (composition) {
                                                _controller.addListener(() {
                                                  if (_controller.isCompleted) {
                                                    setState(() {
                                                      _animationLoaded = true;
                                                    });
                                                    print('Animasi Lottie selesai dimainkan!');
                                                  }
                                                });
                                                 _controller.stop();
                                                // setState(() {
                                                //   _controller.animationBehavior; // Mulai animasi setelah dimuat
                                                // });
                                            },
                                          ),
                                          onDragCompleted: (){
                                            // setState((){
                                            //   _targetDrop = 0;
                                            // });
                                          },
                                          onDraggableCanceled: (a, b){
                                            // setState(() {
                                            //   _targetDrop = 0;
                                            // });
                                          },
                                        ),
                                    );
                                  },
                                )
                            ),
                            Expanded(
                              child: GridView.builder(
                                  shrinkWrap: true, // Membuat GridView menyesuaikan tinggi kontennya
                                  physics: const NeverScrollableScrollPhysics(), // Menonaktifkan scroll di dalam GridView
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount, // Jumlah kolom
                                    childAspectRatio: itemWidth / itemHeight, // Rasio lebar-tinggi item
                                  ),
                                  itemCount: crossAxisCount * mainAxisCount, // Jumlah item
                                  itemBuilder: (context, index) {
                                    int itemRight = itemsRight[index]; 

                                    String itemName = "$itemRight.1";
                                    if (itemMatch[itemRight] == true){
                                        itemName = itemRight.toString();
                                    }
                                    return DragTarget<int>(
                                        builder: (
                                          BuildContext context,
                                          List<dynamic> accepted,
                                          List<dynamic> rejected,
                                        ) {
                                            return Container(
                                              // padding: const EdgeInsets.all(10.0),
                                              margin: const EdgeInsets.all(5.0),
                                              decoration: BoxDecoration(
                                                color: white,
                                                shape: BoxShape.circle, // Bentuk bulat
                                              ),
                                              child: Lottie.asset(
                                                _itemAnimationAssetName(itemName),
                                                fit: BoxFit.contain
                                          ),
                                            );
                                        },
                                        onWillAcceptWithDetails: (details) {

                                          // jika item kiri tidak cocok dengan item kanan maka tolak
                                          return details.data == itemRight;

                                        },
                                        onAcceptWithDetails: (details) {

                                            // jika item kiri cocok dengan item kanan maka matching benar
                                            setState(() {
                                              itemMatch[details.data] = details.data == itemRight;
                                            });

                                        }
                                      );
                                  },
                                )
                            )
                          ],
                        ),
                      ],
                    )
                  )
                      ]
                  )
        )
    );

  }
}