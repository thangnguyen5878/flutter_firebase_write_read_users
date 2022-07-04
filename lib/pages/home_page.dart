// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final dateController = TextEditingController();
  late final String tempDate;
  int _selectedIndex = 0;

  Widget buildUser(User user) => ListTile(
        leading: CircleAvatar(child: Text('${user.age}')),
        title: Text(user.name),
        subtitle: Text(user.birthday.toIso8601String()),
      );

  Stream<List<User>> readUsers() {
    final snapshots =
        FirebaseFirestore.instance.collection('users').snapshots();
    return snapshots.map((snapshot) =>
        snapshot.docs.map((doc) => User.fromJson(doc.data())).toList());
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future createUser(User user) async {
    final doc = FirebaseFirestore.instance.collection('users').doc();
    user.id = doc.id;

    final data = user.toJson();
    await doc.set(data);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = <Widget>[
      // page 1
      Container(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: Column(children: [
          // const Text(
          //   'Add an user',
          //   style: TextStyle(fontSize: 30),
          // ),
          const SizedBox(height: 20),
          NameTextField(nameController: nameController),
          const SizedBox(height: 20),
          AgeTextField(ageController: ageController),
          const SizedBox(height: 20),
          TextFormField(
            controller: dateController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Date of birth",
            ),
            onTap: () async {
              DateTime? date = DateTime(1900);
              FocusScope.of(context).requestFocus(FocusNode());
              date = await showDatePicker(
                currentDate: DateTime.now(),
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );

              dateController.text = DateFormat('dd/MM/yyyy').format(date!);
              tempDate = DateFormat('yyyyMMdd').format(date);
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 100,
            child: ElevatedButton(
                onPressed: () {
                  final user = User(
                    name: nameController.text,
                    age: int.parse(ageController.text),
                    birthday: DateTime.parse(tempDate),
                  );

                  createUser(user);
                },
                child: const Text('Add')),
          ),
        ]),
      ),

      // page 2
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (_, snapshot) {
          if (snapshot.hasError) return Text('Error = ${snapshot.error}');

          if (snapshot.hasData) {
            final docs = snapshot.data!.docs;
            return SafeArea(
              child: Scaffold(
                body: Column(
                  children: [
                    // const Text(
                    //   'List of users',
                    //   style: TextStyle(fontSize: 30),
                    // ),
                    Expanded(
                      child: ListView.builder(
                        physics: const ClampingScrollPhysics(),
                        // scrollDirection: Axis.vertical,
                        // shrinkWrap: true,
                        itemCount: docs.length,
                        itemBuilder: (_, i) {
                          final data = docs[i].data();
                          String? birthday;
                    
                          var timestamp = data['birthday'];
                          if (timestamp == null) {
                            var birthday = 'null';
                          } else {
                            var dt = DateTime.parse(timestamp.toDate().toString());
                            var birthday = DateFormat('dd/MM/yyyy!').format(dt);
                          }
                    
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            child: ListTile(
                              tileColor: const Color.fromARGB(102, 45, 96, 104),
                              shape: RoundedRectangleBorder(
                                side:
                                    const BorderSide(color: Colors.black, width: 1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              title: Text(data['name']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Age: ${data['age']}'),
                                  Text('Date of Birth: $birthday'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    ];

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, //New
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add an user',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List of users',
          ),
        ],
      ),
      body: Center(
        child: pages.elementAt(_selectedIndex), //New
      ),
    );
  }

  TextField buildNameTextField() {
    return TextField(
      controller: nameController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Name',
      ),
    );
  }

  TextField buildAgeTextField() {
    return TextField(
      controller: ageController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Age',
      ),
    );
  }

  SizedBox buildSubmitButton() {
    return SizedBox(
      width: 100,
      child: ElevatedButton(
          onPressed: () {
            final user = User(
              name: nameController.text,
              age: int.parse(ageController.text),
              birthday: DateTime.parse(tempDate),
            );

            createUser(user);
          },
          child: const Text('Submit')),
    );
  }
}

class AgeTextField extends StatelessWidget {
  const AgeTextField({
    Key? key,
    required this.ageController,
  }) : super(key: key);

  final TextEditingController ageController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ageController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Age',
      ),
    );
  }
}

class NameTextField extends StatelessWidget {
  const NameTextField({
    Key? key,
    required this.nameController,
  }) : super(key: key);

  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: nameController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Name',
      ),
    );
  }
}

class User {
  String id;
  final String name;
  final int age;
  final DateTime birthday;

  User({
    this.id = '',
    required this.name,
    required this.age,
    required this.birthday,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'birthday': birthday,
      };

  static User fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        age: json['age'],
        birthday: (json['birthday'] as Timestamp).toDate(),
        name: json['name'],
      );
}