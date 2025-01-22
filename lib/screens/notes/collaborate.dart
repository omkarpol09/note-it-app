import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CollaborateScreen extends StatefulWidget {
  const CollaborateScreen({required this.user, super.key});

  final User user;

  @override
  State<CollaborateScreen> createState() => _CollaborateScreenState();
}

class _CollaborateScreenState extends State<CollaborateScreen> {
  final linkController = TextEditingController();

  collaborate() async {
    final String link = linkController.text.trim();
    if (link.isEmpty) {
      return;
    }

    List<String> lst = link.split('\\');

    if (lst[1] == widget.user.email) {
      return;
    }

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('${lst[1]}-Notes')
        .doc(lst[2])
        .get();

    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
    List collaborators = data['collaborators'];
    collaborators.add(widget.user.email);

    await FirebaseFirestore.instance
        .collection('${widget.user.email}-Notes')
        .doc(lst[2])
        .set(data);

    await FirebaseFirestore.instance
        .collection('${lst[1]}-Notes')
        .doc(lst[2])
        .update({
      'collaborators': collaborators,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 25, right: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: linkController,
              cursorColor: const Color(0xff181F39),
              style: const TextStyle(
                fontFamily: 'VarelaRound',
                color: Color(0xff181F39),
              ),
              decoration: const InputDecoration(
                hintText: 'Link',
                hintStyle: TextStyle(fontFamily: 'VarelaRound'),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(
                  Color(0xff181F39),
                ),
              ),
              onPressed: () {
                collaborate();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Collaborate',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'VarelaRound',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
