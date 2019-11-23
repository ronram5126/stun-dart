import 'dart:async';
import 'dart:io';
import 'package:stun_dart/public_STUN.dart';
import 'package:stun_dart/src/message/message.dart';
import 'package:stun_dart/src/util/constant.dart';
// import 'package:udp/udp.dart';

typedef void DatagramCallback(Datagram data);
StreamSubscription _streamSubscription;
RawDatagramSocket _socket;

Future initializeStun([DatagramCallback callback]) async {
  await RawDatagramSocket.bind(InternetAddress.anyIPv4, 5126)
      .then((sock) => _socket = sock);
  _streamSubscription = _socket.listen((event) {
    if (event == RawSocketEvent.read) {
      if (callback != null) {
        Datagram recievedData = _socket.receive();
        var message = Message.fromBytes(recievedData.data);
        var attributeLength = message.attributes.length;
        print(attributeLength);
        callback(recievedData);
      }
    }
  });
}

Future initRequest() async {
  var data = Message(CLASS_REQUEST, METHOD_BINDING, body: List<int>());
  var byteData = data.toBytes();
  for (int c = 0; c < publicSTUNs.length; c++) {
    var publicSTUN = publicSTUNs[c];
    for (int c1 = 0; c1 < 100; c1++) {
      print(byteData);

      var dataLength =
          await _socket.send(byteData, publicSTUN.address, publicSTUN.port);

      print("${dataLength} bytes sent.");

      await Future.delayed(Duration(seconds: 10));
    }
  }
  ;
}
