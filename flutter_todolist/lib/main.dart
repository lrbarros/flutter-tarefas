import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _todoList = [{"tittle":"Luiz" ,"ok":true}, {"tittle":"Flutter" ,"ok":true},];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Lista de Tarefas",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
              padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: "Nova Tarefa",
                        labelStyle: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {},
                      child: Text(
                        "ADD",
                        style: TextStyle(color: Colors.white),
                      )),
                ],
              )),
          Expanded(
            child: ListView.builder(
                padding: EdgeInsets.only(top: 10.0),
                itemCount: _todoList.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile (
                    title: Text(_todoList[index]["tittle"]),
                    value: _todoList[index]["ok"],
                    secondary: CircleAvatar(
                        child: Icon((_todoList[index]["ok"]? Icons.check: Icons.error)),
                    ), onChanged: (_todoList [index]["ok"]) async {  },
                  );
                }),
          ),
        ],
      ),
    );
  }

  Future<File> _getFie() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = jsonEncode(_todoList);
    final file = await _getFie();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFie();
      return file.readAsString();
    } catch (e) {
      return e.toString();
    }
  }
}
