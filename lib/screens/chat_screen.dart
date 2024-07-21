import 'package:flutter/material.dart';
import 'package:chatapp_two/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
late User loggedInUser;
class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  const ChatScreen({super.key});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  late String MessageText ;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }
  void getMessages()async{
   final messages =  await _firestore.collection('messages').get();
   for (var message in messages.docs){
     print(message.data());
   }
  }
  void messagesStream()async{
     await for (var snapshot in _firestore.collection('messages').snapshots()){
       for (var message in snapshot.docs){
         print(message.data());
       }
     }
  }

  void getCurrentUser()async{
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print('${loggedInUser.email!} is currently logged in');
      }
    }
    catch (e){
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                // Implement logout functionality
                _auth.signOut();
                Navigator.pop(context);

              }),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(stream: _firestore.collection('messages').snapshots(), builder: (context, snapshot){
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center( child: CircularProgressIndicator());
              }

              if (snapshot.hasData) {
                final messages = snapshot.data!.docs.reversed;
                List<Widget> messageBubble = [];

                for (var message in messages) {
                  final messageText = message.get('text') ;
                  final messageSender = message.get('sender');
                  final currentUser = loggedInUser;
                  messageBubble.add(
MessageBubble(sender: messageSender, text: messageText, isMe:currentUser == messageSender ,)
                  );
                }


                return Expanded(
                  child: ListView(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                    children: messageBubble,
                  ),
                );
              }

              return const SizedBox.shrink();
            }),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        MessageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      //Implement send functionality.
                      messageTextController.clear();
                      _firestore.collection('messages').add({
                        'text': MessageText,
                        'sender': loggedInUser.email
                      });
                    },
                    child: const Icon(Icons.send_rounded)
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
class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;
   const MessageBubble({super.key, required this.sender, required this.text, required this.isMe, });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(sender, style: const TextStyle(fontSize: 12.0),),
          Material(
            borderRadius: isMe ?
            const BorderRadius.only(
              topRight: Radius.circular(30),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),) :
            const BorderRadius.only(
              topLeft: Radius.circular(30),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),),
            elevation: 5.0,
              color: isMe ? Colors.black12 : Colors.lightBlueAccent ,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(text, style: const TextStyle(
                    fontSize: 15),),
              )),
        ],
      ),
    );
  }
}
