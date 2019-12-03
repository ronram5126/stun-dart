import 'package:stun_dart/src/util/exceptions.dart';

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
