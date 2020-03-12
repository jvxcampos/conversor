import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = 'https://api.hgbrasil.com/finance';

void main() async {
  runApp(MaterialApp(home: Tela(),
    theme: ThemeData(hintColor: Colors.amber,
    primaryColor: Colors.black
    ),
  ));
}

Future<Map> getData() async
{
  http.Response resposta = await http.get(request);
  return json.decode(resposta.body);
}

class Tela extends StatefulWidget {
  @override
  _TelaState createState() => _TelaState();
}

class _TelaState extends State<Tela> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realChanged(String text){

    if(text.isEmpty) {
      _clearAll();
      return;
    }

    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text){

    if(text.isEmpty) {
      _clearAll();
      return;
    }

    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar*this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text){

    if(text.isEmpty) {
      _clearAll();
      return;
    }

    double euro = double.parse(text);
    realController.text = (euro*this.euro).toStringAsFixed(2);
    dolarController.text = (euro*this.euro/dolar).toStringAsFixed(2);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(" Conversor de Moeda \$"),
        backgroundColor: Colors.amber,
        centerTitle: true ,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          // ignore: missing_return
          builder:(context, snapshot) {
            switch (snapshot.connectionState){
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                    child: Text("Carregando", style: TextStyle(
                    color:  Colors.amber,
                    fontSize: 25.0
                                ),
                textAlign: TextAlign.center)
                );

              default:
                if(snapshot.hasError)
                  {
                    return Center(
                      child:  Text("Erro ao Carregar",
                      style: TextStyle(
                          color:  Colors.amber,
                          fontSize: 25.0
                      ),
                    ));
                  }

                else{
                  dolar = snapshot.data["results"] ["currencies"] ["USD"] ["buy"];
                  euro = snapshot.data["results"] ["currencies"] ["EUR"] ["buy"];

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(Icons.monetization_on, size: 150.0, color: Colors.amber),
                        buildTextField("Reais", "R\$", realController, _realChanged),
                        Divider(),
                        buildTextField("Dólares", "US", dolarController, _dolarChanged),
                        Divider(),
                        buildTextField("Euros", "€", euroController,_euroChanged)
                      ],
                    ),
                  );
                }
            }
          })
    );
  }
}

Widget buildTextField(String moeda, String simb, TextEditingController valores, Function entradas ){
  return TextField(
    controller: valores,
    decoration: InputDecoration(
        labelText: moeda,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: simb
    ),
    style: TextStyle(
        color: Colors.amber, fontSize: 25.0
    ),
    onChanged: entradas,
    keyboardType: TextInputType.number,
  );
}
