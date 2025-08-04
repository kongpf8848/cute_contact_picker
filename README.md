# cute_contact_picker

Flutter选择通讯录联系人插件，支持Android、iOS和HarmonyOS。

## 功能
* 支持获取单个联系人信息（不需要通讯录权限）
* 支持获取联系人列表（需要通讯录权限）
* Android和IOS支持获取联系人姓名的首字母

## 模型
```dart
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

  ///联系人姓名，如张三
  final String? fullName;

  ///电话号码，如13212345678
  final String? phoneNumber;

  ///姓名首字母，如Z
  final String? firstLetter;

}
```

## 用法
### 添加依赖到pubspec.yaml
```yaml
cute_contact_picker: ^0.1.0
```

### 引用
```dart
import 'package:cute_contact_picker/cute_contact_picker.dart';
```
### 添加权限
#### Android
##### 在`AndroidManifest.xml`中添加读取通讯录权限
```xml
<uses-permission android:name="android.permission.READ_CONTACTS" />
```
#### iOS
##### 在`Info.plist`中添加读取通讯录权限
```xml
<key>NSContactsUsageDescription</key>
<string>我们需要访问您的通讯录来帮助您快速填写联系人信息。</string>
```

#### HarmonyOS
##### 在`ohos/entry/src/main/module.json5`中声明通讯录权限
```json
"requestPermissions": [
  {
    "name": "ohos.permission.READ_CONTACTS",
    "reason": "读取联系人信息"
  }
]
```
### 示例1: 打开原生通讯录选择单个联系人
```dart
  final CuteContactPicker _contactPicker = new CuteContactPicker();
  Contact _contact = new Contact(fullName: "", phoneNumber: "");

  _getContactData() async {
    Contact contact = await _contactPicker.selectContactWithNative();
    setState(() {
      _contact = contact;
    });
  }
```
### 示例2: 返回联系人列表
```dart
  final CuteContactPicker _contactPicker = new CuteContactPicker();
  List<Contact> _list = new List();

  _getContactData() async {
    //申请权限
    if (await Permission.contacts.request().isGranted) {
      List<Contact> list = await _contactPicker.selectContacts();
      setState(() {
        _list = list;
      });
    }
  }
