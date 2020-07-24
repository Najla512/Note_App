
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_notes/NoteDetail.dart';
import 'package:provider/provider.dart';
import 'models/note.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'utils/database_helper.dart';
import 'NoteDetail.dart';
import 'package:sqflite/sqflite.dart';
import 'Color.dart';
import 'theme.dart';
import 'package:flutter/painting.dart';

class NoteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;
  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Dark/Light"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.brightness_6),
            color: Colors.white,
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).swapTheme();
            },
          )
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: 400,
            height: 600,
            child: Image.asset(
              'assets/1.jpg',
              fit: BoxFit.contain,
            ),
          ),
//
          Positioned(
            child: Text(
              "My Notes",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold),
            ),
            top: 40,
            left: 20,
          ),

          DraggableScrollableSheet(
            maxChildSize: 0.85,
            minChildSize: 0.1,
            builder: (BuildContext context, ScrollController scrolController) {
              return Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(40),
                          topLeft: Radius.circular(40)),
                    ),
                    child: ListView.builder(
                      itemCount: count,
                      itemBuilder: (context, int position) {
                        return Dismissible(
                          key: ObjectKey(noteList[position]),
                          onDismissed: (direction) {
                            setState(() {
                              _delete(context, noteList[position]);
                            });
                          },
                          background: Container(
                              color: Colors.red,
                              child: Text(
                                "Delete",
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              )),
                          child: ListTile(
                            title: Text(
                              this.noteList[position].title,
                              style: TextStyle(
                                  color: Colors.grey[900],
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              this.noteList[position].date,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            onTap: () {
                              debugPrint("ListTile Tapped");
                              navigateToDetail(
                                  this.noteList[position], 'Edit Note');
                            },
                            isThreeLine: false,
                          ),
                        );
                      },
                      controller: scrolController,
                    ),
                  ),
                ],
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          debugPrint('FAB clicked');
          navigateToDetail(Note('', '', 2), 'Add Note');
        },
        tooltip: 'Add Note',
        label: Text(
          'Add note'.toUpperCase(),
          style: TextStyle(color: BgColor),
        ),
        icon: Icon(
          Icons.add,
          color: BgColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: BgColor,
    );
  }

  void navigateToDetail(Note note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

//
  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('BgColor', BgColor));
  }
}
