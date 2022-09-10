// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

typedef OnCompose = void Function(String firstName, String todo);

class ComposeWidget extends StatefulWidget {
  final OnCompose onCompose;

  const ComposeWidget({
    Key? key,
    required this.onCompose,
  }) : super(key: key);

  @override
  State<ComposeWidget> createState() => _ComposeWidgetState();
}

class _ComposeWidgetState extends State<ComposeWidget> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _todoController;

  @override
  void initState() {
    _firstNameController = TextEditingController();
    _todoController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        height: 200,
        width: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  hintText: "Nome",
                ),
              ),
              TextField(
                controller: _todoController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.list),
                  hintText: "Tarefa do dia",
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                child: Text("Adicionar para Lista",
                    style: TextStyle(fontSize: 14, color: Colors.white)),
                onPressed: () {
                  final firstName = _firstNameController.text;
                  final todo = _todoController.text;
                  widget.onCompose(firstName, todo);
                  _firstNameController.text = '';
                  _todoController.text = '';
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  elevation: 10,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
