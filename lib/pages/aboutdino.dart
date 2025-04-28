import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rive/rive.dart';

import 'package:mocu/constant.dart';
import 'package:mocu/util/utils.dart';
import 'package:mocu/util/animation.dart';
import 'package:mocu/util/audio.dart';
import 'package:mocu/util/alert.dart';

class AboutDino extends StatefulWidget {
  const AboutDino({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AboutDinoState createState() => _AboutDinoState();
}

class _AboutDinoState extends State<AboutDino> with SingleTickerProviderStateMixin {
  final AudioUtils _audioUtils = AudioUtils();

  late final Map<dynamic, AnimationController> _animationController = {};
  late final Map<dynamic, Animation<double>> _animation = {};

  final Map<dynamic, dynamic> animation = {};

  final List<Map<String, dynamic>> _listGame = [
    {
      'title': "Allosaurus",
      'description': "Allosaurus merupakan dinosaurus karnivor terbesar dalam Periode Jurasik. Allosaurus merupakan salah satu jenis dinosaurus yang paling baik dikenal sejauh ini selain karnivor terdahulu lainnya seperti Megalosaurus dan Tyrannosaurus rex.",
      'eat': [2,5]
    },
    {
      'title': "Ankylosaurus",
      'description': "Ankylosaurus adalah salah satu jenis dinosaurus yang hidup pada periode kapur akhir sekitar 68 juta hingga 65 juta tahun yang lalu di Amerika Utara. Memiliki tubuh sepanjang 8 meter, tingginya sekitar 2 meter, dan beratnya mencapai setidaknya 4 ton",
      'eat': [3,4,6,9]
    },
    {
      'title': "Brachiosaurus",
      'description': "Brachiosaurus adalah genus dinosaurus sauropoda yang hidup di Amerika Utara selama Jura Akhir, sekitar 154–150 juta tahun yang lalu. Dinosaurus ini pertama kali dijelaskan oleh paleontolog Amerika bernama Elmer S.",
      'eat': [1,3]
    },
    {
      'title': "Dilophosaurus",
      'description': "Dilophosaurus adalah genus dari dinosaurus theropoda yang hidup pada wilayah yang sekarang merupakan Amerika Utara pada periode Jura Awal sekitar 186 juta tahun lalu. Tiga kerangka ditemukan di Arizona utara pada 1940, dua spesimen yang paling baik terawetkan ditemukan pada 1942. ",
      'eat': [2,5]
    },
    {
      'title': "Parasaurolophus",
      'description': "Parasaurolophus adalah dinosaurus dari famili Hadrosauridae yang hidup pada masa periode kapur akhir sekitar 76,5-73 juta tahun yang lalu. Ia memiliki jambul berbentuk tabung di belakang kepala nya, mungkin untuk berkomunikasi dengan sesamanya, dan mungkin untuk memamerkan pada betina ketika musim kawin.",
      'eat': [1,3,9]
    },
    {
      'title': "Pteranodon",
      'description': "Pteranodon adalah genus pterosaurus yang termasuk beberapa reptil terbang terbesar yang pernah diketahui, dengan rentang sayap melebihi 7 meter. Mereka hidup selama periode geologi Kapur di Amerika Utara yang sekarang dikenal dengan Kansas, Alabama, Nebraska, Wyoming, dan South Dakota.",
      'eat': [7,8]
    },
    {
      'title': "Plesiosaurus",
      'description': "Plesiosaurus adalah jenis reptil laut berleher panjang dari ordo plesiosauria yang hidup di air. Termasuk jenis karnivora, karena hidup di air membuatnya harus memakan ikan. Plesiosaurus hidup pada masa awal periode Jurasik. Temuan tulang fosilnya yang hampir sempurna ditemukan di Inggris dan Jerman.",
      'eat': [2]
    },
     {
      'title': "Pachycephalosaurus",
      'description': "Pachycephalosaurus adalah herbivora Ornithischia dari famili Pachycephalosauridae yang hidup pada zaman Kapur Akhir di Amerika Utara. Genus ini diwakili oleh spesies P. wyomingensis.",
      'eat': [1,3,5,7]
    },
    {
      'title': "Spinosaurus",
      'description': "Spinosaurus merupakan dinosaurus terbesar dari anggota Spinosaurida. Spinosaurus juga merupakan satu dari tiga Theropoda terbesar sepanjang masa, yang hidup di daerah yang kini bisa dikenali sebagai Afrika bagian utara. Spinosaurus cukup terkenal saat ini, karena ukurannya mengalahkan Giganotosaurus dan Mapusaurus.",
      'eat': [2,5]
    },
    {
      'title': "Stegosaurus",
      'description': "Stegosaurus artinya `kadal beratap`, karena sisik besar di punggungnya adalah sebuah genus dinosaurus herbivora besar dari Awal Jurassic di Amerika Utara.",
      'eat': [1,3,9]
    },
    {
      'title': "Tyrannosaurus Rex",
      'description': "Tyrannosaurus adalah sebuah genus dinosaurus teropoda yang tergolong ke dalam klad Coelurosauria. Spesies Tyrannosaurus rex adalah salah satu teropoda besar yang paling dikenal oleh khalayak luas.",
      'eat': [2,5]
    },
    {
      'title': "Triceratops",
      'description': "Triceratops adalah genus dari dinosaurus ceratopsia chasmosaurinae yang hidup pada sub-kala Maastrichtium akhir pada kala Kapur Akhir, sekitar 68 hingga 66 juta tahun lalu pada wilayah yang sekarang merupakan Amerika Utara.",
      'eat': [1,3,4,6]
    },
  ];

  @override
  void initState() {
    super.initState();

    dataColors.shuffle(Random());

    animation['close'] = AnimationUtils.createAnimation(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      begin: 1.0,
      end: 1.2,
    );

    _animationController['close'] = animation['close']['controller'];
    _animation['close'] = animation['close']['animation'];
    
  }

  @override
  void dispose() {
   _animationController['close']!.dispose();

   super.dispose();
  }

  Widget _itemCard(int index, Map<String, dynamic> item){
    String title = item['title'];
    return Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: dataColors[index % dataColors.length],
        child: Row(
          children: [
            // Gambar
            Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.all(8.0),
              child: RiveAnimation.asset(
                utilItemAnimationAssetName(index+1),
                fit: BoxFit.fitHeight,
              ),
            ),
            // Judul dan Deskripsi
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: fontFamilyDynaPuff,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: white,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      "Klik untuk baca detailnya ya!",
                      textAlign: TextAlign.center, // Rata tengah teks
                      style: TextStyle(
                        fontFamily: fontFamilyDynaPuff,
                        fontSize: 14,
                        color: white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }

  Widget _itemDetail(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // Tambahkan padding di sekitar Column
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian Informasi Makanan
          Text(
            "Makanan",
            style: TextStyle(
              fontFamily: fontFamilyDynaPuff,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: white,
            ),
          ),
          const SizedBox(height: 8.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: (item['eat'] as List<int>).map((foodId) {
                return Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  child: SvgPicture.asset(
                    utilItemImageAssetName('yummy/$foodId'), // Ganti dengan path gambar SVG
                    width: 50.0,
                    height: 50.0,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16.0),
          // Bagian Deskripsi
          Text(
            "Deskripsi",
            style: TextStyle(
              fontFamily: fontFamilyDynaPuff,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: white,
            ),
          ),
          const SizedBox(height: 8.0),
          // Deskripsi dengan Scroll
          SizedBox(
            height: 200.0, // Batasi tinggi maksimum deskripsi
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Text(
                item['description'],
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontFamily: fontFamilyDynaPuff,
                  fontSize: 14,
                  color: white,
                ),
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget _bottomSheet() {
    return Container(
        width: double.infinity,
        height: 100.0, // Tinggi BottomSheet
        color:darkBrown,
        padding: EdgeInsets.all(5.0),
        child: Center(
          child: SizedBox(
          width: 50.0,
            child: GestureDetector(
                onTapDown: (_) {
                    _audioUtils.play("click");
                    Navigator.pop(context);
                },
                onTapCancel: (){
                   _animationController['close']!.reverse();
                },
                child: AnimatedBuilder(
                  animation: _animation['close']!,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _animation['close']!.value,
                      child: child,
                    );
                  },
                  child: Card(
                    color: whiteOpacity, // Hitam transparan
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100), // Oval
                    ),
                    child: Icon(
                      Icons.close, // Ikon rumah
                      size: 40.0, // Ukuran ikon
                      color: darkBrown, // Warna ikon
                    ),
                  ),
                ),
              ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: superLightBrown,
      body: Stack(
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
            GridView.builder(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 116.0), // Tambahkan padding bawah (100.0 + 16.0 margin)
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1, // Jumlah kolom
                childAspectRatio: 2.5, // Rasio tinggi dan lebar
              ),
              itemCount: _listGame.length,
              itemBuilder: (context, index) {
                final item = _listGame[index];

                return GestureDetector(
                  onTapDown: (_) {
                    _audioUtils.play("click");

                    showAlertDialog(
                      context,
                      buttonTitle: "Close",
                      content: _itemDetail(item),
                      callback: (action){
                        if (action == 'click') {
                           Navigator.pop(context);
                        }
                      }
                    );
                  },
                  onTapCancel: () {},
                  child: _itemCard(index, item),
                );
              },
            ),
          ]
      ),
      bottomSheet: _bottomSheet(),
    );
  }
}