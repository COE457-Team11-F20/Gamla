#include <WiFiNINA.h>
#include <ArduinoJson.h>

#define sensorPin A0
#define moisturePin A1
#define lightPin 2

char ssid[] = "Darwin";
char pass[] = "2010audi";

int status = WL_IDLE_STATUS;

char server[] = "192.168.0.193";

//String postData;
String postVariable = "temp=";

DynamicJsonDocument doc(2048);

WiFiClient client;

void setup() {

  Serial.begin(9600);

  while (status != WL_CONNECTED) {
    Serial.print("Attempting to connect to Network named: ");
    Serial.println(ssid);
    status = WiFi.begin(ssid, pass);
    delay(10000);
  }

  Serial.print("SSID: ");
  Serial.println(WiFi.SSID());
  IPAddress ip = WiFi.localIP();
  IPAddress gateway = WiFi.gatewayIP();
  Serial.print("IP Address: ");
  Serial.println(ip);
}

void loop() {
  String postData;
  int reading = analogRead(sensorPin);
  int moist = analogRead(moisturePin);
  int light = digitalRead(lightPin);
  float voltage = reading * 5.0;
  voltage /= 1024.0;
  float temperatureC = (voltage - 0.5) * 100 ;
  float temperatureF = (temperatureC * 9.0 / 5.0) + 32.0;

  String temp = String(temperatureC);
  String temp1 = String(moist);
  String temp2 = String(light);

  doc["temprature"] = temp;
  doc["moisture"] = temp1;
  doc["light"] = temp2;

  
  serializeJson(doc,postData);

  
  if (client.connect(server, 3000)) {
    client.println("POST / HTTP/1.1");
    client.println("Host: 192.168.0.152");
    client.println("Connection: close");
    client.println("Content-Type: application/x-www-form-urlencoded");
    client.print("Content-Length: ");
    client.println(postData.length());
    client.println();
    client.print(postData);
  }

  while(client.available()){
    char c = client.read();
    Serial.print(c);
  }

  if (!client.connected()) {
    client.stop();
  }
  Serial.println(postData);

  delay(3000);
  //postData = "";
}
