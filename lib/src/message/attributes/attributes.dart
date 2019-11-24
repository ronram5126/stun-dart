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

class Attributes extends ListBase<Attribute<ByteSerializable>>
    implements ByteSerializable {
  List<Attribute<ByteSerializable>> attributes;

  int get contentLength {
    return this.fold(0, (e, a) => e + a.length + 4);
  }

  Attributes() : super() {
    this.attributes = new List<Attribute<ByteSerializable>>();
  }

  void addFromBytes(List<int> bytes) {
    int index = 0;
    while (bytes.length - index >= 4) {
      var attrib = Attribute.fromBytes(bytes.sublist(index));
      attributes.add(attrib);
      index += attrib.length;
    }
  }

  @override
  int get length {
    return attributes.length;
  }

  @override
  set length(int _length) {
    attributes.length = _length;
  }

  @override
  Attribute operator [](int index) {
    return attributes[index];
  }

  @override
  void operator []=(int index, Attribute value) {
    attributes[index] = value;
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
