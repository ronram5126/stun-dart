import 'dart:core';
import 'dart:collection';
import 'dart:typed_data';
import 'package:stun_dart/src/message/TLV_encoding.dart';

import 'default_attribute.dart';

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
