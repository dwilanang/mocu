import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EggCracker extends StatefulWidget {
  const EggCracker({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EggCrackerGameState createState() => _EggCrackerGameState();
}

class _EggCrackerGameState extends State<EggCracker> {
  int _score = 0;
  bool _isCracked = false;
  int _tapCount = 0;
  final int _maxTaps = 3;
  double _opacity = 0.0;
  bool _showCracked = false; // Tambahkan variabel untuk mengontrol tampilan telur pecah

  void _crackEgg() {
  setState(() {
    if (!_isCracked) {
      _tapCount++;
      print('Tap Count: $_tapCount'); // Tambahkan print ini
      if (_tapCount >= _maxTaps) {
        _isCracked = true;
        _score++;
        _showCracked = true;
        _opacity = 1.0;

        Future.delayed(Duration(milliseconds: 500), () {
          setState(() {
            _opacity = 0.0;
          });
        });

        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _isCracked = false;
            _tapCount = 0;
            _showCracked = false;
          });
        });
      }
    }
  });
}

  void _resetGame() {
    setState(() {
      _score = 0;
      _isCracked = false;
      _tapCount = 0;
      _opacity = 0.0;
      _showCracked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pecahkan Telur'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: _crackEgg,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                 
                  _showCracked ?  AnimatedOpacity(
                      opacity: _opacity,
                      duration: Duration(milliseconds: 500),
                      child: SvgPicture.asset(
                        'assets/images/eggcracked.svg',
                        width: 150,
                        height: 200,
                      ),
                      onEnd: (){
                        print("Opacity : $_opacity, showCracked: $_showCracked");
                      },
                  )
                 :
                     SvgPicture.asset(
                      'assets/images/egg.svg',
                      width: 150,
                      height: 200,
                    )
                ],
              ),
            ),
            SizedBox(height: 20),
            Text('Skor: $_score', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetGame,
              child: Text('Mulai Ulang'),
            ),
          ],
        ),
      ),
    );
  }
}