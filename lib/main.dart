import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const _url = "https://api.hgbrasil.com/finance?format=json&key=6b741c84";
void main() async {
  //print(await getData());

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

//requisição do servidor que vai retornar em algum momento
//é um dado que vai me retornar no Futuro
Future<Map> getData() async {
  http.Response response = await http.get(_url);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final btcController = TextEditingController();

  double dolar;
  double btc;

  void _realChanged(String text) {
    double real = double.parse(text);

    dolarController.text = (real / dolar).toStringAsFixed(2);
    btcController.text = (real / btc).toStringAsFixed(4);
  }

  void _dolarChanged(String text) {
    double dolar = double.parse(text);

    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    btcController.text = (dolar * this.dolar / btc).toStringAsFixed(4);
  }

  void _btcChanged(String text) {
    double btc = double.parse(text);

    realController.text = (btc * this.btc).toStringAsFixed(2);
    dolarController.text = (btc * this.btc / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return buildRequestMessage("Carregando dados...");
              default:
                if (snapshot.hasError) {
                  return buildRequestMessage("Erro ao carregar dados!");
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  btc = snapshot.data["results"]["bitcoin"]["mercadobitcoin"]
                      ["last"];

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(Icons.monetization_on,
                            size: 150.0, color: Colors.amber),
                        buildTextField(
                            "Reais", "R\$", realController, _realChanged),
                        Divider(),
                        buildTextField(
                            "Bitcoin", "₿", btcController, _btcChanged),
                        Divider(),
                        buildTextField(
                            "Dólares", "US\$", dolarController, _dolarChanged),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function func) {
  return TextField(
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    controller: controller,
    onChanged: func,
    keyboardType: TextInputType.number,
  );
}

Widget buildRequestMessage(String label) {
  return Center(
      child: Text(
    label,
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    textAlign: TextAlign.center,
  ));
}
