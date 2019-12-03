import "package:stun_dart/stun.dart";

void main() async {
  await initializeStun(callback: (String selfAddress) {
    var response = calculateResponse();
    print(selfAddress);
    print(response.result);
    print(response.natType);
  });
}
