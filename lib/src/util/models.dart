import 'package:stun_dart/src/message/message.dart';

typedef void StunCallback(String address);

enum NATType { Unknown, Connected, AnyPort, AnyIP }

const Map<NATType, int> natMap = {
  NATType.Unknown: 0,
  NATType.Connected: 2,
  NATType.AnyPort: 4,
  NATType.AnyIP: 6,
};

class TimedMessage {
  final DateTime dateTime;
  final Message message;

  TimedMessage(this.dateTime, this.message);
}

class RespondedFromData extends RespondedData {
  final String from;

  RespondedFromData(
      this.from, DateTime lastRecieved, String result, NATType natType)
      : super(lastRecieved, result, natType);
}

class RespondedData {
  final DateTime lastRecieved;
  final String result;
  final NATType natType;

  RespondedData(this.lastRecieved, this.result, this.natType);
}
