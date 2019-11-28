import 'dart:isolate';
import 'package:stun_dart/stun.dart';
import 'src/util/models.dart';

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


getCurrentAddress(address) {
  
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

Future stopSTUNIsolation() async {}
