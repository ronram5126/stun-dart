import 'dart:isolate';
import 'package:stun_dart/src/util/models.dart';
import 'package:stun_dart/stun.dart';

const int _TIMEOUT = 10;

Map<String, DateTime> lastUpdated = new Map<String, DateTime>();
RespondedData currentAddress;
ReceivePort receivePort;
SendPort sendPort;
Isolate currentIsolate;

void handlePortCall(data) {
  if (data != null && data is Map)
    switch (data["method"]) {
      case "register":
        sendPort = data["port"];
        break;

      case "getCurrentAddress":
        var response = calculateResponse();
        sendPort.send({"method": "setCurrentAddress", "address": response});
        break;
      case "setCurrentAddress":
        currentAddress = data["address"];
        lastUpdated["currentAddress"] = DateTime.now();
        break;

      case "killswitch":
        stopSTUNIsolation().then((d) => sendPort.send({"method": "killed"}));
        break;

      case "killed":
        lastUpdated["killed"] = DateTime.now();
        break;
    }
}

getCurrentAddress(address) async {
  var lastSet = lastUpdated["currentAddress"];
  sendPort.send({"method": "getCurrentAddress"});
  int timeout = _TIMEOUT;
  while ((lastSet == null && lastUpdated is DateTime) ||
      (lastUpdated["currentAddress"].difference(lastSet).inMilliseconds < 0)) {
    await Future.delayed(Duration(seconds: 1));

    timeout--;

    if (timeout < 0) {
      throw Exception("Timeout");
    }
  }

  return currentAddress;
}

void initRecievedPort() {
  if (receivePort != null) {
    receivePort.close();
  }
  receivePort = new ReceivePort();
  receivePort.listen(handlePortCall);
}

Future initSTUNIsolately() async {
  currentIsolate = await Isolate.spawn((SendPort _sendPort) {
    sendPort = _sendPort;

    initRecievedPort();
    sendPort.send({"method": "register", "port": receivePort.sendPort});

    initializeStun((data) {
      sendPort.send(
          {"method": "setCurrentAddress", "address": calculateResponse()});
    });
  }, receivePort.sendPort);
}

Future stopSTUNIsolation() async {
  var lastSet = lastUpdated["killed"];
  sendPort.send({"method": "getCurrentAddress"});
  var timeout = _TIMEOUT;

  while ((lastSet == null && lastUpdated is DateTime) ||
      (lastUpdated["currentAddress"].difference(lastSet).inMilliseconds < 0)) {
    await Future.delayed(Duration(seconds: 1));

    timeout--;

    if (timeout < 0) {
      throw Exception("Timeout");
    }
  }
}
