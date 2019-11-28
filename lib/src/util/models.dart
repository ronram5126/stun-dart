import 'package:stun_dart/src/message/message.dart';

typedef void StunCallback(String address);

enum NATType {
  Unknown,
  Blocked,
  Full,
  Restricted,
  PortRestricted,
  Symmetric,
  Open
}

class TimedMessage {
  final DateTime dateTime;
  final Message message;

  TimedMessage(this.dateTime, this.message);
}

class RespondedFromData extends RespondedData {
  final String from;

  RespondedFromData(this.from, DateTime lastRecieved, String result): super(lastRecieved, result);
}


class RespondedData {
  final DateTime lastRecieved;
  final String result;

  RespondedData(this.lastRecieved, this.result);
  
}
