import "package:stun_dart/stun.dart";

void main() async {
  await initializeStun((String selfAddress) {
    var response = calculateResponse();
    print(selfAddress);
    print(response.result);
  });
}
