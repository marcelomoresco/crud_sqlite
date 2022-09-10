import 'dart:async';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/person.dart';

class PersonDb {
  final String dbName;
  Database? _db;
  PersonDb(this.dbName);

  List<Person> _persons = [];
  final _streamController = StreamController<List<Person>>.broadcast();

  final tableName = 'PEOPLE';

  Future<List<Person>> _fetchPeople() async {
    final db = _db;

    if (db == null) return [];

    try {
      final read = await db.query(
        "PEOPLE",
        distinct: true,
        columns: [
          'ID',
          'FIRST_NAME',
          'TODO',
        ],
        orderBy: 'ID',
      );

      final people = read.map((row) => Person.fromRow(row)).toList();
      return people;
    } catch (e) {
      return [];
    }
  }

  Future<bool> delete(Person person) async {
    final db = _db;

    if (db == null) {
      return false;
    }

    try {
      final deleteCount = await db.delete(
        tableName,
        where: "ID = ?",
        whereArgs: [person.id],
      );
      if (deleteCount == 1) {
        _persons.remove(person);
        _streamController.add(_persons);
        return true;
      } else {
        return false;
      }
      ;
    } catch (e) {
      return false;
    }
  }

  Future<bool> update(Person person) async {
    final db = _db;

    if (db == null) {
      return false;
    }

    try {
      final updateCount = await db.update(
        tableName,
        {
          'FIRST_NAME': person.firstName,
          'TODO': person.todo,
        },
        where: "ID = ?",
        whereArgs: [person.id],
      );

      if (updateCount == 1) {
        _persons.removeWhere((other) => other.id == person.id);
        _persons.add(person);
        _streamController.add(_persons);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> create(String firstName, String todo) async {
    final db = _db;

    if (db == null) return false;

    try {
      final id = await db.insert(tableName, {
        'FIRST_NAME': firstName,
        'TODO': todo,
      });

      final person = Person(id: id, firstName: firstName, todo: todo);

      _persons.add(person);
      _streamController.add(_persons);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> close() async {
    final db = _db;

    if (db == null) return false;

    await db.close();
    return true;
  }

  Future<bool> openDb() async {
    if (_db != null) {
      return true;
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$dbName';

    try {
      final db = await openDatabase(path);

      _db = db;

      final create = '''
CREATE TABLE IF NOT EXISTS PEOPLE(
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        FIRST_NAME STRING NOT NULL,
        TODO STRING NOT NULL
      ) 
      ''';
      await db.execute(create);

      //read

      _persons = await _fetchPeople();
      _streamController.add(_persons);
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<List<Person>> all() =>
      _streamController.stream.map((persons) => persons..sort());
}
