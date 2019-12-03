import 'dart:io';
import 'dart:typed_data';

import 'package:stun_dart/src/util/exceptions.dart';
import 'util/ip.dart';

import '../TLV_encoding.dart';

class MappedAddress implements ByteSerializable {
  final IPFamily family;
  final int port;
  final List<int> address;
  InternetAddress getNetAddress() {
    String addr;
    if (address.length > 4) {
      addr = address.map((f) => f.toRadixString(16)).join(":");
    } else {
      addr = address.join(".");
    }
    return InternetAddress(addr);
  }

  MappedAddress(this.family, this.port, this.address);

  List<int> toBytes() {
    Uint8List result;
    switch (this.family) {
      case IPFamily.ipv4:
        result = new Uint8List(8);
        break;
      case IPFamily.ipv6:
        result = new Uint8List(20);
        break;
      default:
        throw Exception("Unknown Ip family");
    }

    result.setAll(0, [
      0x00,
      getFamilyByte(this.family),
      (this.port >> 8) & 0xff,
      this.port & 0xff,
      ...this.address
    ]);

    return result;
  }

  factory MappedAddress.fromBytes(List<int> datas) {
    if (datas.length != 20 && datas.length != 8) {
      throw InvalidEncoding(
          "Data length is not valid. Expected 20 byte or 8 byte data got ${datas.length} bytes");
    }

    int _port = datas[2] << 8 | datas[3] & 0xff;
    List<int> _address = datas.sublist(4);
    return new MappedAddress(getFamily(datas[1]), _port, _address);
  }
}

class MappedAddressFactory implements ByteSerializableFactory<MappedAddress> {
  @override
  MappedAddress generateSerilizableFromBytes(List<int> bytes) {
    return MappedAddress.fromBytes(bytes);
  }
}
