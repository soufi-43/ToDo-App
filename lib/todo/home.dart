import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/todo/newtodo.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Home'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _newToDo,
        child: Icon(Icons.add),
      ),
      body: _content(context),
    );
  }

  void _newToDo() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => NewToDo()));
  }

  Widget _content(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: StreamBuilder(
        stream: Firestore.instance.collection('todos').snapshots(),

        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return _error(context, 'No connectionis made');

              break;
            case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator(),);
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              if(snapshot.hasError){
                return _error(context, snapshot.error.toString());

              }
              if(!snapshot.hasData){
                return _error(context, 'No Data');

              }

              // ignore: missing_return
              return _drawScreen(context, snapshot.data);

              break;
          }
        },
      ),
    );
  }

  Widget _error(BuildContext context, String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _drawScreen(BuildContext context, QuerySnapshot data) {
    return ListView.builder(
        itemCount: data.documents.length,
        itemBuilder:(BuildContext context,int position){
          return ListTile(
            title: Text(data.documents[position]['body']),
          );
        });

  }
}