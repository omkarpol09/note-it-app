import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note_it/screens/notes/collaborate.dart';
import 'package:note_it/screens/notes/notesscreen.dart';
import 'package:note_it/screens/tasks/todoscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late User user;
  int selectedIndex = 0;
  late List<Widget> pages;
  var random = Random();
  List colors = [
    0xffFDA597,
    0xffADD8CE,
    0xffFEDA90,
  ];

  void changeIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    user = FirebaseAuth.instance.currentUser!;
    pages = [
      NotesScreen(
        user: user,
        colors: colors,
        random: random,
      ),
      TodoScreen(
        user: user,
        colors: colors,
        random: random,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Note It',
          style: TextStyle(
            color: Color(0xff181F39),
            // fontSize: 25,
            fontWeight: FontWeight.bold,
            fontFamily: 'VarelaRound',
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xff181F39),
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipOval(
                    child: Container(
                      height: 70,
                      width: 70,
                      color: Colors.white,
                      child: Center(
                        child: Text(
                          user.email.toString()[0].toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xff181F39),
                            fontFamily: 'VarelaRound',
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user.email.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'VarelaRound',
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CollaborateScreen(user: user),
                  ),
                );
              },
              leading: const Icon(
                Icons.group,
                color: Colors.white,
              ),
              title: const Text(
                'Collaborate',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'VarelaRound',
                ),
              ),
            ),
            ListTile(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
              },
              leading: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'VarelaRound',
                ),
              ),
            ),
          ],
        ),
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: changeIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Todos'),
        ],
      ),
    );
  }
}
