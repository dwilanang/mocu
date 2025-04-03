
String utilItemImageAssetName(dynamic name) {
  return "assets/images/$name.svg";
}

String utilItemAnimationAssetName(dynamic name) {
  return "assets/animation/$name.riv";
}

int utilPointStar(double total) {
    if (total >= 0 && total < 2) {
      return 1;
    } else if (total >= 2 && total < 4) {
      return 2;
    } else if (total >= 4 && total < 6) {
      return 3;
    } else if (total >= 6 && total < 8) {
      return 4;
    } else if (total >= 8) {
      return 5;
    } else {
      return 0; // Nilai di luar rentang
    }
}