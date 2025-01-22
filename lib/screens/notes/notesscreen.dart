import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:note_it/screens/notes/addnote.dart';
import 'package:note_it/screens/notes/editnote.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen(
      {required this.user,
      required this.colors,
      required this.random,
      super.key});

  final User user;
  final List<dynamic> colors;
  final Random random;

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  DateTime now = DateTime.now();

  showCollaboratedMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Collaborated',
            style: TextStyle(
              color: Color(0xff181F39),
              fontFamily: 'VarelaRound',
            ),
          ),
          content: const SizedBox(
            child: Text(
              'This note is in Collaboration. Cancel the Collaboration.',
              style: TextStyle(
                color: Color(0xff181F39),
                fontFamily: 'VarelaRound',
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(
                  Color(0xff181F39),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Ok',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'VarelaRound',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  deleteNote(List collaborators, String docID) async {
    await FirebaseFirestore.instance
        .collection('${widget.user.email}-Notes')
        .doc(docID)
        .delete();

    if (collaborators.isNotEmpty) {
      for (final collaborator in collaborators) {
        await FirebaseFirestore.instance
            .collection('$collaborator-Notes')
            .doc(docID)
            .delete();
      }
    }
  }

  showNoteDeletedMessage(data, List collaborators, String docID) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Note deleted successfully.',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'VarelaRound',
          ),
        ),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection('${widget.user.email}-Notes')
                .doc(docID)
                .set(data);

            if (collaborators.isNotEmpty) {
              for (final collaborator in collaborators) {
                await FirebaseFirestore.instance
                    .collection('$collaborator-Notes')
                    .doc(docID)
                    .set(data);
              }
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('${widget.user.email}-Notes')
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
                'No notes found. Try adding some.',
                style: TextStyle(
                  color: Color(0xff181F39),
                  fontFamily: 'VarelaRound',
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(
              left: 7,
              right: 7,
            ),
            child: ListView(
              children: snapshot.data!.docs.map(
                (doc) {
                  Map<String, dynamic> data = doc.data();

                  return Slidable(
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      key: Key(doc.id),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            if (widget.user.email != data['owner']) {
                              showCollaboratedMessage();
                            } else {
                              deleteNote(data['collaborators'], doc.id);
                            }
                          },
                          backgroundColor: const Color(0xff181F39),
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                        )
                      ],
                    ),
                    child: InkWell(
                      onLongPress: () {
                        return;
                      },
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EditNote(
                              date: data['date'],
                              title: data['title'],
                              note: data['note'],
                              dateNow: now,
                              user: widget.user,
                              uid: doc.id,
                              owner: data['owner'],
                              collaborators: data['collaborators'],
                            ),
                          ),
                        );
                      },
                      child: Card(
                        color: Color(data['color']),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      data['title'],
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xff181F39),
                                        fontFamily: 'VarelaRound',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    data['date'],
                                    style: const TextStyle(
                                      color: Color(0xff181F39),
                                      fontFamily: 'VarelaRound',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              Text(
                                data['note'],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                                style: const TextStyle(
                                  color: Color(0xff181F39),
                                  fontFamily: 'VarelaRound',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff181F39),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AddNote(
              user: widget.user,
              colors: widget.colors,
              now: now,
              random: widget.random,
            ),
          ));
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
