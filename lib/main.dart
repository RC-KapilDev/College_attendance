import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'scanner.dart';
import 'package:http/http.dart' as http;

var kColorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF6851a5));
var kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 5, 99, 125),
);
void main() {
  runApp(const qrGenerator());
}

class qrGenerator extends StatelessWidget {
  const qrGenerator({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: kColorScheme,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true)
          .copyWith(colorScheme: kDarkColorScheme),
      title: 'QR Code from JSON',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var jsonContent = '';

  Future<void> fetchDataFromAPI() async {
    final response = await http.get(Uri.parse(
        'http://192.168.1.6:3000/api/data')); // Replace with your API endpoint

    if (response.statusCode == 200) {
      final jsonData = response.body;
      setState(() {
        jsonContent = jsonData;
      });
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDataFromAPI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Student Detail'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SfBarcodeGenerator(
              value: jsonContent,
              symbology: QRCode(),
            ),
            const SizedBox(height: 20.0),
            const Text('Scan the QR code '),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Scanner()),
                );
              },
              child: const Text('Scanner'),
            ),
          ],
        ),
      ),
    );
  }
}
