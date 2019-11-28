import "package:stun_dart/stun.dart";

void main() async {
  await initializeStun((String selfAddress) {
    print(selfAddress);
  });
}
