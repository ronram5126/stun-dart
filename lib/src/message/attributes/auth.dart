import 'dart:convert';

import 'package:stun_dart/src/message/TLV_encoding.dart';
import 'package:stun_dart/src/util/exceptions.dart';
import 'package:dart_stringprep/string_prep.dart';

final STRPREPFUNC nameprep = preps["nameprep"];

class UserName implements ByteSerializable {
  final String username;

  UserName(this.username);

  factory UserName.fromBytes(List<int> data) {
    return new UserName(utf8.decode(data));
  }

  @override
  List<int> toBytes() {
    if (username.length > 512) {
      throw InvalidEncoding("Username must be less than 512 byte");
    }
    return utf8.encode(nameprep(this.username));
  }
}

class MappedAddressFactory implements ByteSerializableFactory<UserName> {
  @override
  UserName generateSerilizableFromBytes(List<int> bytes) {
    return UserName.fromBytes(bytes);
  }
}
