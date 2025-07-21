import 'package:etrace/appbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

void main() => runApp(SuiviBetail());

class SuiviBetail extends StatelessWidget {
  const SuiviBetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.nunitoTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: Colors.white,
      ),
      child: SuiviBetailScreen(),
    );
  }
}

class SuiviBetailScreen extends StatefulWidget {
  const SuiviBetailScreen({super.key});

  @override
  State<SuiviBetailScreen> createState() => _SuiviBetailScreenState();
}

class _SuiviBetailScreenState extends State<SuiviBetailScreen> {
  DateTime date = DateTime(2025, 6, 7);
  final List<TruckForm> truckForms = [TruckForm(key: UniqueKey())];

  /*void addTruckForm() {
    setState(() {
      truckForms.add(TruckForm(key: UniqueKey()));
    });
  }*/

  void submitForms() {
    // Validation & submission logic here
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: SoftAppBar(
        title: "Suivi Betaille",
        actions: [Icon(Icons.settings_outlined)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 42,
                  backgroundImage: AssetImage('assets/images/autre.png'),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Dareine",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("CHP-35 Yaounde",
                        style: TextStyle(color: Colors.green)),
                    Text("dareine.checkpoint@minepia.com"),
                    Text("(+237) 684 64 59 36"),
                    Text("Resp. MINEPIA Rianne",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Identification du Checkpoint",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(
                  0xff111827,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: DateFormat('dd/MM/yyyy').format(date),
              decoration: InputDecoration(
                //hintText: "Ex : Ferme Ngomeka, Bertoua...",
                prefixIcon: Icon(FontAwesomeIcons.calendarCheck,
                    color: Color(0xff4B5563)),
                //suffixIcon: Icon(FontAwesomeIcons.angleDown,
                //size: 16, // Ajuste la taille de l'icône si nécessaire
                //color: Color(0xff4B5563)),
                filled: true,
                fillColor: Color(0xfff5f5f5),
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12)),
              ),
              /*decoration: InputDecoration(
                prefixIcon: const Icon(Icons.calendar_today),

                //border:
                    //OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),*/
              readOnly: true,
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: "Centre",
              /*decoration: InputDecoration(
                prefixIcon: const Icon(Icons.location_on_outlined),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),*/
              decoration: InputDecoration(
                //hintText: "Ex : Ferme Ngomeka, Bertoua...",
                prefixIcon: Icon(FontAwesomeIcons.locationCrosshairs,
                    color: Color(0xff4B5563)),
                //suffixIcon: Icon(FontAwesomeIcons.angleDown,
                //size: 16, // Ajuste la taille de l'icône si nécessaire
                //color: Color(0xff4B5563)),
                filled: true,
                fillColor: Color(0xfff5f5f5),
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12)),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: "Mfoumdi",
                    readOnly: true,
                    /*decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),*/
                    decoration: InputDecoration(
                      //hintText: "Ex : Ferme Ngomeka, Bertoua...",
                      prefixIcon: Icon(FontAwesomeIcons.mountain,
                          color: Color(0xff4B5563)),
                      //suffixIcon: Icon(FontAwesomeIcons.angleDown,
                      //size: 16, // Ajuste la taille de l'icône si nécessaire
                      //color: Color(0xff4B5563)),
                      filled: true,
                      fillColor: Color(0xfff5f5f5),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: "Yaoundé V",
                    readOnly: true,
                    /*decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),*/
                    decoration: InputDecoration(
                      //hintText: "Ex : Ferme Ngomeka, Bertoua...",
                      prefixIcon: Icon(FontAwesomeIcons.locationDot,
                          color: Color(0xff4B5563)),
                      //suffixIcon: Icon(FontAwesomeIcons.angleDown,
                      //size: 16, // Ajuste la taille de l'icône si nécessaire
                      //color: Color(0xff4B5563)),
                      filled: true,
                      fillColor: Color(0xfff5f5f5),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Enregistrement des Camions",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(
                      0xff111827,
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {}, //addTruckForm,
                    icon: const Icon(Icons.add_circle_outline))
              ],
            ),
            const SizedBox(height: 8),
            ...truckForms,
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5A8C49), Color(0xFFAC6E3F)],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline,
                    size: 24, color: Colors.white),
                label: const Text(
                  "Enregistrer",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                onPressed: submitForms,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class TruckForm extends StatelessWidget {
  const TruckForm({super.key});

  @override
  Widget build(BuildContext context) {
    final timeNow = TimeOfDay.now().format(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      //elevation: 2,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), color: Color(0xfff5f5f5)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Camion #120250707",
                style: TextStyle(color: Colors.green)),
            const SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12)),
                hintText: "Entrez l'immatriculation du camion",
                prefixIcon:
                    const Icon(Icons.directions_car, color: Color(0xff4B5563)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "Provenance",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "Destination",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: timeNow,
              readOnly: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.access_time),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text("🐄 Bovins"),
                      TextFormField(
                        initialValue: "120",
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    children: [
                      const Text("🐑 Ruminants"),
                      TextFormField(
                        initialValue: "120",
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    children: [
                      const Text("🐖 Porcs"),
                      TextFormField(
                        initialValue: "120",
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
