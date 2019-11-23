import 'dart:io';

import "package:stun_dart/stun.dart";

void main() async {
  await initializeStun((Datagram data) {
    print(data.data);
  });
  await initRequest();
}
