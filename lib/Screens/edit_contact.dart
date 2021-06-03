import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import '../model/contact.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
class EditContact extends StatefulWidget {
  final String id;
  EditContact(this.id);
  @override
  _EditContactState createState() => _EditContactState(id);
}

class _EditContactState extends State<EditContact> {
  String id;
  _EditContactState(this.id);

  String _firstName = '';
  String _lastName = '';
  String _phone = '';
  String _address = '';
  String _email = '';
  String _photoUrl;
  String _houseNumber = '';
  String _streetNumber = '';
  String _birthday = '';
  String rua = "";
  String cidade = "";
  DateTime selectedDate = DateTime.now();
  //handle text editing controller

  TextEditingController _fnController = TextEditingController();
  TextEditingController _lnController = TextEditingController();
  TextEditingController _poController = TextEditingController();
  TextEditingController _emController = TextEditingController();
  TextEditingController _adController = TextEditingController();
  TextEditingController _hnController = TextEditingController();
  TextEditingController _snController = TextEditingController();
  TextEditingController _birthdayController = TextEditingController();


  bool isLoading = true;

  //db/firebase helper
  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    //get contact from firebase
    this.getContact(id);
  }

  getContact(id) async {
    Contact contact;
    _databaseReference.child(id).onValue.listen((event) {
      contact = Contact.fromSnapshot(event.snapshot);

      _fnController.text = contact.firstName;
      _lnController.text = contact.lastName;
      _poController.text = contact.phone;
      _emController.text = contact.email;
      _adController.text = contact.address;
     _hnController.text = contact.houseNumber;
     _snController.text = contact.streetNumber;
     _birthdayController.text = contact.birthday;

      setState(() {
        _firstName = contact.firstName;
        _lastName = contact.lastName;
        _phone = contact.phone;
        _email = contact.email;
        _address = contact.address;
        _photoUrl = contact.photoUrl;
        _houseNumber = contact.houseNumber;
        _birthday = contact.birthday;
        _streetNumber = contact.streetNumber;
        selectedDate = DateFormat("yyyy-MM-dd - kk:mm").parse(_birthday);

        isLoading = false;
      });
      armazenarDados();
    });
  }

  //update contact
  updateContact(BuildContext context) async {
    if (_firstName.isNotEmpty &&
        _lastName.isNotEmpty &&
        _phone.isNotEmpty &&
        _email.isNotEmpty &&
        _address.isNotEmpty) {
      _birthday = DateFormat('yyyy-MM-dd - kk:mm').format(selectedDate);
      Contact contact = Contact.withId(this.id, this._firstName, this._lastName,
          this._phone, this._email, this._address, this._photoUrl, this._streetNumber, this._houseNumber, this._birthday);

      await _databaseReference.child(id).set(contact.toJson());
      navigateToLastScreen(context);
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Field required"),
              content: Text("All fields are required"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Closr"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }

  //pick image
  Future pickImage() async {
    File file = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 200.0, maxWidth: 200.0);

    uploadImage(file);
  }

  //upload image

  void uploadImage(File file) async {
    final bytes = await file.readAsBytes();
    String convertida = base64Encode(bytes);

    this._photoUrl = convertida;

  }

  navigateToLastScreen(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF30336B),
        title: Text("Editar"),
      ),
      body: Container(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: EdgeInsets.all(10.0),
                child: ListView(
                  children: <Widget>[
                    //image view
                    Container(
                        margin: EdgeInsets.only(top: 5.0),
                        child: GestureDetector(
                          onTap: () {
                            this.pickImage();
                          },
                          child: Center(
                            child: Container(
                                width: 100.0,
                                height: 100.0,
                                decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                      fit: BoxFit.cover,
                                      image: _photoUrl == "empty"
                                          ? AssetImage("assets/logo.png")
                                          : Image.memory(base64Decode(_photoUrl)),
                                    ))),
                          ),
                        )),
                    //
                    Container(
                      margin: EdgeInsets.only(top: 14.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _firstName = value;
                          });
                        },
                        controller: _fnController,
                        decoration: InputDecoration(
                          labelText: 'Primeiro nome',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                      ),
                    ),
                    //
                    Container(
                      margin: EdgeInsets.only(top: 14.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _lastName = value;
                          });
                        },
                        controller: _lnController,
                        decoration: InputDecoration(
                          labelText: 'Segundo nome',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                      ),
                    ),
                    //
                    Container(
                      margin: EdgeInsets.only(top: 14.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _phone = value;
                          });
                        },
                        controller: _poController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Telefone',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                      ),
                    ),
                    //
                    Container(
                      margin: EdgeInsets.only(top: 14.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _email = value;
                          });
                        },
                        controller: _emController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                      ),
                    ),
                    //
                    Container(
                      margin: EdgeInsets.only(top: 14.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _address = value;
                          });
                          armazenarDados();
                        },
                        controller: _adController,
                        decoration: InputDecoration(
                          labelText: 'CEP',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
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

                    // update button
                    Container(
                      padding: EdgeInsets.fromLTRB(50, 23, 50, 20),
                      child: RaisedButton(
                        padding: EdgeInsets.fromLTRB(100.0, 20.0, 100.0, 20.0),
                        onPressed: () {
                          updateContact(context);
                        },
                        color: Colors.black,
                        child: Text(
                          "Atualizar",
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                          ),
                        ),
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
    if (_address == "") return;

    http.Response jsonCru = await pesquisarCep(this._address);

    //erro na api
    if (jsonCru.statusCode != 200) return;

    Map<String, dynamic> mapa = jsonDecode(jsonCru.body);

    rua = mapa['logradouro'];
    cidade = mapa['localidade'];
  }
}
