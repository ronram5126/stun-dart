import 'dart:typed_data';

class InvalidEncoding implements Exception {
  String cause;
  InvalidEncoding(this.cause);
}




class TLVEncoding {
  final int type;
  final int length;
  final List<int> datas;

  TLVEncoding(this.type, this.length, this.datas);

  List<int> toList() {
    while(datas.length % 4 != 0) {
      datas.add(0);
    }

    var actualLength = datas.length + 4;
    var result = new Uint8List(actualLength);
    
    result.setRange(0, actualLength, [type>>8, type & 15,  length>>8, length & 15, ...(datas??[])]);
    return result;
  }

  factory TLVEncoding.fromByte(List<int> byteData) {
    if (byteData.length < 4) {
      throw InvalidEncoding("Given Data must include 32-bit (4 byte) information, 16-bit for type and 16-bit for length.");
    }
    int _type = byteData[0] << 8 + byteData[1] & 15;
    int _length = byteData[2] << 8 + byteData[3] & 15;
    List<int> _datas = new List<int>();
    if (byteData.length > 4) {
      _datas.addAll(byteData.sublist(4));
    }
    return new TLVEncoding(_type, _length, _datas);
  }
}