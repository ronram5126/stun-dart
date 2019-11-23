import 'dart:convert';
import 'dart:typed_data';

import 'package:stun_dart/src/util/exceptions.dart';
import 'package:stun_dart/src/message/TLV_encoding.dart';

class ErrorCode implements ByteSerializable {
  final int errorClass;
  final int errorNumber;
  final String reason;

  ErrorCode(this.errorClass, this.errorNumber, this.reason);

  List<int> toBytes() {
    int actualLength = 4 + reason.length;
    actualLength += actualLength % 4 > 0
        ? (4 - actualLength % 4)
        : 0; // padding to 32-Bit Boundary
    Uint8List result = new Uint8List(actualLength);
    result.setAll(0, [
      0x00,
      0x00,
      0xF & this.errorClass,
      0xFF & this.errorNumber,
      ...utf8.encode(reason)
    ]);
    return result;
  }

  factory ErrorCode.fromBytes(List<int> bytes) {
    if (bytes.length < 4) {
      throw InvalidEncoding("Length of Error must be atleast 4 bytes");
    }
    int _class = bytes[3] & 0xf;
    int _code = bytes[4];
    String _reason = bytes.length > 4 ? utf8.decode(bytes.sublist(5)) : "";

    return new ErrorCode(_class, _code, _reason);
  }
}

class ErrorCodeFactory implements ByteSerializableFactory<ErrorCode> {
  @override
  ErrorCode generateSerilizableFromBytes(List<int> bytes) {
    return ErrorCode.fromBytes(bytes);
  }
}
