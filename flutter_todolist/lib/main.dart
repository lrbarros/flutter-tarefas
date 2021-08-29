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
  @override
  void initState() {
    _readData().then((content) {
      setState(() {
        _todoList = json.decode(content);
      });
    });
  }

  final _todoController = TextEditingController();

  List _todoList = [];
  Map<String, dynamic> _todoRemoved = Map();
  int _lastDismiblePos = 0;

  void addTodo() {
    setState(() {
      Map<String, dynamic> newTodo = Map();
      newTodo["title"] = _todoController.text;
      _todoController.text = "";
      newTodo["ok"] = false;
      _todoList.add(newTodo);
      _saveData();
    });
  }
 Future<Null> _refresh() async{
    await Future.delayed(Duration(seconds: 1));
   setState(() {
     _todoList.sort((a,b){
       if(a["ok"] && !b["ok"]){
         return 1;
       }else if(!a["ok"] && b["ok"]){
         return -1;
       }else{
         return 0;
       }
     });
     _saveData();
   });


 }
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
                      controller: _todoController,
                      decoration: InputDecoration(
                        labelText: "Nova Tarefa",
                        labelStyle: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: addTodo,
                      child: Text(
                        "ADD",
                        style: TextStyle(color: Colors.white),
                      )),
                ],
              )),
          Expanded(
            child: RefreshIndicator(child: ListView.builder(
              padding: EdgeInsets.only(top: 10.0),
              itemCount: _todoList.length,
              itemBuilder: buildItem,
            ), onRefresh: _refresh,)
          ),
        ],
      ),
    );
  }

  Widget buildItem(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_todoList[index]["title"]),
        value: _todoList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon((_todoList[index]["ok"] ? Icons.check : Icons.error)),
        ),
        onChanged: (c) {
          setState(() {
            _todoList[index]["ok"] = c;
            _saveData();
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _todoRemoved = Map.from(_todoList[index]);
          _lastDismiblePos = index;
          _todoList.removeAt(index);
          _saveData();
        });

        final snack = SnackBar(
          content: Text("Tarefa \" ${_todoRemoved["title"]}\" removida"),
          action: SnackBarAction(label: "Desfazer", onPressed: () {
            setState(() {
              _todoList.insert(_lastDismiblePos, _todoRemoved);
            });
          }),
          duration: Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(snack);
      },
    );
  }

  /* */

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
