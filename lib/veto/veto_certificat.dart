import 'package:etrace/appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(VetoCertificat());

class VetoCertificat extends StatelessWidget {
  const VetoCertificat({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: Colors.white,
      ),
      child: VetoCertificatScreen(),
    );
  }
}

class VetoCertificatScreen extends StatefulWidget {
  const VetoCertificatScreen({super.key});

  @override
  _VetoCertificatScreenState createState() => _VetoCertificatScreenState();
}

class _VetoCertificatScreenState extends State<VetoCertificatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SoftAppBar(
        title: "Certificat Vétérinaire",
        actions: [Icon(Icons.settings_outlined)],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Cette page vous permet de suivre les informations vétérinaires des bovins.",
              //style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
