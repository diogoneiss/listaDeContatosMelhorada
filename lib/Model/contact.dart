import 'package:firebase_database/firebase_database.dart';

class Contact{

  String _id;
  String _firstName;
  String _lastName;
  String _phone;
  String _photoUrl;
  String _email;
  String _address;
  String _houseNumber;
  String _streetNumber;
  String _birthday;

  Contact(this._firstName,this._lastName,this._phone,this._email,this._address,this._photoUrl, this._houseNumber, this._streetNumber, this._birthday);
  Contact.withId(this._id,this._firstName,this._lastName,this._phone,this._email,this._address,this._photoUrl, this._houseNumber, this._streetNumber, this._birthday);

  //Adding getters
  String get id => this._id;
  String get firstName => this._firstName;
  String get lastName => this._lastName;

  String get houseNumber => null;
  String get phone => this._phone;
  String get address => this._address;
  String get email => this._email;
  String get photoUrl => this._photoUrl;

  String get streetNumber => this._streetNumber;
  String get birthday => this._birthday;



  //Adding Setters
  set firstName(String firstName){
    this._firstName = firstName;
  }
  set lastName(String lastName){
    this._lastName = lastName;
  }
  set phone(String phone){
    this._phone = phone;
  }
  set address(String address){
    this._address = address;
  }
  set email(String email){
    this._email = email;
  }
  set photoUrl(String photoUrl){
    this._photoUrl = photoUrl;
  }

  set houseNumber(String houseNumber){
    this._houseNumber = houseNumber;
  }
  set streetNumber(String streetNumber){
    this._streetNumber = streetNumber;
  }
  set birthday(String birthday){
    this._birthday = birthday;
  }

  Contact.fromSnapshot(DataSnapshot snapshot){
    this._id = snapshot.key;
    this._firstName = snapshot.value['firstName'];
    this._lastName = snapshot.value['lastName'];
    this._phone = snapshot.value['phone'];
    this._email = snapshot.value['email'];
    this._photoUrl = snapshot.value['photoUrl'];
    this._address = snapshot.value['address'];
    this._houseNumber = snapshot.value['houseNumber'];
    this._streetNumber = snapshot.value['streetNumber'];
    this._birthday = snapshot.value['birthday'];
  }

  Map<String,dynamic> toJson() {
    return{
      "firstName": _firstName,
      "lastName": _lastName,
      "phone": _phone,
      "address": _address,
      "email": _email,
      "photoUrl": _photoUrl,
      "houseNumber": _houseNumber,
      "streetNumber": _streetNumber,
      "birthday": _birthday,
    };
  }
}