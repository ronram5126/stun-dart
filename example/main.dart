import "package:stun_dart/stun.dart";

void main() async {
  int _responseCounter = 0;
  initializeStun(callback: (String selfAddress) {
    var response = calculateResponse();
    print(selfAddress);
    print(response.result);
    print(response.natType);
    _responseCounter++;
  });
  while (_responseCounter < 7) {
    await Future.delayed(Duration(seconds: 2));
  }
  await stopStunning();
}
