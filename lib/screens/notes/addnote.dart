import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddNote extends StatefulWidget {
  const AddNote(
      {required this.user,
      required this.colors,
      required this.now,
      required this.random,
      super.key});

  final User user;
  final List<dynamic> colors;
  final DateTime now;
  final Random random;

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  final titleController = TextEditingController();
  final noteController = TextEditingController();

  addNote() async {
    final title = titleController.text;
    final note = noteController.text;

    if (title.isEmpty && note.isEmpty) {
      return;
    }

    await FirebaseFirestore.instance
        .collection('${widget.user.email}-Notes')
        .add({
      'title': title,
      'note': note,
      'order': DateTime.now().microsecondsSinceEpoch,
      'color': widget.colors[widget.random.nextInt(3)],
      'date': '${widget.now.day}-${widget.now.month}-${widget.now.year}',
      'collaborators': [],
      'owner': '${widget.user.email}'
    });

    titleController.clear();
    noteController.clear();
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    noteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 45,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.now.day}-${widget.now.month}-${widget.now.year}',
              style: const TextStyle(
                color: Color(0xff181F39),
                fontFamily: 'VarelaRound',
              ),
            ),
            TextField(
              controller: titleController,
              autofocus: true,
              cursorColor: const Color(0xff181F39),
              style: const TextStyle(
                fontFamily: 'VarelaRound',
                color: Color(0xff181F39),
              ),
              decoration: const InputDecoration(
                hintText: 'Title',
                hintStyle: TextStyle(fontFamily: 'VarelaRound'),
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: TextField(
                  controller: noteController,
                  cursorColor: const Color(0xff181F39),
                  style: const TextStyle(
                    fontFamily: 'VarelaRound',
                    color: Color(0xff181F39),
                  ),
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Note',
                    hintStyle: TextStyle(fontFamily: 'VarelaRound'),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            // const Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 20, bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                        Color(0xff181F39),
                      ),
                    ),
                    onPressed: () {
                      addNote();
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'VarelaRound',
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'cancel',
                      style: TextStyle(
                        color: Color(0xff181F39),
                        fontFamily: 'VarelaRound',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    ;
  }
}
