import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

import 'package:syncfusion_flutter_gauges/gauges.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Air Quality Monitoring',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 0, 0, 0)),
        useMaterial3: true,
      ),
      home: MyHomePage(
        title: 'Air Quality Monitoring',
        temp: "0",
        humid: "0",
        co2: "0",
        oxygen: "0",
        updatedAt: "1970-01-01T00:00:00Z",
      ),
    );
  }
}

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  MyHomePage(
      {super.key,
      required this.title,
      this.temp = "0",
      this.humid = "0",
      required this.co2,
      required this.oxygen,
      required this.updatedAt});

  final String title;
  String temp;
  String humid;
  String co2;
  String oxygen;
  String updatedAt;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = true;
  Timer? timer;
  late String createdAt = "";

  Future<void> _getThingspeakData() async {
    try {
      final dio = Dio();
      var result = await dio.get(
          "https://api.thingspeak.com/channels/2777631/feeds.json?api_key=E6N68ACDNJSE7MP8&results=1",
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (result.statusCode == 200) {
        var feeds = (result.data);
        var fields = feeds["feeds"][0];

        setState(() {
          widget.temp = fields["field1"];
        });

        setState(() {
          widget.humid = fields["field2"];
        });

        setState(() {
          widget.co2 = fields["field3"];
        });

        setState(() {
          widget.oxygen = fields["field4"];
        });

        setState(() {
          widget.updatedAt = fields["created_at"];
        });
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _startPolling() {
    timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _getThingspeakData();
    });
  }

  void _stopPolling() {
    timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    _getThingspeakData();
    _startPolling();
  }

  @override
  void dispose() {
    super.dispose();
    _stopPolling();
  }

  @override
  Widget build(BuildContext context) {
    String rawDate = widget.updatedAt;
    DateTime parsedDate = DateTime.parse(rawDate);

    DateTime indonesianTime = parsedDate.add(const Duration(hours: 7));

    String formattedLastUpdatedAt =
        DateFormat('dd-MM-yyyy HH:mm:ss').format(indonesianTime);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    backgroundColor: Colors.blue,
                    color: Color.fromARGB(255, 145, 170, 182),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Loading channel data...',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            : ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Realtime Data',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text('Last updated at : $formattedLastUpdatedAt WIB'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: SfRadialGauge(
                      enableLoadingAnimation: true,
                      axes: <RadialAxis>[
                        RadialAxis(
                          radiusFactor: 0.9,
                          minimum: 0.0,
                          maximum: 50.0,
                          ranges: <GaugeRange>[
                            GaugeRange(
                                startValue: 0.0,
                                endValue: 20.0,
                                color: Colors.blue),
                            GaugeRange(
                                startValue: 20.0,
                                endValue: 35.0,
                                color: Colors.orange),
                            GaugeRange(
                                startValue: 35.0,
                                endValue: 50.0,
                                color: Colors.red),
                          ],
                          pointers: <GaugePointer>[
                            NeedlePointer(value: double.parse(widget.temp)),
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                              widget: Text(
                                "Temperature\n${widget.temp} \u2103",
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              angle: 90,
                              positionFactor: 0.5,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: SfRadialGauge(
                      enableLoadingAnimation: true,
                      axes: <RadialAxis>[
                        RadialAxis(
                          radiusFactor: 0.9,
                          minimum: 0.0,
                          maximum: 100.0,
                          ranges: <GaugeRange>[
                            GaugeRange(
                                startValue: 0.0,
                                endValue: 50.0,
                                color: Colors.blue),
                            GaugeRange(
                                startValue: 50.0,
                                endValue: 75.0,
                                color: Colors.orange),
                            GaugeRange(
                                startValue: 75.0,
                                endValue: 100.0,
                                color: Colors.red),
                          ],
                          pointers: <GaugePointer>[
                            NeedlePointer(value: double.parse(widget.humid)),
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                              widget: Text(
                                "Humidity\n${widget.humid} %",
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              angle: 90,
                              positionFactor: 0.5,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: SfRadialGauge(
                      enableLoadingAnimation: true,
                      axes: <RadialAxis>[
                        RadialAxis(
                          radiusFactor: 0.9,
                          minimum: 0.0,
                          maximum: 5000.0,
                          ranges: <GaugeRange>[
                            GaugeRange(
                                startValue: 0.0,
                                endValue: 1000.0,
                                color: Colors.blue),
                            GaugeRange(
                                startValue: 1000.0,
                                endValue: 2000.0,
                                color: Colors.orange),
                            GaugeRange(
                                startValue: 2000.0,
                                endValue: 5000.0,
                                color: Colors.red),
                          ],
                          pointers: <GaugePointer>[
                            NeedlePointer(value: double.parse(widget.co2)),
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                              widget: Text(
                                "CO2\n${widget.co2} PPM",
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              angle: 90,
                              positionFactor: 0.5,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: SfRadialGauge(
                      enableLoadingAnimation: true,
                      axes: <RadialAxis>[
                        RadialAxis(
                          radiusFactor: 0.9,
                          minimum: 0.0,
                          maximum: 50.0,
                          ranges: <GaugeRange>[
                            GaugeRange(
                                startValue: 0.0,
                                endValue: 20.0,
                                color: Colors.blue),
                            GaugeRange(
                                startValue: 20.0,
                                endValue: 35.0,
                                color: Colors.orange),
                            GaugeRange(
                                startValue: 35.0,
                                endValue: 50.0,
                                color: Colors.red),
                          ],
                          pointers: <GaugePointer>[
                            NeedlePointer(value: double.parse(widget.oxygen)),
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                              widget: Text(
                                "Oxygen (02)\n${widget.oxygen} %",
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              angle: 90,
                              positionFactor: 0.5,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
