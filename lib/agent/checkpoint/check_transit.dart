import 'package:etrace/appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(CheckTransit());

class CheckTransit extends StatelessWidget {
  const CheckTransit({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: Colors.white,
      ),
      child: CheckTransitScreen(),
    );
  }
}

class CheckTransitScreen extends StatefulWidget {
  const CheckTransitScreen({super.key});

  @override
  _CheckTransitScreenState createState() => _CheckTransitScreenState();
}

class _CheckTransitScreenState extends State<CheckTransitScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SoftAppBar(
        title: "Declarations d'abattage",
        actions: [Icon(Icons.settings_outlined)],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Cette page vous permet de suivre les bétails en transit.",
              //style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
