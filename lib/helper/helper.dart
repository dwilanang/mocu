import 'dart:math';

void shuffleArrays(List<int> array1, List<int> array2) {
  final random = Random();

  // Acak array1
  array1.shuffle(random);
  // Acak array2
  array2.shuffle(random);

  // Periksa apakah urutan array1 dan array2 sama
  while (areArraysEqual(array1, array2)) {
    // Jika sama, acak lagi array2
    array2.shuffle(random);
  }
}

bool areArraysEqual(List<int> array1, List<int> array2) {
  // Periksa apakah panjang array sama
  if (array1.length != array2.length) return false;

  // Periksa setiap elemen
  for (int i = 0; i < array1.length; i++) {
    if (array1[i] != array2[i]) {
      return false;
    }
  }

  // Jika semua elemen sama, return true
  return true;
}