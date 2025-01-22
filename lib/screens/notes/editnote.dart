import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditNote extends StatefulWidget {
  const EditNote(
      {required this.title,
      required this.note,
      required this.date,
      required this.dateNow,
      required this.user,
      required this.uid,
      required this.owner,
      required this.collaborators,
      super.key});

  final String date;
  final String title;
  final String note;
  final DateTime dateNow;
  final User user;
  final String uid;
  final String owner;
  final List collaborators;

  @override
  State<EditNote> createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  TextEditingController editTitleController = TextEditingController();
  TextEditingController editNoteController = TextEditingController();

  generateCollaborationLink() {
    String link = 'note-it\\${widget.user.email}\\${widget.uid}';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Collaboration Link',
            style: TextStyle(
              color: Color(0xff181F39),
              fontFamily: 'VarelaRound',
            ),
          ),
          content: SizedBox(
            child: Text(
              link,
              style: const TextStyle(
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
                Clipboard.setData(ClipboardData(text: link));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Link copied to clipboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'VarelaRound',
                      ),
                    ),
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text(
                'Copy',
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
                'Close',
                style: TextStyle(
                  color: Color(0xff181F39),
                  fontFamily: 'VarelaRound',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  editNote() async {
    final editedTitle = editTitleController.text;
    final editedNote = editNoteController.text;

    if (widget.owner == widget.user.email) {
      await FirebaseFirestore.instance
          .collection('${widget.user.email}-Notes')
          .doc(widget.uid)
          .update({
        'title': editedTitle,
        'note': editedNote,
        'order': DateTime.now().microsecondsSinceEpoch,
        'date':
            '${widget.dateNow.day}-${widget.dateNow.month}-${widget.dateNow.year}',
      });

      for (final collaborator in widget.collaborators) {
        await FirebaseFirestore.instance
            .collection('$collaborator-Notes')
            .doc(widget.uid)
            .update({
          'title': editedTitle,
          'note': editedNote,
          'order': DateTime.now().microsecondsSinceEpoch,
          'date':
              '${widget.dateNow.day}-${widget.dateNow.month}-${widget.dateNow.year}',
        });
      }
    } else {
      await FirebaseFirestore.instance
          .collection('${widget.owner}-Notes')
          .doc(widget.uid)
          .update({
        'title': editedTitle,
        'note': editedNote,
        'order': DateTime.now().microsecondsSinceEpoch,
        'date':
            '${widget.dateNow.day}-${widget.dateNow.month}-${widget.dateNow.year}',
      });

      for (final collaborator in widget.collaborators) {
        await FirebaseFirestore.instance
            .collection('$collaborator-Notes')
            .doc(widget.uid)
            .update({
          'title': editedTitle,
          'note': editedNote,
          'order': DateTime.now().microsecondsSinceEpoch,
          'date':
              '${widget.dateNow.day}-${widget.dateNow.month}-${widget.dateNow.year}',
        });
      }
    }
  }

  cancelCollaboration() {
    unCollaborate() async {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('${widget.owner}-Notes')
          .doc(widget.uid)
          .get();

      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      List collaborators = data['collaborators'];
      collaborators.remove(widget.user.email);

      await FirebaseFirestore.instance
          .collection('${widget.owner}-Notes')
          .doc(widget.uid)
          .update({
        'collaborators': collaborators,
      });

      await FirebaseFirestore.instance
          .collection('${widget.user.email}-Notes')
          .doc(widget.uid)
          .delete();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Cancel Collaboration',
            style: TextStyle(
              color: Color(0xff181F39),
              fontFamily: 'VarelaRound',
            ),
          ),
          content: const SizedBox(
            child: Text(
              'Are you sure you want to cancel collaboration?',
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
                unCollaborate();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Yes',
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
                'No',
                style: TextStyle(
                  color: Color(0xff181F39),
                  fontFamily: 'VarelaRound',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    editNoteController.dispose();
    editTitleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    editTitleController.text = widget.title;
    editNoteController.text = widget.note;

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (widget.owner == widget.user.email)
            IconButton(
              onPressed: generateCollaborationLink,
              icon: const Icon(
                Icons.group,
                color: Color(0xff181F39),
              ),
            ),
          if (widget.owner != widget.user.email)
            IconButton(
              onPressed: () {
                cancelCollaboration();
              },
              icon: const Icon(
                Icons.cancel,
                color: Color(0xff181F39),
              ),
            ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.date,
              style: const TextStyle(
                color: Color(0xff181F39),
                fontFamily: 'VarelaRound',
              ),
            ),
            TextField(
              controller: editTitleController,
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
                  controller: editNoteController,
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
                      editNote();
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Save',
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
                      'cancle',
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
  }
}
