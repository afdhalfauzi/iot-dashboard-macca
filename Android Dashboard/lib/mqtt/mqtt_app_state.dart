import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

enum MQTTAppConnectionState { connected, disconnected, connecting }

class MQTTAppState with ChangeNotifier {
  MQTTAppConnectionState _appConnectionState =
      MQTTAppConnectionState.disconnected;
  String _receivedText = '0 0';

  void setReceivedText(String text) {
    _receivedText = text;
    notifyListeners();
  }

  void setAppConnectionState(MQTTAppConnectionState state) {
    _appConnectionState = state;
    notifyListeners();
  }

  String get getReceivedText => _receivedText;
  MQTTAppConnectionState get getAppConnectionState => _appConnectionState;
}
