import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mqtt/mqtt_app_state.dart';
import 'mqtt/mqtt_manager.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  get screenHeight =>
      MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
  int sliderValue = 27;
  List<String> receivedMsg = ["0", "0"];

  void initState() {
    Future.delayed(Duration.zero).then((value) {
      _connectMQTT('smartHomeMacca/temphum');
    });
    super.initState();
  }

  late MQTTAppState currentAppState;
  late MQTTManager manager;

  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    currentAppState = appState;
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 242, 251, 251),
        appBar: AppBar(
          //   title: Text(widget.title),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              children: [
                Text('Smart Home',
                    style: TextStyle(
                        fontSize: screenHeight * 0.032,
                        fontWeight: FontWeight.bold)),
                Text('Living room',
                    style: TextStyle(
                        fontSize: screenHeight * 0.018, color: Colors.black45)),
              ],
            ),
            SizedBox(
              height: screenHeight * 0.5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [_buildTemperatureColumn(), _buildHumidityColumn()],
              ),
            ),
            Container(
              color: Colors.white,
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('Adjust Temperature',
                      style: TextStyle(
                          fontSize: screenHeight * 0.018, color: Colors.black)),
                  Text('$sliderValue°c',
                      style: TextStyle(
                          fontSize: screenHeight * 0.07, color: Colors.black)),
                  SliderTheme(
                    data: SliderThemeData(
                        activeTrackColor: Colors.blue,
                        inactiveTrackColor: Colors.black12),
                    child: Container(
                        child: Slider(
                      min: 16,
                      max: 30,
                      value: sliderValue.toDouble(),
                      onChanged: ((value) {
                        setState(() {
                          sliderValue = value.toInt();
                          if (currentAppState.getAppConnectionState ==
                              MQTTAppConnectionState.connected) {
                            _publishMessage('smartHomeMacca/servo',
                                sliderValue.round().toString());
                          } else {}
                        });
                      }),
                    )),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 150,
            ),
            (currentAppState.getAppConnectionState ==
                    MQTTAppConnectionState.connected)
                ? Text(
                    "Connected",
                    style:
                        TextStyle(backgroundColor: Colors.green, fontSize: 25),
                  )
                : Text("Disconnect",
                    style:
                        TextStyle(backgroundColor: Colors.red, fontSize: 25)),
          ],
        )));
  }

  Widget _buildTemperatureColumn() {
    if (currentAppState.getAppConnectionState ==
        MQTTAppConnectionState.connected) {
      receivedMsg = currentAppState.getReceivedText.split(" ");
    } else {
      receivedMsg = ["0", "0"];
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(receivedMsg[0] + '°c',
            style:
                TextStyle(fontSize: screenHeight * 0.07, color: Colors.black)),
        Text('Temperature',
            style: TextStyle(
                fontSize: screenHeight * 0.018, color: Colors.black45)),
      ],
    );
  }

  Widget _buildHumidityColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(receivedMsg[1] + '⁒',
            style:
                TextStyle(fontSize: screenHeight * 0.07, color: Colors.black)),
        Text('Humidity',
            style: TextStyle(
                fontSize: screenHeight * 0.018, color: Colors.black45)),
      ],
    );
  }

////////////////
//MQTT UTILITY//
////////////////
  void _connectMQTT(String topic) {
    manager = MQTTManager(topic: topic, state: currentAppState);
    manager.initializeMQTTClient();
    manager.connect();
  }

  void _disconnectMQTT() {
    manager.disconnect();
  }

  void _publishMessage(String topic, String text) {
    final String message = text;
    manager.publish(topic, message);
  }
}
