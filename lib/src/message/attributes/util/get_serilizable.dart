import 'package:stun_dart/src/message/attributes/changed_address.dart';
import 'package:stun_dart/src/message/attributes/username.dart';
import 'package:stun_dart/src/message/attributes/xaddress.dart';
import 'package:stun_dart/src/util/constant.dart';

import '../../TLV_encoding.dart';
import '../default_attribute.dart';
import '../error.dart';
import '../mapped_address.dart';

ByteSerilizerFactory getSerilizer(int attributeType) {
  switch (attributeType) {
    case ATTRIBUTE_MAPPED_ADDRESS:
      return (data) => MappedAddress.fromBytes(data);
    case ATTRIBUTE_CHANGED_ADDRESS:
      return (data) => ChangedAddress.fromBytes(data);
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
