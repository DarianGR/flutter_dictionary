import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String url = "https://owlbot.info/api/v4/dictionary/";
  String token = "9ff98480522a7e0932b57f8831b405f0cb8fa5d7";

  TextEditingController textEditingController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;
  late StreamController streamController;
  late Stream _stream;

  searchText() async {
    if (textEditingController.text == null ||
        textEditingController.text.length == 0) {
      streamController.add(null);
      return;
    }
    streamController.add("waiting");
    Uri uri = Uri.parse(url + textEditingController.text.trim());
    Response response = await get(uri, headers:
    {"Authorization": "Token " + token});
    streamController.add(json.decode(response.body));
  }

  @override
  void initState() {
    super.initState();
    streamController = StreamController();
    _stream = streamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "DICTIONARY",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade300
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(45),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 12, bottom: 11.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.0),
                      color: Colors.grey.shade700),
                  child: TextFormField(
                    onChanged: (String text) {
                    },
                    controller: textEditingController,
                    decoration: InputDecoration(
                      hintText: "Search for a word",
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      contentPadding: const EdgeInsets.only(left: 24.0),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.search,
                  size: 40,
                  color: Colors.white,
                ),
                onPressed: () {
                  searchText();
                },
              )
            ],
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(8),
        child: StreamBuilder(
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: Text(
                  'Enter a search word',
                  style: TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            }
            if (snapshot.data == "waiting") {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data["definitions"].length,
              itemBuilder: (BuildContext context, int index) {
                return ListBody(
                  children: [
                    Container(
                      color: Colors.black,
                      child: ListTile(
                        leading: snapshot.data["definitions"][index]
                                    ["image_url"] ==
                                null
                            ? null
                            : CircleAvatar(
                                backgroundImage: NetworkImage(snapshot
                                    .data["definitions"][index]["image_url"]),
                              ),
                        title: Text(textEditingController.text.trim() +
                            "(" +
                            snapshot.data["definitions"][index]["type"] +
                            ")"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          snapshot.data["definitions"][index]["definition"]),
                    )
                  ],
                );
              },
            );
          },
          stream: _stream,
        ),
      ),
      bottomNavigationBar: Container(
          decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.orange.shade300, Colors.orange.shade100, Colors.white]),
        ),
        child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              minimumSize: Size.fromHeight(50),
            ),
            icon: Icon(Icons.arrow_back, size: 32),
            label: Text(
              'Sign Out',
              style: TextStyle(fontSize: 24),
            ),
            onPressed: FirebaseAuth.instance.signOut,
          ),
        ),
      );
    }
}