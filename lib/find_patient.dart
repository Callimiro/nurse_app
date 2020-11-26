import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nurse_app/login_page.dart';
import 'package:nurse_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';


class FindPatient extends StatefulWidget{
  @override
  _FindPatient createState() => _FindPatient();
}

class _FindPatient extends State<FindPatient>{

  TextEditingController nameController = new TextEditingController();
  createAlertDialog(BuildContext context,String content){
    return showDialog(context: context,builder: (context){
      return AlertDialog(
        title: Text(content),
      );
    });
  }
  find(String name) async{

    String token = sharedPreferences.getString('accessToken');
    print(token);
    var response = await http.get("http://240aedc662a2.ngrok.io/api/auth/patientname/"+name,
        headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer '+token
    });

    createAlertDialog(context,response.body);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: const Text('Find Patient'),
        actions: <Widget>[

          IconButton(
            icon: Icon(Icons.insert_invitation),
            onPressed: (){
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MainPage()),(route) => true);
            },
          ),
          IconButton(
              icon: Icon(Icons.search),
              onPressed: (){

                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => FindPatient()),(route) => true);
              }
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {

              sharedPreferences.setString("accessToken", null);
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()),(route) => true);
            },
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          new Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            margin: EdgeInsets.only(top: 30.0),
            child: new TextField(
              style: TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                hintText: 'Enter Patient Name',
                labelText: 'Patient Name',
              ),
              controller: nameController,
            ),
          ),

          new Container(
            width: MediaQuery.of(context).size.width,
            height: 40.0,
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            margin: EdgeInsets.only(top: 30.0),
            child: RaisedButton(
              onPressed: (){
                find(nameController.text);
               },
                child: Text("Find Patient",style: TextStyle(color: Colors.white70)),
                color: Colors.green,
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
                ),
              )
            ),
        ],
      ),
    );
  }
}