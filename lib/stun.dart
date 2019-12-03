import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:stun_dart/public_STUN.dart';
import 'package:stun_dart/src/message/attributes/attributes.dart';
import 'package:stun_dart/src/message/attributes/change_address.dart';
import 'package:stun_dart/src/message/attributes/changed_address.dart';
import 'package:stun_dart/src/message/attributes/default_attribute.dart';
import 'package:stun_dart/src/message/attributes/xaddress.dart';
import 'package:stun_dart/src/message/message.dart';
import 'package:stun_dart/src/util/constant.dart';
import 'package:stun_dart/src/util/exceptions.dart';
import 'package:stun_dart/src/util/models.dart';

StreamSubscription _streamSubscription;
RawDatagramSocket _socket;
bool _keepSTUNNING;
bool _stunning;
NATType currentNatType = NATType.Unknown;
Timer queCheck;

final UnknownAddressResult =
    () => new RespondedData(DateTime.now(), "NA", NATType.Unknown);
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
  NATType repondedNatType = responses[0].natType;
  for (int c = 1; c < responses.length; c++) {
    String _responseResult = responses[c].result;
    DateTime _respondedTime = responses[c].lastRecieved;
    NATType _repondedNATType = responses[c].natType;
    if (responseResult != _responseResult) {
      return UnknownAddressResult();
    }

    if (respondedTime.difference(_respondedTime).inMilliseconds < 0) {
      respondedTime = _respondedTime;
    }

    if (natMap[_repondedNATType] > natMap[repondedNatType]) {
      repondedNatType = _repondedNATType;
    }
  }

  return RespondedData(respondedTime, responseResult, repondedNatType);
}

Future initializeStun({StunCallback callback, RawDatagramSocket socket}) async {
  if (socket == null) {
    await RawDatagramSocket.bind(InternetAddress.anyIPv4, 5126)
        .then((sock) => _socket = sock);
  } else {
    _socket = socket;
  }

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
        XAddress xAddress;
        ChangedAddress changedAddress;
        for (int c = 0; c < attributes.length; c++) {
          var tlvAttribute = attributes[c];
          if (tlvAttribute.type == ATTRIBUTE_XOR_MAPPED_ADDRESS) {
            xAddress = tlvAttribute.attribute;
          } else if (tlvAttribute.type == ATTRIBUTE_CHANGED_ADDRESS) {
            changedAddress = tlvAttribute.attribute;
          }
        }
        if (xAddress != null) {
          String selfAddress =
              '${xAddress.getNetAddress().address}:${xAddress.actualPort}';
          NATType natType = NATType.Unknown;
          if (changedAddress == null) {
            natType = NATType.Connected;
          } else {
            var changedAddressNet = changedAddress.getNetAddress();
            var changedAddressPort = changedAddress.port;
            var recievedAddress = recievedData.address;
            var recievedAddressPort = recievedData.port;

            if (changedAddressNet.address != recievedAddress.address) {
              natType = NATType.AnyIP;
            } else if (changedAddressPort != recievedAddressPort) {
              natType = NATType.AnyPort;
            } else {
              throw InvalidEncoding(
                  "Recieved Changed attribute, with same ip and port address.");
            }
          }

          addResponse(recievedFrom, selfAddress, natType);
          if (callback != null) {
            callback(selfAddress);
          }
        }
      }
    }
  });

  initQueTimer();
  await initRequest();
}

void addResponse(String recievedFrom, String selfAddress, NATType natType) {
  for (int c = 0; c < responses.length; c++) {
    var response = responses[c];
    if (response.from == recievedFrom) {
      responses.remove(response);
      c--;
    }
  }

  responses.add(new RespondedFromData(
      recievedFrom, DateTime.now(), selfAddress, natType));
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
    for (int c = 0; c < messages.length; c++) {
      var message = messages[c];

      if (DateTime.now().difference(message.dateTime).inSeconds >
          TIMEOUT_SECONDS) {
        messages.remove(message);
      }

      c--;
    }
  });
}

Future initRequest() async {
  messages.clear();
  responses.clear();

  _keepSTUNNING = true;
  _stunning = true;
  while (_keepSTUNNING) {
    for (int c2 = 0; c2 < publicSTUNs.length; c2++) {
      var _messages = getCurrentMessages();
      for (int c3 = 0; c3 < _messages.length; c3++) {
        var message = _messages[c3];
        messages.add(TimedMessage(DateTime.now(), message));

        var byteData = message.toBytes();
        var publicSTUN = publicSTUNs[c2];

        await _socket.send(byteData, publicSTUN.address, publicSTUN.port);
        await Future.delayed(Duration(seconds: 1));
      }
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

List<Message> getCurrentMessages() {
  return [
    Message(CLASS_REQUEST, METHOD_BINDING, body: List<int>()),
    Message(CLASS_REQUEST, METHOD_BINDING,
        body: List<int>(),
        attributes: Attributes()
          ..add(Attribute.fromAttribute(
              ATTRIBUTE_CHANGE_ADDRESS, ChangeAddress(false, true)))),
    Message(CLASS_REQUEST, METHOD_BINDING,
        body: List<int>(),
        attributes: Attributes()
          ..add(Attribute.fromAttribute(
              ATTRIBUTE_CHANGE_ADDRESS, ChangeAddress(true, true))))
  ];
}
