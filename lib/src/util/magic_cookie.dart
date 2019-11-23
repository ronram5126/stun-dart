import 'constant.dart';

final List<int> MAGIC_COOKIE_ARRAY = [
  (MAGIC_COOKIE >> 24) & 0xFF,
  (MAGIC_COOKIE >> 16) & 0xFF,
  (MAGIC_COOKIE >> 8) & 0xFF,
  (MAGIC_COOKIE ) & 0xFF
];

List<int> MAGIC_XOR (List<int> data) {
  List<int> result = new List<int>();
  
  for(int c = 0; c < data.length; c++) {
    int currentDataByte = data[c];
    int currentMagicByte = MAGIC_COOKIE_ARRAY[c % MAGIC_COOKIE_ARRAY.length];
    
    result.add(currentDataByte ^ currentMagicByte);
  }
  return result;
} 
