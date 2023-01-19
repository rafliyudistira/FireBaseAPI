import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

TextEditingController inputName = TextEditingController();
TextEditingController inputEmail = TextEditingController();
TextEditingController inputGender = TextEditingController();

class NetworkApi extends StatefulWidget {
  NetworkApi({super.key});

  @override
  State<NetworkApi> createState() => _NetworkApiState();
}

class _NetworkApiState extends State<NetworkApi> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference users = firestore.collection('users');
    final editName = TextEditingController();
    final editEmail = TextEditingController();
    final editGender = TextEditingController();
    // print(postData());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "FireBase CRUD",
        ),
        centerTitle: true,
      ),
      body: Container(
          child: StreamBuilder<QuerySnapshot>(
        stream: users.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
                children: snapshot.data!.docs
                    .map(
                      (e) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(e['name'][0],
                              style: TextStyle(color: Colors.white)),
                        ),
                        title: Text(e['name']),
                        subtitle: Text(e['email']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: (() {
                                editName.text = e['name'];
                                editEmail.text = e['email'];
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                          title: const Text(
                                            'Update User',
                                            textAlign: TextAlign.center,
                                          ),
                                          content: Form(
                                            key: _formKey,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextFormField(
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return "Name cannot be empty";
                                                    }
                                                    return null;
                                                  },
                                                  controller: editName,
                                                  decoration: InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    labelText: 'Nama',
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                TextFormField(
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return "Email cannot be empty";
                                                    }
                                                    if (!EmailValidator
                                                        .validate(value)) {
                                                      return "Please insert correct email";
                                                    }
                                                    return null;
                                                  },
                                                  controller: editEmail,
                                                  decoration: InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    labelText: 'Email',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, 'Cancel'),
                                                  child: const Text(
                                                    'Cancel',
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    await users
                                                        .doc(e.id)
                                                        .update({
                                                      'name': editName.text,
                                                      'email': editEmail.text,
                                                    });
                                                    editName.clear();
                                                    editEmail.clear();
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            )
                                          ],
                                        ));
                              }),
                              icon: Icon(Icons.edit),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                await users.doc(e.id).delete();
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList());
          } else {
            return CircularProgressIndicator();
          }
        },
      )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text(
                'Input User',
                textAlign: TextAlign.center,
              ),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Name cannot be empty";
                        }
                        return null;
                      },
                      controller: inputName,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Name',
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email cannot be empty";
                        }
                        if (!EmailValidator.validate(value)) {
                          return "Please insert correct email";
                        }
                        return null;
                      },
                      controller: inputEmail,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text(
                        'Cancel',
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          users.add({
                            "name": inputName.text,
                            "email": inputEmail.text,
                          });
                          inputName.clear();
                          inputEmail.clear();
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('OK'),
                    ),
                  ],
                )
              ],
            ),
          );
          //
        },
      ),
    );
  }
}
