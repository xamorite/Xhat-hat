import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chatapp_two/screens/welcome_screen.dart';
import 'package:chatapp_two/screens/login_screen.dart';
import 'package:chatapp_two/screens/registration_screen.dart';
import 'package:chatapp_two/screens/chat_screen.dart';
import 'firebase_options.dart';

void main()async {
  runApp(const FlashChat());
  await Firebase.initializeApp(
         options: DefaultFirebaseOptions.currentPlatform,
       );
}

class FlashChat extends StatelessWidget {
  const FlashChat({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black54),
        ),
      ),
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => const WelcomeScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        RegistrationScreen.id: (context) => const RegistrationScreen(),
        ChatScreen.id: (context) => const ChatScreen(),
      },
    );
  }
}
