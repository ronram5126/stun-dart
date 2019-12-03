import 'package:stun_dart/src/message/attributes/change_address.dart';
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
      return (datas) => MappedAddress.fromBytes(datas);
    case ATTRIBUTE_CHANGE_ADDRESS:
      return (datas) => ChangeAddress.fromBytes(datas);
    case ATTRIBUTE_CHANGED_ADDRESS:
      return (datas) => ChangedAddress.fromBytes(datas);
    case ATTRIBUTE_XOR_MAPPED_ADDRESS:
      return (datas) => XAddress.fromBytes(datas);
    case ATTRIBUTE_ERROR_CODE:
      return (datas) => ErrorCode.fromBytes(datas);
    case ATTRIBUTE_USERNAME:
      return (datas) => UserName.fromBytes(datas);
    default:
      return (datas) => new DefaultAttribute(datas);
  }
}
