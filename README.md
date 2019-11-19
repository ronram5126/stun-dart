# STUN Dart
Simple plug and play stun client for dart, with configurable predefined list of public stun. It can be started in isolation with refresh interval to maintain the STUN infomation and raise onChanged event if something changes.
A composable, Future-based library for making HTTP requests.

## Using

This is a bare minimum stun client useful for further establishing peer-to-peer connection between two different clients.

```dart
```

You can also isolate the process. It will automatically maintain the detail regarding how to establish peer to peer connection.

```dart
```

When unconfigured this package use different public stun server. It is recommended that you provide more than one stun server to account for any errors and downtime.
```dart
```
