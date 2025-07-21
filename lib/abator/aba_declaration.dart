import 'package:etrace/appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(AbaDeclaration());

class AbaDeclaration extends StatelessWidget {
  const AbaDeclaration({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: Colors.white,
      ),
      child: AbaDeclarationScreen(),
    );
  }
}

class AbaDeclarationScreen extends StatefulWidget {
  const AbaDeclarationScreen({super.key});

  @override
  _AbaDeclarationScreenState createState() => _AbaDeclarationScreenState();
}

class _AbaDeclarationScreenState extends State<AbaDeclarationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SoftAppBar(
        title: "Declarations d'abattage",
        //actions: [Icon(Icons.settings_outlined)],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Cette page vous permet de suivre les déclarations d'abattage.",
              //style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
