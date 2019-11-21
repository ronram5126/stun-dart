import 'TLV_encoding.dart';
import 'constant.dart';

class Message extends TLVEncoding {
  final int messageClass;
  final int messageMethod;
  final List<int> body;

  Message(this.messageClass, this.messageMethod, this.body) 
  : super(MESSAGE_TYPE_FILTER & (messageClass | messageMethod), body.length, body);

  factory Message.fromData(List<int> data) {
    var encoded = TLVEncoding.fromByte(data);
    int _messageClass = encoded.type & CLASS_FILTER;
    int _messageMethod = encoded.type & METHOD_FILTER;
    return new Message(_messageClass, _messageMethod, encoded.datas);
  }
}