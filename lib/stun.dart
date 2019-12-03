import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:isolate';
import 'package:stun_dart/public_STUN.dart';
import 'package:stun_dart/src/message/attributes/xaddress.dart';
import 'package:stun_dart/src/message/message.dart';
import 'package:stun_dart/src/util/constant.dart';
import 'package:stun_dart/src/util/models.dart';

Isolate isolation;

StreamSubscription _streamSubscription;
RawDatagramSocket _socket;
bool _keepSTUNNING;
bool _stunning;
NATType currentNatType = NATType.Unknown;
Timer queCheck;

final UnknownAddressResult = () => new RespondedData(DateTime.now(), "NA");
final List<TimedMessage> messages = new List<TimedMessage>();
final List<RespondedFromData> responses = new List<RespondedFromData>();

RespondedData calculateResponse() {
  if (responses == null || responses.length == 0) {
    return UnknownAddressResult();
  }

  responses.sort((a, b) => b.lastRecieved.compareTo(a.lastRecieved));

  // remove expired responses
  responses.removeWhere((a) =>
      DateTime.now().difference(a.lastRecieved).inMinutes >
      RESPONSE_TIMEOUT_MINUTES);

  if (responses.length == 0) {
    return UnknownAddressResult();
  }

  String responseResult = responses[0].result;
  DateTime respondedTime = responses[0].lastRecieved;

  for (int c = 1; c < responses.length; c++) {
    String _responseResult = responses[c].result;
    DateTime _respondedTime = responses[c].lastRecieved;
    if (responseResult != _responseResult) {
      return UnknownAddressResult();
    }

    if (respondedTime.difference(_respondedTime).inMilliseconds < 0) {
      respondedTime = _respondedTime;
    }
  }

  return RespondedData(respondedTime, responseResult);
}

Future initializeStun([StunCallback callback]) async {
  await RawDatagramSocket.bind(InternetAddress.anyIPv4, 5126)
      .then((sock) => _socket = sock);
  _streamSubscription = _socket.listen((event) {
    if (event == RawSocketEvent.read) {
      Datagram recievedData = _socket.receive();
      String recievedFrom =
          recievedData.address.address + ":" + recievedData.port.toString();
      var message = Message.fromBytes(recievedData.data);
      for (int c = 0; c < messages.length; c++) {
        var msg = messages[c].message;
        var idx = 0;
        if (message.transactionId
            .every((_tID) => _tID == msg.transactionId[idx++])) {
          messages.removeAt(c--);
        }
      }
      var attributes = message.attributes;
      if (attributes.length > 0) {
        for (int c = 0; c < attributes.length; c++) {
          var tlvAttribute = attributes[c];
          if (tlvAttribute.type == ATTRIBUTE_XOR_MAPPED_ADDRESS) {
            XAddress attribute = tlvAttribute.attribute;
            var ipaddress = attribute.actualAddress;
            var port = attribute.actualPort;
            String selfAddress = ipaddress.join(".") + ":$port";
            addResponse(recievedFrom, selfAddress);
            if (callback != null) callback(selfAddress);
          }
        }
      }
    }
  });

  initQueTimer();
  await initRequest();
}

void addResponse(String recievedFrom, String selfAddress) {
  responses.forEach((response) {
    if (response.from == recievedFrom) {
      responses.remove(response);
    }
  });

  responses
      .add(new RespondedFromData(recievedFrom, DateTime.now(), selfAddress));
}

void stopQueTimer() {
  if (queCheck != null) {
    queCheck.cancel();
    queCheck = null;
  }
}

void initQueTimer() {
  stopQueTimer();
  queCheck = Timer.periodic(new Duration(seconds: TIMEOUT_SECONDS), (Timer t) {
    messages.forEach((message) {
      if (DateTime.now().difference(message.dateTime).inSeconds >
          TIMEOUT_SECONDS) {
        messages.remove(message);
      }
    });
  });
}

Future initRequest() async {
  messages.clear();
  responses.clear();

  _keepSTUNNING = true;
  _stunning = true;
  while (_keepSTUNNING) {
    for (int c2 = 0; c2 < publicSTUNs.length; c2++) {
      var message = Message(CLASS_REQUEST, METHOD_BINDING, body: List<int>());
      messages.add(new TimedMessage(DateTime.now(), message));

      var byteData = message.toBytes();
      var publicSTUN = publicSTUNs[c2];

      await _socket.send(byteData, publicSTUN.address, publicSTUN.port);
      await Future.delayed(Duration(seconds: 1));
    }
    await Future.delayed(Duration(seconds: 10));
  }
  _stunning = false;
}

Future stopStunning() async {
  _keepSTUNNING = false;

  while (_stunning) {
    await Future.delayed(Duration(seconds: 10));
  }
  stopQueTimer();
  _socket.close();
  _streamSubscription.cancel();
}
