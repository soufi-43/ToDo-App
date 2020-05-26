import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewToDo extends StatefulWidget {
  @override
  _NewToDoState createState() => _NewToDoState();
}

class _NewToDoState extends State<NewToDo> {
  var _key = GlobalKey<FormState>();
  TextEditingController _todoController = TextEditingController();
  bool _autoValidation = false;

  bool _isLoading = false;

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('New ToDo'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveToDo,
        child: Icon(Icons.save),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _isLoading ? _loading(context) : _form(context),
      ),
    );
  }

  Widget _form(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _key,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _todoController,
              autovalidate: _autoValidation,
              decoration: InputDecoration(hintText: 'Enter ToDo'),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Todo Text is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _loading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  void _saveToDo() async {
    if (!_key.currentState.validate()) {
      setState(() {
        _autoValidation = true;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
      FirebaseAuth.instance.currentUser().then((user){
       Firestore.instance.collection('todos').document().setData({
         'body':_todoController.text ,
         'user_id':user.uid,
         'done':false,
       }).then((_){
         Navigator.of(context).pop();
       });
      });

    }
  }
}
