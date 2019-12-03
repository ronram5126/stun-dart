import 'dart:convert';

import '../TLV_encoding.dart';
import 'util/get_serilizable.dart';

class DefaultAttribute extends ByteSerializable {
  final List<int> data;

  DefaultAttribute(this.data);
  String get utf8String => utf8.decode(data);

  @override
  List<int> toBytes() {
    return data;
  }
}

class Attribute<T extends ByteSerializable> extends TLVEncoding {
  ByteSerilizerFactory<T> _attributeGenerator;
  int get length => 4 + datas.length;

  T _attribute;

  T get attribute {
    if (_attribute == null) {
      _attribute = _attributeGenerator(datas);
    }
    return _attribute;
  }

  Attribute(int type, List<int> datas) : super(type, datas) {
    this._attributeGenerator = getSerilizer(type);
  }
  factory Attribute.fromAttribute(int type, T attrib) {
    return Attribute(type, attrib.toBytes());
  }

  factory Attribute.fromBytes(List<int> bytes) {
    var tlv = TLVEncoding.fromBytes(bytes);
    return new Attribute(tlv.type, tlv.datas);
  }
}
