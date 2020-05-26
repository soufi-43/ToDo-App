import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/auth/login.dart';
import 'package:todoapp/todo/home.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  bool _autoValidation = false;
  String _error;

  bool _isLoading = false;

  var _key = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        centerTitle: true,
        title: Text('Register New Account'),
      ),
      body: _isLoading ? _loading(context) : _form(context),
    );
  }

  Widget _form(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Form(
          autovalidate: _autoValidation,
          key: _key,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(hintText: 'Email'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Email is Required';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 24,
              ),
              TextFormField(
                obscureText: true,
                controller: _passwordController,
                decoration: InputDecoration(hintText: 'Password'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Password is Required';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 24,
              ),
              TextFormField(
                obscureText: true,
                controller: _confirmPasswordController,
                decoration: InputDecoration(hintText: 'Confirm Password'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'confirmation of password is Required';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 36,
              ),
              Container(
                width: double.infinity,
                child: RaisedButton(
                  onPressed: _onRegisterClick,
                  child: Text('Register'),
                ),
              ),
              SizedBox(
                height: 36,
              ),
              _errorMessage(context),
              Row(
                children: <Widget>[
                  Text('Have an account?'),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ),
                      );
                    },
                    child: Text('Login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  void _onRegisterClick() async {
    if (!_key.currentState.validate()) {
      setState(() {
        _autoValidation = true;
      });
    } else {
      setState(() {
        _isLoading = true;
        _autoValidation = false;
      });

      AuthResult result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text);

      if (result.user == null) {
        setState(() {
          _isLoading = false ;
          _error = 'User registration error';
        });
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      }
    }
  }

  Widget _errorMessage(BuildContext context) {
    if (_error == null) {
      return Container();
    }
    return Container(
      child: Text(
        _error,
        style: TextStyle(
          color: Colors.red,
        ),
      ),
    );
  }
}
