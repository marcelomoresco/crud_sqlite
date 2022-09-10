// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

class Person implements Comparable {
  final int id;
  final String firstName;
  final String todo;
  Person({
    required this.id,
    required this.firstName,
    required this.todo,
  });

  Person.fromRow(Map<String, Object?> row)
      : id = row['ID'] as int,
        firstName = row['FIRST_NAME'] as String,
        todo = row["TODO"] as String;

  @override
  int compareTo(covariant Person other) => other.id.compareTo(id);

  @override
  bool operator ==(covariant Person other) => id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return "Person, id $id,firstName $firstName, toDO $todo";
  }
}
