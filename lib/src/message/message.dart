import 'dart:convert';
import 'dart:typed_data';

import 'package:stun_dart/src/util/magic_cookie.dart';
import 'package:stun_dart/src/util/constant.dart';
import 'package:uuid/uuid.dart';

import 'TLV_encoding.dart';
import 'attributes/attributes.dart';

List<int> newTransactionId() {
  var uuid = new Uuid();
  String uuidString = uuid.v1();
  uuidString = '${uuidString.substring(0, 8)}${uuidString.substring(9, 13)}';
  return utf8.encode(uuidString);
}

class Message extends TLVEncoding {
  int get messageClass {
    return this.type & CLASS_FILTER;
  }

  int get messageMethod {
    return this.type & METHOD_FILTER;
  }

  Attributes _attributes;

  Attributes get attributes {
    if (_attributes == null) {
      _attributes = new Attributes();
      _attributes.addFromBytes(this.datas);
    }
    return _attributes;
  }

  List<int> _transactionId;

  List<int> get transactionId {
    if (_transactionId == null || _transactionId.length != 12) {
      _transactionId = newTransactionId();
    }
    return _transactionId;
  }

  Message(int messageClass, int messageMethod,
      {List<int> transactionId, List<int> body, Attributes attributes})
      : super(
            MESSAGE_TYPE_FILTER & (messageClass | messageMethod),
            attributes != null
                ? attributes.toBytes()
                : body != null
                    ? body
                    : throw Exception(
                        "You must supply either attributes or body.")) {
    this._transactionId = transactionId ?? newTransactionId();
  }

  @override
  List<int> toBytes() {
    List<int> superBytes = super.toBytes();
    var result =
        new Uint8List(superBytes.length + 12 + MAGIC_COOKIE_ARRAY.length);
    var valList = [
      ...superBytes.sublist(0, 4),
      ...MAGIC_COOKIE_ARRAY,
      ...this.transactionId,
    ];

    if (superBytes.length > 4) {
      valList.addAll(superBytes.sublist(5));
    }

    result.setAll(0, valList);
    return result;
  }

  factory Message.fromBytes(List<int> data) {
    var encoded =
        TLVEncoding.fromBytes([...data.sublist(0, 4), ...data.sublist(20)]);
    int _messageClass = encoded.type & CLASS_FILTER;
    int _messageMethod = encoded.type & METHOD_FILTER;
    List<int> transactionId = data.sublist(8, 20);
    return new Message(_messageClass, _messageMethod,
        body: encoded.datas, transactionId: transactionId);
  }
}

class MessageFactory implements ByteSerializableFactory<Message> {
  @override
  Message generateSerilizableFromBytes(List<int> bytes) {
    return Message.fromBytes(bytes);
  }
}
