import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:mocu/constant.dart';
import 'package:mocu/helper/helper.dart';
import 'package:mocu/utils/alert.dart';

class MatchingPlay extends StatefulWidget {
  const MatchingPlay({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MatchingPlayState createState() => _MatchingPlayState();
}

class _MatchingPlayState extends State<MatchingPlay> with SingleTickerProviderStateMixin {
  
  List<int> _itemsLeft = [], _itemsRight = [];
  final Map<int, bool> _itemMatch = {};

  bool _animationLoaded = true;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _itemsLeft = List<int>.generate(4, (i) => i+1);
    _itemsRight = List<int>.generate(4, (i) => i+1);
    
    shuffleArrays(_itemsLeft, _itemsRight);

    _controller = AnimationController(vsync: this);
    _controller.stop();
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

  Widget _itemAnimationLeft(dynamic name, double itemWidth, itemHeight){
    return ClipOval(
      child: SizedBox(
        width: _animationLoaded ? 0 : itemWidth,
        height: _animationLoaded ? 0 : itemHeight,
        child: Lottie.asset(
          _itemAnimationAssetName(name),
          controller: _controller,
          onLoaded: (composition) {
            setState(() {
              _animationLoaded = false;
            });
            _controller
              ..duration = composition.duration
              ..forward().whenComplete(() {
                _controller
                  ..duration = composition.duration
                  ..repeat();
              });
          },
          options: LottieOptions(enableMergePaths: true), // Enable caching
        ),
      ),
    );
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
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SvgPicture.asset(
                  _itemImageAssetName("background"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SingleChildScrollView(
              child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Visibility(
                      visible: _animationLoaded,
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text(
                              "Menunggu mempersiapkan data",
                              style: TextStyle(
                                fontFamily: fontFamilyDinoRegular,
                                fontSize: 18.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        !_animationLoaded ?
                          Text(
                              "Cocokan Karakter",
                              style: TextStyle(
                                fontFamily: fontFamilyDinoRegular,
                                fontSize: 25.0,
                              ),
                            )
                        : 
                        SizedBox.shrink(),
                        
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
                                    int itemLeft = _itemsLeft[index]; 

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
                                          feedback: LottieBuilder.asset(
                                            _itemAnimationAssetName(itemLeft),
                                            width: 100.0,
                                            height: 100.0,
                                          ),
                                          childWhenDragging: _emptyBox(),
                                          child: _itemMatch[itemLeft] == true ? 
                                          _emptyBox() 
                                          : 
                                          _itemAnimationLeft(itemLeft, itemWidth, itemHeight),
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
                                    int itemRight = _itemsRight[index]; 

                                    String itemName = "$itemRight.1";
                                    if (_itemMatch[itemRight] == true){
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
                                              child: _itemAnimationLeft(itemName, itemWidth, itemHeight),
                                            );
                                        },
                                        onWillAcceptWithDetails: (details) {

                                          // jika item kiri cocok dengan item kanan maka tolak
                                          if (_itemMatch[details.data]==true) {
                                              return false;
                                          }

                                          return true;
                                        },
                                        onAcceptWithDetails: (details) {
                                            var isMatch = details.data == itemRight;
                                            
                                            if (isMatch) {
                                                // jika item kiri cocok dengan item kanan maka matching benar
                                                setState(() {
                                                  _itemMatch[details.data] = isMatch;
                                                });
                                            } else {
                                                showAlertDialog(context, "Upps tidak cocok, coba lagi ya!", "Coba Lagi", Lottie.asset('assets/animation/sad.json', width: 100.0), (){});
                                            }
                                        }
                                      );
                                  },
                                )
                            )
                          ],
                        ), 
                      ]
                    )
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }
}