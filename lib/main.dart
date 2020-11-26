import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nurse_app/find_patient.dart';
import 'package:nurse_app/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nurse APP',
      theme: ThemeData(
        // This is the theme of your application.
        //
        accentColor: Colors.white70,
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MainPage(title: 'Nurse App'),
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MainPageState createState() => _MainPageState();
}
SharedPreferences sharedPreferences ;
class _MainPageState extends State<MainPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final List<String> _injuries = <String>["general","Intergast","Orl","Cardio"];
  final List<int> _sevirities = <int>[1,2,3,4,5];
  TextEditingController nameController = new TextEditingController();
  TextEditingController summaryController = new TextEditingController();
  String _injury = "general";
  String _name = null;
  String _summary = null;
  int _sevirity = 1;

  void initState(){
    super.initState();
    CheckLoginStatus();
    nameController.addListener(() {
      _name = nameController.text;
    });
    summaryController.addListener(() {
      _summary = summaryController.text;
    });
  }
  CheckLoginStatus() async{
    sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString('accessToken');

    if(token == null){
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()),(route) => false);
    }

  }
  schedulePatient(String pname,int injurity,int sevirity,String summary) async{
    String token = sharedPreferences.getString('accessToken');
    print("the summary is : "+summary);
    var response = await http.post("http://240aedc662a2.ngrok.io/auth/sch_req",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer '+token
        },body: json.encode({
          'patientName':pname,
          'injurityLevel':injurity,
          'sevirityIndex':sevirity,
          'nurse_summary':summary
        }));
      var jsonData;
      if(response.statusCode ==200 ){
         var res = await http.get("http://240aedc662a2.ngrok.io/affectation/"+pname,headers: <String, String>{
           'Content-Type': 'application/json; charset=UTF-8',
           'Authorization': 'Bearer '+token
         });
         jsonData = json.decode(res.body);
         print(jsonData);
         print(res.statusCode);
         if(res.statusCode == 200){
           createAlertDialog(context,jsonData.toString());
         }else{
           createAlertDialog(context,jsonData.toString()+" status code :"+res.statusCode.toString());
         }

      }else{
        jsonData = json.decode(response.body);
        createAlertDialog(context,jsonData.toString()+" status code :"+response.statusCode.toString());
      }
  }

  createAlertDialog(BuildContext context,String content){
    return showDialog(context: context,builder: (context){
      return AlertDialog(
        title: Text(content),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: const Text('ADD new Patient'),
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
      body: new Form(
        key: _formKey,
        autovalidate: true,

        child: new ListView(
          children: <Widget>[

            new Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              margin: EdgeInsets.only(top: 30.0),
              child: new TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Enter Patient Name',
                  labelText: 'Patient Name',
                ),
                controller: nameController,
                onChanged: (value) {
                  _name = value;
                  setState(() {
                    nameController.addListener(() {
                      _name = nameController.text;
                    });
                  });
                },
              ),
            ),
            new Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: new FormField(
                builder: (FormFieldState state){
                  SizedBox(height: 30.0);
                  return InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Injury Type',
                      ),
                      isEmpty: _injury == '',
                      child: new DropdownButtonHideUnderline(

                        child: new DropdownButton(
                          isDense: true,
                          items: _injuries.map((String item) =>
                              DropdownMenuItem<String>(child: Text(item), value: item)).toList(),
                          onChanged: (String value){
                            setState(() {
                              this._injury = value;
                            });
                          },
                          value: _injury,
                        ),

                      )
                  );
                },
              ),
            ),

            new Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child:new FormField(
              builder: (FormFieldState state){
                return InputDecorator(
                    decoration: InputDecoration(
                        labelText: 'Sevirity index'
                    ),
                    isEmpty: _sevirity == '',
                    child: new DropdownButtonHideUnderline(
                      child: new DropdownButton(
                        isDense: true,
                        items: _sevirities.map((int item) =>
                            DropdownMenuItem<int>(child: Text(item.toString()), value: item)).toList(),
                        onChanged: (int value){
                          setState(() {
                            this._sevirity = value;
                          });
                        },
                        value: _sevirity,
                      ),

                    )
                );
              },
              )
            ),
            new Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: new TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Enter additional information',
                  labelText: 'Nurse Summary',
                ),
                controller: summaryController,
                onChanged: (value) {
                  _summary = value;
                  setState(() {
                    summaryController.addListener(() {
                      _summary = summaryController.text;
                    });
                  });
                },
              ),
            ),

            new Container(
              width: MediaQuery.of(context).size.width,
              height: 40.0,
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              margin: EdgeInsets.only(top: 30.0),
              child: RaisedButton(
                  child: const Text('Submit'),
                  onPressed: (){
                    _name = nameController.text;
                    _summary = summaryController.text;
                    int _injurity;
                    switch(_injury){
                      case "general":
                        _injurity = 1;
                        break;
                      case "Intergast":
                        _injurity = 2;
                        break;
                      case "Orl":
                        _injurity = 3;
                        break;
                      case "Cardio":
                        _injurity = 4;
                        break;
                    }
                    schedulePatient(_name,_injurity,_sevirity,_summary);
                  }
              ),
            )
          ],
        ),
      ),
    );

  }

}