import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

final String serverUri = "test.mosquitto.org";
final int port = 1883;
final String topicName = "plant";

enum MqttCurrentConnectionState {
  IDLE,
  CONNECTING,
  CONNECTED,
  DISCONNECTED,
  ERROR_WHEN_CONNECTING
}

enum MqttSubscriptionState { IDLE, SUBSCRIBED }

class MQTTClientWrapper {
  MqttServerClient client;
  Stream<List<MqttReceivedMessage<MqttMessage>>> updates;

  MQTTClientWrapper() {
    client = MqttServerClient.withPort(serverUri, 'flutter_client', port);
  }

  Future<MqttServerClient> connect() async {
    client.logging(on: true);
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onUnsubscribed = onUnsubscribed;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = onSubscribeFail;
    client.pongCallback = pong;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('Mqtt_spl_id')
        .keepAliveFor(60) // Must agree with the keep alive set above or not set
        .withWillTopic(
            'willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
    }

    client.subscribe("plant", MqttQos.atLeastOnce);
    client.subscribe("plantTempsChart", MqttQos.atLeastOnce);
    client.subscribe("plantMoisturesChart", MqttQos.atLeastOnce);
    client.subscribe("plantLightsChart", MqttQos.atLeastOnce);
    return client;
  }

  void onConnected() {
    print('Connected');
  }

// unconnected
  void onDisconnected() {
    print('Disconnected');
  }

// subscribe to topic succeeded
  void onSubscribed(String topic) {
    print('Subscribed topic: $topic');
  }

// subscribe to topic failed
  void onSubscribeFail(String topic) {
    print('Failed to subscribe $topic');
  }

// unsubscribe succeeded
  void onUnsubscribed(String topic) {
    print('Unsubscribed topic: $topic');
  }

// PING response received
  void pong() {
    print('Ping response client callback invoked');
  }

  void updaaaates() {
    updates = client.updates;
  }

  void subscribeTo(String topic) {
    client.subscribe(topic, MqttQos.atLeastOnce);
  }
}
