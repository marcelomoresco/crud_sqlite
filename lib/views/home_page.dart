import 'package:crud_sqlite/database/person_database.dart';
import 'package:crud_sqlite/views/components/compose_widget.dart';
import 'package:flutter/material.dart';

import '../models/person.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PersonDb _databaseCrud;
  final _firstNameController = TextEditingController();
  final _todoController = TextEditingController();

  @override
  void initState() {
    _databaseCrud = PersonDb('db.sqflite');
    _databaseCrud.openDb();
    super.initState();
  }

  @override
  void dispose() {
    _databaseCrud.close();
    super.dispose();
  }

  Future<Person?> showUpdateDialog(BuildContext context, Person person) {
    _firstNameController.text = person.firstName;
    _todoController.text = person.todo;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.deepPurple,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Digite os valores atualizados",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.person,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    controller: _todoController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.person,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(null);
                    },
                  ),
                  TextButton(
                    child: Text(
                      "Salvar",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      final editedPerson = Person(
                        id: person.id,
                        firstName: _firstNameController.text,
                        todo: _todoController.text,
                      );
                      Navigator.of(context).pop(editedPerson);
                    },
                  ),
                ],
              ),
            ],
          );
        }).then((value) {
      if (value is Person) {
        return value;
      } else {
        return null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: StreamBuilder(
        stream: _databaseCrud.all(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.waiting:
              if (snapshot.data == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              //List

              final people = snapshot.data as List<Person>;
              print(people);

              return Column(
                children: [
                  SizedBox(
                    height: 100,
                  ),
                  ComposeWidget(onCompose: (firstName, todo) {
                    _databaseCrud.create(firstName, todo);
                  }),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "CRUD feito com SQLITE",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemBuilder: (context, index) {
                          final person = people[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: Container(
                              height: 70,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15)),
                              child: ListTile(
                                onTap: () async {
                                  final editedPerson =
                                      await showUpdateDialog(context, person);
                                  if (editedPerson != null) {
                                    await _databaseCrud.update(editedPerson);
                                  }
                                },
                                title: Text(person.firstName),
                                subtitle: Text(person.todo),
                                trailing: TextButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              content: Text(
                                                  "Tem certeza que deseja deletar esse item?"),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text("Não")),
                                                TextButton(
                                                    onPressed: () async {
                                                      Navigator.of(context)
                                                          .pop();
                                                      await _databaseCrud
                                                          .delete(person);
                                                    },
                                                    child: Text("Deletar"))
                                              ],
                                            );
                                          });
                                    },
                                    child: Icon(Icons.disabled_by_default,
                                        color: Colors.red)),
                              ),
                            ),
                          );
                        },
                        itemCount: people.length),
                  ),
                ],
              );
            default:
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
          }
        },
      ),
    );
  }
}
