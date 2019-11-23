import 'dart:typed_data';

import 'package:stun_dart/src/util/exceptions.dart';
import 'package:stun_dart/src/util/magic_cookie.dart';
import 'package:stun_dart/src/message/TLV_encoding.dart';

enum IPFamily { ipv4, ipv6 }

IPFamily getFamily(int data) {
  switch (data) {
    case 0x01:
      return IPFamily.ipv4;
      break;
    case 0x02:
      return IPFamily.ipv6;
      break;
    default:
      throw InvalidEncoding("unknown ip family!");
  }
}

int getFamilyByte(IPFamily fam) {
  switch (fam) {
    case IPFamily.ipv4:
      return 0x01;
      break;
    case IPFamily.ipv6:
      return 0x02;
      break;
    default:
      throw InvalidEncoding("unknown ip family!");
  }
}

class MappedAddress implements ByteSerializable {
  final IPFamily family;
  final int port;
  final List<int> address;

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
    if (datas.length != 20 || datas.length != 8) {
      throw InvalidEncoding(
          "Data length is not valid. Expected 20 byte or 8 byte data got ${datas.length} bytes");
    }
    int _port = datas[2] << 8 & datas[3] * 0xff;
    List<int> _address = datas.sublist(3, datas.length);
    return new MappedAddress(getFamily(datas[1]), _port, _address);
  }
}

class MappedAddressFactory implements ByteSerializableFactory<MappedAddress> {
  @override
  MappedAddress generateSerilizableFromBytes(List<int> bytes) {
    return MappedAddress.fromBytes(bytes);
  }
}

class XAddress extends MappedAddress {
  final List<int> actualAddress;

  XAddress(IPFamily family, int port, this.actualAddress)
      : super(family, port, MAGIC_XOR(actualAddress));

  factory XAddress.fromMappedAddress(MappedAddress mappedAddress,
      {IPFamily family, int port, List<int> address}) {
    return new XAddress(family ?? mappedAddress.family,
        port ?? mappedAddress.port, address ?? mappedAddress.address);
  }

  factory XAddress.fromBytes(List<int> datas) {
    var _mappedAddress = MappedAddress.fromBytes(datas);
    return XAddress.fromMappedAddress(_mappedAddress,
        address: MAGIC_XOR(_mappedAddress.address));
  }
}

class XAddressFactory implements ByteSerializableFactory<XAddress> {
  @override
  XAddress generateSerilizableFromBytes(List<int> bytes) {
    return XAddress.fromBytes(bytes);
  }
}
