import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'edit_contact.dart';
import '../Model/contact.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class ViewContact extends StatefulWidget {

  final String id;
  ViewContact(this.id);

  @override
  _ViewContactState createState() => _ViewContactState(id);
}

class _ViewContactState extends State<ViewContact> {

  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();
  String id;
  _ViewContactState(this.id);
  Contact _contact;
  bool isLoading = false;
  String rua = "";
  String cidade = "";
  getContact(id) async{
    _databaseReference.child(id).onValue.listen((event){
      setState(() {
        _contact = Contact.fromSnapshot(event.snapshot);
      });
    });
  }


  @override
  void initState(){
    super.initState();
    this.getContact(id);
  }

  callAction(String number) async{
    String url = "tel:${number}";
    if(await canLaunch(url)){
      await launch(url);
    }else{
      throw 'Could not call ${number}';
    }
  }

  smsAction(String number) async{
    String url = "sms:${number}";
    if(await canLaunch(url)){
      await launch(url);
    }else{
      throw 'Could not send sms to ${number}';
    }
  }

  navigateToEditScreen(id){
    Navigator.push(context, MaterialPageRoute(builder: (context){
      return EditContact(id);
    }));
  }

  navigateToLastScreen(){
    Navigator.pop(context);
  }

  deleteContact(){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text("Delete"),
          content: Text("Do you really want to delete?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Delete"),
              onPressed: () async{
                Navigator.of(context).pop();
                await _databaseReference.child(id).remove();
                navigateToLastScreen();
              },
            )
          ],
        );
      }
    );
  }

@override
  Widget build(BuildContext context) {
    // wrap screen in WillPopScreen widget
    return Scaffold(
      backgroundColor: Color(0xFFDAE0E2),
      appBar: AppBar(
        backgroundColor: Color(0xFF30336B),
        title: Text("View Contact"),
      ),
      body: Container(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                children: <Widget>[
                  // header text container
                  Container(
                      height: 200.0,
                      child: Image(
                        //
                        image: (_contact == null || (_contact.photoUrl == "empty" || _contact.photoUrl == null))
                            ? AssetImage("assets/logo.png")
                            : Image.memory(base64Decode(_contact.photoUrl)).image,
                        fit: BoxFit.contain,
                      )),
                  //name
                  Card(
                    elevation: 2.0,
                    child: Container(
                        margin: EdgeInsets.all(20.0),
                        width: double.maxFinite,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.perm_identity),
                            Container(
                              width: 10.0,
                            ),
                            Text(
                              "${_contact.firstName} ${_contact.lastName}",
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ],
                        )),
                  ),
                  Card(elevation: 2.0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(50, 20, 50, 50),
                    child: Column(


                      children: <Widget>[
                        Text(
                          "Aniversário salvo:",
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          "${_contact.birthday}",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),

                      ],
                    ),
                    )
                  ),
                  // phone
                  Card(
                    elevation: 2.0,
                    child: Container(
                        margin: EdgeInsets.all(20.0),
                        width: double.maxFinite,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.phone),
                            Container(
                              width: 10.0,
                            ),
                            Text(
                              _contact.phone,
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ],
                        )),
                  ),
                  // email
                  Card(
                    elevation: 2.0,
                    child: Container(
                        margin: EdgeInsets.all(20.0),
                        width: double.maxFinite,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.email),
                            Container(
                              width: 10.0,
                            ),
                            Text(
                              _contact.email,
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ],
                        )),
                  ),
                  // address
                  Card(
                    elevation: 2.0,
                    child: Container(
                        margin: EdgeInsets.all(20.0),
                        width: double.maxFinite,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.home),
                            Container(
                              width: 10.0,
                            ),
                            Text(
                              _contact.address,
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ],
                        )),
                  ),
                  // call and sms
                  Card(
                    elevation: 10.0,
                    child: Container(
                        margin: EdgeInsets.all(20.0),
                        width: double.maxFinite,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            IconButton(
                              iconSize: 30.0,
                              icon: Icon(Icons.phone),
                              color: Colors.blue,
                              onPressed: () {
                                callAction(_contact.phone);
                              },
                            ),
                            IconButton(
                              iconSize: 30.0,
                              icon: Icon(Icons.message),
                              color: Colors.blue,
                              onPressed: () {
                                smsAction(_contact.phone);
                              },
                            ),
                            IconButton(
                              iconSize: 30.0,
                              icon: Icon(Icons.edit),
                              color: Colors.blue,
                              onPressed: () {
                                navigateToEditScreen(id);
                              },
                            ),
                            IconButton(
                              iconSize: 30.0,
                              icon: Icon(Icons.delete),
                              color: Colors.blue,
                              onPressed: () {
                                deleteContact();
                              },
                            )
                          ],
                        )),
                  ),
                ],
              ),
      ),
    );
  }
  Future<http.Response> pesquisarCep(String cep) async {
    return http.get('https://viacep.com.br/ws/$cep/json/');
  }
  void armazenarDados() async {
    //sair se o cep estiver vazio
    if (_contact.address == "") return;

    http.Response jsonCru = await pesquisarCep(_contact.address);

    //erro na api
    if (jsonCru.statusCode != 200) return;

    Map<String, dynamic> mapa = jsonDecode(jsonCru.body);

    rua = mapa['logradouro'];
    cidade = mapa['localidade'];
  }

}
