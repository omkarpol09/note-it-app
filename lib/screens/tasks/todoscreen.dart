import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen(
      {required this.user,
      required this.colors,
      required this.random,
      super.key});

  final User user;
  final List<dynamic> colors;
  final Random random;

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final taskController = TextEditingController();

  addToDo() async {
    final task = taskController.text;

    if (task.isEmpty) {
      return;
    }

    await FirebaseFirestore.instance
        .collection('${widget.user.email}-Tasks')
        .add({
      'task': task,
      'status': false,
      'color': widget.colors[widget.random.nextInt(3)],
      'order': DateTime.now().microsecondsSinceEpoch,
    });

    taskController.clear();
  }

  openDialogBox() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          elevation: 4,
          content: SizedBox(
            width: 200,
            height: 100,
            child: TextField(
              cursorColor: const Color(0xff181F39),
              style: const TextStyle(
                fontFamily: 'VarelaRound',
                color: Color(0xff181F39),
              ),
              controller: taskController,
              decoration: const InputDecoration(
                hintText: 'Task',
                hintStyle: TextStyle(
                  color: Color(0xff181F39),
                  fontFamily: 'VarelaRound',
                ),
              ),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(
                  Color(0xff181F39),
                ),
              ),
              onPressed: () {
                addToDo();
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
                taskController.clear();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Color(0xff181F39),
                  fontFamily: 'VarelaRound',
                ),
              ),
            )
          ],
        );
      },
    );
  }

  showTaskDeletedMessage(data) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Task deleted successfully.',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'VarelaRound',
          ),
        ),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection('${widget.user.email}-Tasks')
                .add(data);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    taskController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('${widget.user.email}-Tasks')
            .orderBy('order', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No tasks found. Try adding some.',
                style: TextStyle(
                  color: Color(0xff181F39),
                  fontFamily: 'VarelaRound',
                ),
              ),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data();
              var status = data['status'];
              var uid = doc.id;

              return Padding(
                padding: const EdgeInsets.only(
                  left: 7,
                  right: 7,
                  bottom: 4,
                ),
                child: SizedBox(
                  height: 60,
                  child: Card(
                    color: Color(data['color']),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Checkbox(
                            fillColor: const MaterialStatePropertyAll(
                              Color(0xff181F39),
                            ),
                            value: status,
                            onChanged: (value) async {
                              await FirebaseFirestore.instance
                                  .collection('${widget.user.email}-Tasks')
                                  .doc(uid)
                                  .update({
                                'status': value!,
                              });
                            },
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                data['task'],
                                style: const TextStyle(
                                  color: Color(0xff181F39),
                                  fontFamily: 'VarelaRound',
                                ),
                              ),
                            ),
                          ),
                          // const Spacer(),
                          IconButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('${widget.user.email}-Tasks')
                                  .doc(uid)
                                  .delete();

                              showTaskDeletedMessage(data);
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Color(0xff181F39),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff181F39),
        onPressed: openDialogBox,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

// button coror 0xff181F39
// 0xffADD8CE   0xffFDA597    0xffFEDA90
