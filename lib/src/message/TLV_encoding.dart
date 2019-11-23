import 'dart:typed_data';

import '../util/exceptions.dart';

typedef T ByteSerilizerFactory<T extends ByteSerializable>(List<int> bytes);

abstract class ByteSerializableFactory<T extends ByteSerializable> {
  T generateSerilizableFromBytes(List<int> bytes);
}

abstract class ByteSerializable {
  List<int> toBytes();
}

class TLVEncoding implements ByteSerializable {
  final int type;
  final List<int> datas;

  TLVEncoding(this.type, this.datas);

  List<int> toBytes() {
    // Padding to 32 bit boundaries

    while (datas.length % 4 != 0) {
      datas.add(0);
    }
    var dataLength = datas.length;
    var fullLength = dataLength + 4;
    var result = new Uint8List(fullLength);

    result.setAll(0, [
      type >> 8,
      type & 0xff,
      dataLength >> 8,
      dataLength & 0xff,
      ...(datas ?? [])
    ]);
    return result;
  }

  factory TLVEncoding.fromBytes(List<int> byteData) {
    if (byteData.length < 4) {
      throw InvalidEncoding(
          "Given Data must include 32-bit (4 byte) information, 16-bit for type and 16-bit for length.");
    }
    int _type = byteData[0] << 8 | byteData[1] & 0xff;
    int _length = byteData[2] << 8 | byteData[3] & 0xff;
    List<int> _datas = new List<int>();

    if (byteData.length > 4) {
      if (byteData.length - 4 < _length) {
        throw InvalidEncoding(
            "Given data is shorted than specified length in TLV data.");
      }
      _datas.addAll(byteData.sublist(4, 4 + _length));
    }

    return new TLVEncoding(_type, _datas);
  }
}

class TLVEncodingFactory implements ByteSerializableFactory<TLVEncoding> {
  @override
  TLVEncoding generateSerilizableFromBytes(List<int> bytes) {
    return TLVEncoding.fromBytes(bytes);
  }
}
