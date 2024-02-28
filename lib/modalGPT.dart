import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:english_words/english_words.dart';

void modalDialog(BuildContext context, WordPair pair) async {
  showDialog<void>(
    context: context,
    builder: (context) {
      return DialogContent(pair: pair);
    },
  );
}

class DialogContent extends StatefulWidget {
  final WordPair pair;

  DialogContent({required this.pair});

  @override
  _DialogContentState createState() => _DialogContentState();
}

class _DialogContentState extends State<DialogContent> {
  late Future<List<dynamic>> firstDefinition;
  late Future<List<dynamic>> secondDefinition;

  @override
  void initState() {
    super.initState();
    fetchDefinitions();
  }

  void fetchDefinitions() {
    firstDefinition = _fetchDefinition(widget.pair.first);
    secondDefinition = _fetchDefinition(widget.pair.second);
  }

  Future<List<dynamic>> _fetchDefinition(String word) async {
    final response = await http.get(Uri.parse("https://api.dictionaryapi.dev/api/v2/entries/en/$word"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load definitions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Definition"),
      content: FutureBuilder(
        future: Future.wait([firstDefinition, secondDefinition]),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return SizedBox(
                width: 300.0,
                height: 300.0,
                child: ListView.builder(
                  itemCount: 2,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(
                        (index == 0) ? widget.pair.first : widget.pair.second,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      subtitle: Text(
                        (index == 0)
                            ? snapshot.data![0][0]['meanings'][0]['definitions'][0]['definition']
                            : snapshot.data![1][0]['meanings'][0]['definitions'][0]['definition'],
                      ),
                    );
                  },
                ),
              );
            }
          }
        },
      ),
    );
  }
}
