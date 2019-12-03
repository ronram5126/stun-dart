import 'package:stun_dart/src/message/attributes/mapped_address.dart';
import 'util/ip.dart';

class ChangedAddress extends MappedAddress {
  ChangedAddress(IPFamily family, int port, List<int> address)
      : super(family, port, address);

  factory ChangedAddress.fromBytes(List<int> datas) {
    var add = MappedAddress.fromBytes(datas);
    return ChangedAddress(add.family, add.port, add.address);
  }
}
