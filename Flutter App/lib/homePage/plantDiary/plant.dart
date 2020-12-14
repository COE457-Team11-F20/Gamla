import 'dart:ffi';

class Plant {
  final Float temp;
  final int light;
  final int moisture;

  Plant({this.temp, this.light, this.moisture});

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      temp: json['temp'],
      light: json['light'],
      moisture: json['moisture'],
    );
  }
}
