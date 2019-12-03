import 'util/ip.dart';
import 'package:stun_dart/src/util/magic_cookie.dart';

import '../TLV_encoding.dart';
import 'mapped_address.dart';

class XAddress extends MappedAddress {
  final List<int> actualAddress;
  final int actualPort;

  XAddress(IPFamily family, this.actualPort, this.actualAddress)
      : super(family, MAGIC_XOR_INT16(actualPort), MAGIC_XOR(actualAddress));

  factory XAddress.fromMappedAddress(MappedAddress mappedAddress,
      {IPFamily family, int port, List<int> address}) {
    return new XAddress(family ?? mappedAddress.family,
        port ?? mappedAddress.port, address ?? mappedAddress.address);
  }

  factory XAddress.fromBytes(List<int> datas) {
    var _mappedAddress = MappedAddress.fromBytes(datas);
    return XAddress.fromMappedAddress(_mappedAddress,
        address: MAGIC_XOR(_mappedAddress.address),
        port: MAGIC_XOR_INT16(_mappedAddress.port));
  }
}

class XAddressFactory implements ByteSerializableFactory<XAddress> {
  @override
  XAddress generateSerilizableFromBytes(List<int> bytes) {
    return XAddress.fromBytes(bytes);
  }
}
