import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../Model/contact.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:async/async.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
class AddContact extends StatefulWidget {
  @override
  _AddContactState createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {

  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();

  String _firstName = '';
  String _lastName = '';
  String _photoUrl = 'empty';
  String _email = '';
  String _address = '';
  String _phone = '';
  String _houseNumber = '';
  String _streetNumber = '';
  String _birthday = '';
  String rua = "";
  String cidade = "";
  /// Which holds the selected date
  /// Defaults to today's date.
  DateTime selectedDate = DateTime.now();



  saveContact(BuildContext context) async {
    if(
      _firstName.isNotEmpty && _lastName.isNotEmpty && _phone.isNotEmpty && _email.isNotEmpty && 
      _address.isNotEmpty
    ){
      _birthday = DateFormat('yyyy-MM-dd - kk:mm').format(selectedDate);
      Contact contact = Contact(this._firstName,this._lastName,this._phone,
          this._email,this._address,this._photoUrl, this._houseNumber, this._streetNumber, this._birthday);

      //inserir no banco de dados
      await _databaseReference.push().set(contact.toJson());
      navigateToLastScreen(context);
    } else {
      showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Campos vazios"),
            content: Text("Por favor, preencha todos os campos"),
            actions: <Widget>[
              FlatButton(
                child: Text("Ok"),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        } 
      );
    }
  }

  navigateToLastScreen(context){
    Navigator.of(context).pop();
  }



  Future pickImage() async{
    File file = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 200.0,
      maxWidth: 200.0
    );

    uploadImage(file);
  }

  void uploadImage(File file) async{
    final bytes = await file.readAsBytes();
    String convertida = base64Encode(bytes);
    this._photoUrl = convertida;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAF0F1),
      appBar: AppBar(
        backgroundColor: Color(0xFF30336B),
        title: Text("Adicionar contato"),
      ),
      body: Container(
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: ListView(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 5.0),
                child: GestureDetector(
                  onTap: (){
                    this.pickImage();
                  },
                  child: Center(
                    child: Container(
                      width: 150.0,
                      height: 150.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: _photoUrl == "empty"
                          ? AssetImage("assets/logo.png")
                          : Image.memory(base64Decode(_photoUrl)),
                        )
                      ),
                    ),
                  ),
                )
              ),
              Container(
                margin: EdgeInsets.only(top:10.0),
                child: TextField(
                  textAlign: TextAlign.center,
                  onChanged: (value){
                    setState(() {
                      _firstName = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Primeiro nome',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top:10.0),
                child: TextField(
                  textAlign: TextAlign.center,
                  onChanged: (value){
                    setState(() {
                      _lastName = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Segundo nome',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),

                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top:10.0),
                child: TextField(
                  textAlign: TextAlign.center,
                  onChanged: (value){
                    setState(() {
                      _phone = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Telefone',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),

                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top:10.0),
                child: TextField(
                  textAlign: TextAlign.center,
                  onChanged: (value){
                    setState(() {
                      _email = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),

                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top:10.0),
                child: TextField(
                  textAlign: TextAlign.center,
                  onChanged: (value){
                    setState(() {
                      _address = value;
                    });
                    armazenarDados();
                  },
                  decoration: InputDecoration(
                    labelText: 'Cep',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top:10.0),
                child: TextField(
                  textAlign: TextAlign.center,
                  onChanged: (value){
                    setState(() {
                      _streetNumber = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Número',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top:10.0),
                child: TextField(
                  textAlign: TextAlign.center,
                  onChanged: (value){
                    setState(() {
                      _houseNumber = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Complemento',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top:10.0),
                child: Text("Sua rua: ${rua}\nSua cidade: ${cidade}",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),)
              ),
              Container(
                padding: EdgeInsets.fromLTRB(50, 20, 50, 50),
                child: Column(


                  children: <Widget>[
                    Text(
                      "Aniversário salvo:",
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      "${selectedDate.toLocal()}".split(' ')[0],
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    RaisedButton(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      onPressed: () => _selectDate(context), // Refer step 3
                      child: Text(
                        'Editar aniversário',
                        style:
                        TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      color: Colors.greenAccent,
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.fromLTRB(50, 10, 50, 10),
                child: RaisedButton(
                  padding: EdgeInsets.fromLTRB(100, 20, 100, 20),
                  color: Colors.black,
                  child: Text('Salvar', style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0
                  ),),
                  onPressed: (){
                    saveContact(context);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(1900),
      lastDate: DateTime(2022),
      initialDatePickerMode: DatePickerMode.year,

    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Future<http.Response> pesquisarCep(String cep) async {
    return http.get('https://viacep.com.br/ws/$cep/json/');
  }
  void armazenarDados() async {
    //sair se o cep estiver vazio
    print("Armazenando dados, co m seguinte address: "+_address);
    if (_address == "") return;

    http.Response jsonCru = await pesquisarCep(this._address);

    //erro na api
    if (jsonCru.statusCode != 200) return;

    Map<String, dynamic> mapa = jsonDecode(jsonCru.body);
  print(mapa);
    rua = mapa['logradouro'];
    cidade = mapa['localidade'];
  }
}


