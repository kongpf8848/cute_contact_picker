import 'dart:async';

import 'package:flutter/services.dart';

class CuteContactPicker {
  static const MethodChannel _channel =
      const MethodChannel('plugins.flutter.io/cute_contact_picker');

  /// 打开原生通讯录
  ///
  /// return [Contact]
  Future<Contact> selectContactWithNative() async {
    final Map<dynamic, dynamic> result =
        await _channel.invokeMethod('selectContactNative');
    return new Contact.fromMap(result);
  }

  /// 获取通讯录列表
  ///
  /// return List<Contact>
  Future<List<Contact>> selectContacts() async {
    final List result = await _channel.invokeMethod('selectContactList');
    List<Contact> contacts = [];
    result.forEach((f) {
      contacts.add(new Contact.fromMap(f));
    });
    return contacts;
  }
}

class Contact {
  Contact({this.fullName, this.phoneNumber, this.firstLetter});

  factory Contact.fromMap(Map<dynamic, dynamic> map) => new Contact(
        fullName: map['fullName'],
        phoneNumber: map['phoneNumber'],
        firstLetter: map['firstLetter'],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fullName'] = this.fullName;
    data['phoneNumber'] = this.phoneNumber;
    data['firstLetter'] = this.firstLetter;
    return data;
  }

  final String? fullName;
  final String? phoneNumber;
  final String? firstLetter;
}
