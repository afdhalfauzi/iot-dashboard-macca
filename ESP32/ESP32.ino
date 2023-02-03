#include <WiFi.h>
#include <PubSubClient.h>
#include <DHTesp.h>
#include <ESP32Servo.h>

#define ledPIN 2
#define CONNECTION_TIMEOUT 10
#define DHT_PIN 15
#define SERVO_PIN 23

WiFiClient client;
PubSubClient mqtt(client);
DHTesp dhtSensor;
Servo servo;

const char* ssid       = "Wokwi-GUEST";
const char* password   = "";
String mqttBroker = "test.mosquitto.org";

void setup(){
  pinMode(ledPIN, OUTPUT);
  Serial.begin(115200);
  dhtSensor.setup(DHT_PIN, DHTesp::DHT22);
  servo.attach(SERVO_PIN, 500, 2400);
  connectWiFi();
  mqtt.setServer(mqttBroker.c_str(), 1883); //(broker, port)
}

void loop(){
  if(!mqtt.connected()){
    connectMqtt();
  }
  mqtt.loop();
  mqtt.publish("smartHomeMacca/temphum", getTempAndHum().c_str());
  mqtt.setCallback(mqttReceivedMsg);
  delay(500);
}

String getTempAndHum() {
  TempAndHumidity  data = dhtSensor.getTempAndHumidity();
  String temp = String(data.temperature, 0);
  String hum = String(data.humidity, 0);
  Serial.println("Temp: " + temp + "°C");
  Serial.println("Humidity: " + hum + "%");
  Serial.println("---");
  return String(temp+" "+hum);
}

void mqttReceivedMsg(char *topic, byte *msg, unsigned int msgLength){
  String command = "";
  Serial.println(String(topic));

  if (String(topic)== "smartHomeMacca/servo"){
    for (int i = 0; i < msgLength; i++){
      command += String(char(msg[i]));
    }
    Serial.println("Servo is at " + command + " degree");
    int pos = map(command.toInt(), 16, 27, 0, 189);
    servo.write(pos);
  }
}

void connectMqtt(){
  while(!mqtt.connected()){
    Serial.println("Connecting to MQTT ...");
    if(mqtt.connect("smartHomeMacca")){  //id
      mqtt.subscribe("smartHomeMacca/#");  //topic
      Serial.println("MQTT Connected");
    }
  }
}

void connectWiFi(){
  Serial.print("Connecting to WiFI");
  WiFi.begin(ssid, password);
  int timeout_counter = 0;

  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
    timeout_counter++;
    if (timeout_counter >= CONNECTION_TIMEOUT){
      ESP.restart();
    }
  }

  Serial.println("WiFi connected.");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}
