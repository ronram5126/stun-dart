import 'dart:convert';
import 'dart:core';
import 'dart:collection';
import 'dart:typed_data';
import 'package:stun_dart/src/message/TLV_encoding.dart';
import 'package:stun_dart/src/message/attributes/address.dart';
import 'package:stun_dart/src/message/attributes/auth.dart';
import 'package:stun_dart/src/message/attributes/error.dart';
import 'package:stun_dart/src/util/constant.dart';

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
  final ByteSerilizerFactory<T> attributeGenerator;
  int get length => 4 + datas.length;

  T get attribute {
    return attributeGenerator(datas);
  }

  Attribute(this.attributeGenerator, int type, List<int> datas)
      : super(type, datas);

  factory Attribute.fromBytes(List<int> bytes) {
    var tlv = TLVEncoding.fromBytes(bytes);
    return new Attribute(getSerilizer(tlv.type), tlv.type, tlv.datas);
  }
}

class Attributes extends ListBase<Attribute<ByteSerializable>>
    implements ByteSerializable {
  Map<String, Attribute<ByteSerializable>> _typeMap;
  int get contentLength {
    return this.fold(0, (e, a) => e + a.length + 4);
  }

  Attributes() : super() {
    _typeMap = Map<String, Attribute<ByteSerializable>>();
  }

  @override
  void add(Attribute a) {
    super.add(a);
    String key = getAttributeString(a.type);
    _typeMap[key] = a;
  }

  void addFromBytes(List<int> bytes) {
    int index = 0;
    while (bytes.length - index >= 4) {
      var attrib = Attribute.fromBytes(bytes.sublist(index));
      this.add(attrib);
      index += attrib.length;
    }
  }

  @override
  int get length => _typeMap.length;

  @override
  set length(int newLength) {
    throw Exception("cannot set length of attributes");
  }

  @override
  Attribute operator [](dynamic index) {
    if (index is String) {
      return _typeMap[index];
    } else if (index is int) {
      return _typeMap.values.toList()[index];
    } else {
      throw Exception("unknown index type");
    }
  }

  @override
  void operator []=(dynamic index, Attribute value) {
    if (index is String) {
      _typeMap[index] = value;
    } else if (index is int) {
      var inx = _typeMap.keys.toList()[index];
      _typeMap[inx] = value;
    } else {
      throw Exception("unknown index type");
    }
  }

  @override
  List<int> toBytes() {
    Uint8List data = new Uint8List(contentLength);
    int idx = 0;
    this.forEach((a) {
      var d = a.toBytes();
      data.setRange(idx, d.length, d);
      idx += d.length;
    });
    return data;
  }
}

ByteSerilizerFactory getSerilizer(int attributeType) {
  switch (attributeType) {
    case ATTRIBUTE_MAPPED_ADDRESS:
      return (data) => MappedAddress.fromBytes(data);
    case ATTRIBUTE_XOR_MAPPED_ADDRESS:
      return (data) => XAddress.fromBytes(data);
    case ATTRIBUTE_ERROR_CODE:
      return (data) => ErrorCode.fromBytes(data);
    case ATTRIBUTE_USERNAME:
      return (data) => UserName.fromBytes(data);
    default:
      return (data) => new DefaultAttribute(data);
  }
}
