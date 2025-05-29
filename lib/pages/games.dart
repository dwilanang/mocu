import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mocu/constant.dart';
import 'package:mocu/util/audio.dart';
import 'package:mocu/util/animation.dart';
import 'package:mocu/provider/action.dart';
import 'package:mocu/widget/sectionbottom.dart';
import 'package:mocu/util/utils.dart';

class Games extends StatefulWidget {
  const Games({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GamesState createState() => _GamesState();
}

class _GamesState extends State<Games> with TickerProviderStateMixin, WidgetsBindingObserver {

  final AudioUtils _audioUtils = AudioUtils();

  late final Map<dynamic, AnimationController> _animationController = {};
  late final Map<dynamic, Animation<double>> _animation = {};

  late final Map<int, AnimationController> _animationControllerPlay = {};
  late final Map<int, Animation<double>> _animationPlay = {};

  final Map<dynamic, dynamic> animation = {};
  final  Map<int, dynamic> playAnimation = {};

  final List<Map<String, dynamic>> _listGame = [
      {'title': "Matching", 'page':'/matching'}, 
      {'title': "Feeding", 'page':'/feeding'}, 
      {'title': "Memory", 'page':'/memory'}, 
      // {'title': "Crack Egg", 'page':'/crack-egg'}, 
      {'title': "About Dino", 'page':'/about-dino'}
  ];

  bool _soundMode = true;

  @override
  void initState() {
    super.initState();

    // Kunci ke portrait saat halaman ini dibuka
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Tambahkan observer untuk mendeteksi perubahan lifecycle
    WidgetsBinding.instance.addObserver(this);

    _audioUtils.play("backsound", loop: true);

    animation['sound'] = AnimationUtils.createAnimation(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      begin: 1.0,
      end: 1.2,
    );

    _animationController['sound'] = animation['sound']['controller'];
    _animation['sound'] = animation['sound']['animation'];

    for (int i = 1; i <= _listGame.length; i++) {
      playAnimation[i] = AnimationUtils.createAnimation(
          vsync: this,
          duration: const Duration(milliseconds: 100),
          begin: 1.0,
          end: 1.2
        );

        _animationControllerPlay[i] = playAnimation[i]['controller'];
        _animationPlay[i] = playAnimation[i]['animation'];

        animation[i] = AnimationUtils.createAnimationRepeatNoReverse(
            vsync: this,
            duration: const Duration(seconds: 5),
            begin: 0.0, end: 3 * math.pi
        );

      _animationController[i] = animation[i]['controller'];
      _animation[i] = animation[i]['animation'];
    }

    
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

     _audioUtils.stopAll();
    if (_soundMode && state == AppLifecycleState.resumed) {
      // Halaman menjadi aktif kembali
       _audioUtils.play("backsound", loop: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Hapus observer
    _audioUtils.stopAll();

    List<String> animations = ['sound'];
    for (String v in animations) {
      _animationController[v]!.dispose();
    }

    for (int i = 1; i <= _listGame.length; i++) {
      _animationControllerPlay[i]!.dispose();
      _animationController[i]!.dispose();
    }

    super.dispose();
  }
 
  Widget _sectionBottom(){
    return SectionBottom(
          animationController: _animationController,
          animation: _animation,
          isSoundMode: _soundMode,
          onSoundTapDown: (){
            _audioUtils.play("click");
            _animationController['sound']!.forward();
            setState(() {
              _soundMode = !_soundMode;

              if (_soundMode) {
                  _audioUtils.play("backsound", loop: true);
              } else {
                  _audioUtils.stop("backsound");
              }
            });
          },
          onSoundTapCancel: (){
            _animationController['sound']!.reverse();
          },
         
        );
  }
  
  Widget _itemGame(int i, Map<String, dynamic> item) {
  return GestureDetector(
    onTapDown: (_) {
      _animationControllerPlay[i]!.forward();
      
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) {
          _audioUtils.setVolume("backsound", 0.3);
          Navigator.pushNamed(context, item['page']).then((_) {
            _audioUtils.setVolume("backsound", 1.0);
          });
        }
      });
    },
    onTapUp: (_) {
      _audioUtils.play("click");
    },
    onTapCancel: () {
      _animationControllerPlay[i]!.reverse();
    },
    child: AnimatedBuilder(
      animation: _animationPlay[i]!,
      builder: (context, child) {
        return Transform.scale(
          scale: _animationPlay[i]!.value,
          child: child,
        );
      },
      child: Card(
        color: softBrownOpacity, // Transparan
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Oval
        ),
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0), // Jarak antar item
        child: Center(
          child: Text(
            item['title'],
            style: TextStyle(
              color: white,
              fontSize: 20.0,
              fontFamily: fontFamilyDynaPuff,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: softBrown,
        body: SafeArea(
          child: Stack(
            children: [
              SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SvgPicture.asset(
                    utilItemImageAssetName('background'),
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SvgPicture.asset(
                    utilItemImageAssetName('bgoverlay'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    height: 50.0,
                  ),
                  SvgPicture.asset(
                      utilItemImageAssetName('dinosaurbymocu'),
                      height: 100.0,
                  ),
                   SizedBox(
                    height: 25.0,
                  ),
                  Expanded(
                    // padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                    child: GridView.count(
                      crossAxisCount: 1, // Jumlah kolom
                      childAspectRatio: 4.0, // Sesuaikan rasio tinggi
                      children: _listGame.asMap().entries.map((entry) {
                        int index = entry.key;
                        Map<String, dynamic> item = entry.value;
                        return _itemGame(index+1, item);
                      }).toList()
                    ),
                  )
                ],
              )
              ,
                Consumer<ActionProvider>(
                  builder: (context, model, child) {
                    if(model.execAction["sound"] != null){
                        if (model.execAction["sound"]! == true){
                          _audioUtils.play("backsound", loop: true);
                          _audioUtils.setVolume("backsound", 0.3);
                        } else {
                          _audioUtils.stop("backsound");
                        }
                    }

                    return SizedBox.shrink();
                  },
                ),
            ],
          ),
        ),
        bottomSheet: _sectionBottom(),
      )
    );
  }
}