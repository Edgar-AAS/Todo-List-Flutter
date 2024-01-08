import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:todo/entities/item.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Todo App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  //tudo aqui e chama apenas uma vez
  HomePage({super.key});

  var items = <Item>[];

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var taskController = TextEditingController(); //gerencia o texto

  void add() {
    if (taskController.text.isEmpty) return;

    setState(() {
      widget.items.add(
        Item(
          title: taskController.text,
          done: false,
        ),
      );
      saveItems();
      taskController.clear();
    });
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
      saveItems();
    });
  }

  Future loadItems() async {
    var preferences = await SharedPreferences.getInstance();
    var data = preferences.getString('data');

    if (data != null) {
      //Iterable (coluna que permite percorrer ela) (genèrico)
      Iterable decoded = jsonDecode(data);
      List<Item> itemsResult = decoded.map((e) => Item.fromJson(e)).toList();

      setState(() {
        widget.items = itemsResult;
      });
    }
  }

  void saveItems() async {
    var preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      'data',
      jsonEncode(widget.items),
    );
  }

  _HomePageState() {
    loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: taskController,
          keyboardType: TextInputType.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          decoration: const InputDecoration(
              labelText: "Nome Tarefa",
              labelStyle: TextStyle(color: Colors.white)),
        ),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];

          return Dismissible(
            key: Key(item.title ?? ""),
            onDismissed: (direction) {
              remove(index);
            },
            background: Container(
              color: Colors.red.withOpacity(0.3),
            ),
            child: CheckboxListTile(
              title: Text(item.title ?? ""),
              value: item.done,
              onChanged: (value) {
                setState(() {
                  item.done = value;
                  saveItems();
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: add,
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }
}
