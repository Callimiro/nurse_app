import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nurse_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  SharedPreferences sharedPreferences ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.lightBlue,
            Colors.tealAccent
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter
          ),
        ),
          child: _isLoading ? Center(child: CircularProgressIndicator()): ListView(
        children: <Widget>[
          headerSection(),
          textSection(),
          buttonSection()
        ],
      ),
      ),
    );
  }
  singIn(String email,password) async{

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var response = await http.post("http://240aedc662a2.ngrok.io/api/auth/signin",
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },body: json.encode(<String, String>{
          'username':email,
          'password':password
          }));
    var jsonData;
    print(response.body);
    jsonData = json.decode(response.body);
    var role = jsonData['roles'];
    if(response.statusCode == 200 && role.toString() == "[ROLE_NURSE]"){
      setState(() {
        _isLoading = false;
      });
      sharedPreferences.setString("accessToken", jsonData['accessToken']);
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MainPage()),(route) => false);

    }else{
      setState(() {
        _isLoading = false;
      });
      sharedPreferences.setString("accessToken", null);
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MainPage()),(route) => true);
      print(response.body);
    }
  }
  Container buttonSection(){
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      margin: EdgeInsets.only(top: 30.0),
      child: RaisedButton(
        onPressed: (){
          setState(() {
            _isLoading = true;
          });
          singIn(emailController.text, passwordController.text);
        },
        child: Text("Sign In",style: TextStyle(color: Colors.white70)),
        color: Colors.purple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
      )
    );
  }
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  Container textSection(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      margin: EdgeInsets.only(top: 30.0),
      child: Column(
        children: <Widget>[
          textEmail("Email",Icons.email),
          SizedBox(height: 30.0,),
          textPassword("Password",Icons.lock),
        ],
      ),
    );
  }

  TextFormField textEmail(String title,IconData icon){
    return TextFormField(
      controller: emailController,
      style: TextStyle(color: Colors.white70),
      decoration: InputDecoration(
        hintText: title,
        hintStyle: TextStyle(color: Colors.white70),
        icon: Icon(icon)

    ),
    );
  }

  TextFormField textPassword(String title,IconData icon){
    return TextFormField(
      controller: passwordController,
      obscureText: true,
      style: TextStyle(color: Colors.white70),
      decoration: InputDecoration(
          hintText: title,
          hintStyle: TextStyle(color: Colors.white70),
          icon: Icon(icon)

      ),
    );
  }
  Container headerSection(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Text("Nurse Login",style: TextStyle(color: Colors.white),),
    );
  }
}
