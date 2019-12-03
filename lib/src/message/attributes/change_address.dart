import 'package:stun_dart/src/message/TLV_encoding.dart';
import 'package:stun_dart/src/util/exceptions.dart';

class ChangeAddress extends ByteSerializable {
  final bool changeIp;
  final bool changePort;

  ChangeAddress(this.changeIp, this.changePort) : super();

  factory ChangeAddress.fromBytes(List<int> datas) {
    if (datas.length < 4) {
      throw InvalidEncoding("Invalid Data length.");
    }

    if (datas[3] & 0xF9 != 0) {
      throw InvalidEncoding("Incorrect flags. ${datas[3]}");
    }

    bool _changeIp = datas[3] & 4 == 4;
    bool _changePort = datas[3] & 2 == 2;
    return ChangeAddress(_changeIp, _changePort);
  }

  @override
  List<int> toBytes() {
    List<int> result = [0, 0, 0, 0];
    result[3] = (this.changeIp ? 4 : 0) | (this.changePort ? 2 : 0);
    return result;
  }
}
