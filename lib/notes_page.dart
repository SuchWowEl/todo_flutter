import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
//import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:provider/provider.dart';
import 'db_functions.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();

//   sqfliteFfiInit();
//   databaseFactory = databaseFactoryFfi;
//   runApp(const MyApp());
// }

class NoteGiven {
  late Notes def;
  late NotesDatabase database;
  late String date;

  NoteGiven({required this.date}) {
    print("notegiven constructor called");
    database = NotesDatabase(); // require NotesDatabase next time
  }
  /* {
    date = id;
    database = NotesDatabase();
    //fetchNote();
    print("database should be initialized");
  }*/

  void callInfo() {
    database.callInfo();
  }

  Future<Notes> fetchNote() async {
    print("date is $date");
    return fetchNotes(date);
  }

  Future<Notes> fetchNotes(date) async {
    def = await database.loadNote(date);
    return def;
  }

  Future<void> insertNote(noteReceived) async {
    await database.insertNotes(noteReceived);
    print("note inserted!");
  }

  Future<void> updateNotesToDb(Notes noteReceived, String oldDate) async {
    await database.updateNote(noteReceived, oldDate);
    print("note updated! ${noteReceived.toString()}");
  }

  void updateNotes(String title, content) {
    content = json.encode(content);
    updateNotesToDb(
        Notes(
            title: title,
            date: DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()),
            content: content),
        def.date);
  }

  deleteNote(String dateOfNote) async {
    await database.deleteNote(dateOfNote);
  }

  // void printDatabase() {
  //   database.loadData();
  // }

  // void saveNote(noteReceived) {
  //   database.updateNote(noteReceived);
  // }

  void setDefaultNotes() {
    def = const Notes(
        title: "", date: "now?", content: r'[{"insert": "default value\n"}]');
  }

  void setDef(Notes note) {
    def = note;
    date = note.date;
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   NoteGiven temp() {
//     var temp = NoteGiven(date: 2.toString());
//     temp.setDefaultNotes();
//     print(temp.def.toString());
//     return temp;
//   }

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Notes App',
//       theme: ThemeData(
//         brightness: Brightness.dark,
//         primaryColor: Colors.pinkAccent,
//         secondaryHeaderColor: const Color.fromARGB(255, 255, 23, 23),
//         //colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: FutureProvider<NoteGiven>(
//         initialData: temp(),
//         create: (context) async {
//           var tempvar = NoteGiven(date: 2.toString());
//           await tempvar.fetchNote();
//           print("tempvar value: ${tempvar.def.toString()}");
//           return tempvar;
//         },
//         child: Consumer<NoteGiven>(
//           builder: (context, noteGiven, child) =>
//               NotesPage(noteGiven: noteGiven),
//         ),
//       ),
//     );
//   }
// }

class NotesPage extends ConsumerWidget {
  final Notes noteGiven;
  const NotesPage({super.key, required this.noteGiven});

  QuillController createController() {
    var stringtemp = json.decode(noteGiven.content);
    // if (stringtemp is List) {
    // print("noteGiven is JSON");
    print(stringtemp);
    return QuillController(
        document: Document.fromJson(stringtemp),
        selection: const TextSelection.collapsed(offset: 0));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("notesList @ NotesPage");
    print("the date of said note is: ${noteGiven.date}");
    TextEditingController controller =
        TextEditingController(text: noteGiven.title);

    QuillController quillController = createController();

    return MaterialApp(
      theme: Theme.of(context),
      home: Scaffold(
        appBar: AppBar(
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new)),
            backgroundColor: Colors.black54,
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width:
                        300, //(MediaQuery.of(context).devicePixelRatio /3), //.sizeOf(context).width / 3),
                    child: TextField(
                      controller: controller,
                      cursorColor: Colors.white,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          fillColor: Colors.lightGreen,
                          hintStyle: TextStyle(color: Colors.white70),
                          hintText: "Title"),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            var content = json.encode(
                                quillController.document.toDelta().toJson());
                            var newNote = Notes(
                                title: controller.text,
                                date: DateFormat('yyyy-MM-dd hh:mm:ss')
                                    .format(DateTime.now()),
                                content: content);
                            ref
                                .read(notesProvider.notifier)
                                .updateNotes(newNote, noteGiven.date);
                          },
                          icon: const Icon(Icons.check)),
                      IconButton(
                          onPressed: () {
                            ref
                                .read(notesProvider.notifier)
                                .deleteNotes(noteGiven.date);
                            Navigator.pop(context);
                          },
                          //noteGiven.deleteNote(noteGiven.def.date),
                          icon: const Icon(Icons.delete_outline)),
                    ],
                  ),
                ])),
        body: NotesContent(quillController: quillController),
      ),
    );
  }
}

class NotesContent extends StatelessWidget {
  final QuillController quillController;
  const NotesContent({super.key, required this.quillController});

  @override
  Widget build(BuildContext context) {
    final QuillController controller = quillController;
    return Column(
      children: [
        Container(
          height: 15,
        ),
        QuillToolbar.basic(
          color: Colors.blue[900],
          controller: controller,
        ),
        Expanded(
          child: QuillEditor.basic(
            placeholder: "What is in your mind?",
            keyboardAppearance: Brightness.dark,
            padding: const EdgeInsets.all(50),
            controller: controller,
            readOnly: false,
          ),
        ),
      ],
    );
  }
}
