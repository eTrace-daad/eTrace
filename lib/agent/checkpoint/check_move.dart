import 'package:etrace/appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(CheckMove());

class CheckMove extends StatelessWidget {
  const CheckMove({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: Colors.white,
      ),
      child: CheckMoveScreen(),
    );
  }
}

class CheckMoveScreen extends StatefulWidget {
  const CheckMoveScreen({super.key});

  @override
  _CheckMoveScreenState createState() => _CheckMoveScreenState();
}

class _CheckMoveScreenState extends State<CheckMoveScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SoftAppBar(
        title: "Suivi Bétail",
        actions: [Icon(Icons.settings_outlined)],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Cette page vous permet de suivre les bétails en mouvement.",
              //style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
