import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:note_app/model/note_list_model.dart';
import 'package:note_app/style/text_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<NoteModel> listNote = [];

  final TextEditingController _textTitleNote = TextEditingController();
  final TextEditingController _textDescNote = TextEditingController();

  _getDataLocal() async {
    final prefs = await SharedPreferences.getInstance();
    var action = prefs.get('action');
    setState(() {
      if (action == null) {
        listNote = [];
      } else {
        listNote = noteModelFromJson(action.toString());
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDataLocal();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _textDescNote.dispose();
    _textTitleNote.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 248, 248, 248),
        floatingActionButton: FloatingActionButton.large(
            backgroundColor: Colors.black,
            onPressed: () {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('New Note'),
                  content: SizedBox(
                    height: 130,
                    child: Column(
                      children: [
                        TextField(
                          controller: _textTitleNote,
                          decoration:
                              const InputDecoration(label: Text('Title Note')),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextField(
                          controller: _textDescNote,
                          decoration: const InputDecoration(
                              label: Text('Description Note')),
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () {
                        _addNote();
                      },
                      child: const Text('SUBMIT'),
                    ),
                  ],
                ),
              );
            },
            child: const Icon(Icons.comment_outlined)),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Note',
                  style: noteTitle,
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: size.height / 1.2,
                  child: listNote.isEmpty
                      ? Center(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: size.height / 8,
                            ),
                            Image.asset(
                              'images/no_list.png',
                              width: size.width / 1.5,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text('No Note Data!', style: noteWarning),
                          ],
                        ))
                      : ListView.builder(
                          itemBuilder: ((context, index) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.all(15),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border:
                                      Border.all(color: Colors.black, width: 1),
                                  borderRadius: BorderRadius.circular(15)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: size.width / 1.5,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          listNote[index].title!,
                                          style: noteListTitle,
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(listNote[index].desc!,
                                            style: noteDescTitle)
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _deleteNote(index);
                                    },
                                    child: const Icon(
                                      Icons.delete_outline_outlined,
                                      color: Colors.pinkAccent,
                                    ),
                                  )
                                ],
                              ),
                            );
                          }),
                          itemCount: listNote.length),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _addNote() async {
    NoteModel note = NoteModel(
      title: _textTitleNote.text,
      desc: _textDescNote.text,
    );
    listNote.add(note);
    _textTitleNote.clear();
    _textDescNote.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('action', json.encode(listNote));
    _getDataLocal();
    setState(() {});
    Navigator.pop(context);
  }

  _deleteNote(int index) async {
    listNote.removeAt(index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('action', json.encode(listNote));
    _getDataLocal();
    setState(() {});
  }
}
