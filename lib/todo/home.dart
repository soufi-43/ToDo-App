import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/auth/login.dart';
import 'package:todoapp/todo/newtodo.dart';
import 'utilities.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseUser _user;

  bool _hasError = false;

  bool _isLoading = true;

  String _errorMessage;

  String _name ;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAuth.instance.currentUser().then((user) {



      Firestore.instance.collection('profiles').where('user_id',isEqualTo: user.uid).getDocuments().then((snapshotQuery){


        setState(() {
          _name = snapshotQuery.documents[0]['name'];

          _user = user;
          _isLoading = false;
          _hasError = false;
        });

      });




    }).catchError((error) {
      setState(() {
        _hasError = true;
        _errorMessage = error.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: _isLoading ?Text('Home') : (_hasError ? _error(context, _errorMessage):Text(_name))  ,
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text('LOGOUT'),
              trailing: Icon(Icons.exit_to_app),
              onTap: () async {
                FirebaseAuth.instance.signOut().then((_) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ));
                });
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _newToDo,
        child: Icon(Icons.add),
      ),
      body: _conTent(context),
    );
  }

  void _newToDo() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => NewToDo()));
  }

  Widget _conTent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: _isLoading
          ? loading(context)
          : (_hasError ? _error(context, _errorMessage) : content(context)),
    );
  }

  Widget content(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection(collections['todos'])
          .where('user_id', isEqualTo: _user.uid)
          .orderBy('done')
          .snapshots(),
      // ignore: missing_return
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return _error(context, 'No connection is made');

            break;
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              return _error(context, snapshot.error.toString());
            }
            if (!snapshot.hasData) {
              return _error(context, 'No Data');
            }

            // ignore: missing_return
            return _drawScreen(context, snapshot.data);

            break;
        }
      },
    );
  }

  Widget loading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
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
        itemBuilder: (BuildContext context, int position) {
          return Card(
            child: ListTile(
              title: Text(
                data.documents[position]['body'],
                style: TextStyle(
                  decoration: data.documents[position]['done']
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              trailing: IconButton(
                onPressed: () {
                  Firestore.instance
                      .collection(collections['todos'])
                      .document(data.documents[position].documentID)
                      .delete();
                },
                icon: Icon(
                  Icons.delete,
                  color: Colors.red.shade300,
                ),
              ),
              leading: IconButton(
                onPressed: () {
                  Firestore.instance
                      .collection(collections['todos'])
                      .document(data.documents[position].documentID)
                      .updateData({
                    'done': true,
                  });
                },
                icon: Icon(
                  Icons.assignment_turned_in,
                  color: data.documents[position]['done']
                      ? Colors.teal
                      : Colors.grey.shade300,
                ),
              ),
            ),
          );
        });
  }
}
