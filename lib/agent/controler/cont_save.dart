import 'package:etrace/appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContSave extends StatelessWidget {
  const ContSave({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: Colors.white,
      ),
      child: ContSaveScreen(),
    );
  }
}

class ContSaveScreen extends StatefulWidget {
  final String? code;
  final Map<String, dynamic>? owner;
  final Map<String, dynamic>? bovinData;
  final String? dateScan;

  const ContSaveScreen({
    Key? key,
    this.code,
    this.owner,
    this.bovinData,
    this.dateScan,
  }) : super(key: key);

  @override
  _ContSaveScreenState createState() => _ContSaveScreenState();

  // Factory pour récupérer les infos depuis GoRouter
  static ContSaveScreen fromGoRouter(BuildContext context) {
    final state = GoRouterState.of(context);
    final extra = state.extra as Map<String, dynamic>? ?? {};
    return ContSaveScreen(
      code: extra['code'] as String?,
      owner: extra['owner'] as Map<String, dynamic>?,
      bovinData: extra['bovinData'] as Map<String, dynamic>?,
      dateScan: extra['dateScan'] as String?,
    );
  }
}

class _ContSaveScreenState extends State<ContSaveScreen> {
  final _formKey = GlobalKey<FormState>();

  bool autoGenerateCode = true;
  bool useQRCode = true;

  String generatedCode = "";
  String? manualCode;
  String? bovinName;
  String? sexe;
  String? race;
  String? autreRace;
  DateTime? birthDate;
  String? birthPlace;
  String? idMethod;

  List<String> races = ['Race zébu', 'Race taurine', 'Race métisse', 'Autre'];
  List<String> usedCodes = ["BOV-20250501-ABCD"]; // Simule une base locale

  @override
  void initState() {
    super.initState();
    if (widget.code != null) {
      generatedCode = widget.code!;
    }
    if (widget.owner != null) {
      // Par exemple, tu peux pré-remplir le propriétaire ou afficher une carte animée
    }
    _generateCode();
  }

  void _generateCode() {
    final now = DateTime.now();
    final rand = Random().nextInt(9999).toString().padLeft(4, '0');
    setState(() {
      generatedCode = 'BOV-${DateFormat('yyyyMMdd').format(now)}-$rand';
    });
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (autoGenerateCode == false &&
        manualCode != null &&
        usedCodes.contains(manualCode)) {
      _showErrorDialog(
          "Ce code d'identification existe déjà. Vérifiez l'animal ou essayez un autre code.");
      return;
    }
    if (useQRCode == false && (manualCode == null || manualCode!.isEmpty)) {
      _showErrorDialog("Veuillez saisir un code manuel valide.");
      return;
    }
    _formKey.currentState!.save();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("🐄 Bovin enregistré avec succès !"),
      backgroundColor: Colors.green[700],
    ));
    //Navigator.pop(context);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Erreur"),
        content: Text(message),
        actions: [
          TextButton(
            child: Text("Vérifier l'animal"),
            onPressed: () => Navigator.of(ctx).pop(),
          )
        ],
      ),
    );
  }

  final List<Map<String, String>> raceCards = [
    {
      'label': 'Race zébu',
      'image': 'assets/images/zebu.png', // Mets tes propres images ici
    },
    {
      'label': 'Race taurine',
      'image': 'assets/images/taurine.png',
    },
    {
      'label': 'Race métisse',
      'image': 'assets/images/metisse.png',
    },
    {
      'label': 'Autre',
      'image': 'assets/images/autre.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final paletteTerre = Color(0xFF8B5E3C);
    //final paletteSavane = Color(0xFF5A8C49);

    return Scaffold(
      appBar: SoftAppBar(
        title: "Enregistrement d'un bovin",
        actions: [Icon(Icons.settings_outlined)],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.owner != null) ...[
                Text(
                  "Propriétaire du bovin",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 8),
              ],
              if (widget.owner != null) ...[
                SizedBox(height: 8),
                AnimatedContainer(
                  duration: Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.shade100.withOpacity(0.2),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(18),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(0xff4a7b58).withOpacity(.5),
                        child: Icon(Icons.person, color: Colors.white),
                        radius: 28,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.owner?['nom'] ?? "-",
                                style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                            Text(widget.owner?['contact'] ?? "-",
                                style: GoogleFonts.nunito(
                                    fontSize: 15,
                                    color: Colors.blueGrey.shade400)),
                            Text(widget.owner?['adresse'] ?? "-",
                                style: GoogleFonts.nunito(
                                    fontSize: 15,
                                    color: Colors.blueGrey.shade400)),
                            Text("ID: ${widget.owner?['identifiant'] ?? '-'}",
                                style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    color: Colors.blueGrey.shade300)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 16),
              Text(
                  "Ajoutez les informations officielles de l'animal et son code QR unique d'identification.",
                  style: TextStyle(
                      color: Color(0xff4B5563),
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
              SizedBox(height: 20),

              // Code d'identification
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xfff5f5f5),
                  borderRadius: BorderRadius.circular(12),
                  /*boxShadow: [
                    BoxShadow(
                      color: Colors.green.shade100.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],*/
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.refresh, color: Color(0x33333333)),
                            SizedBox(width: 12),
                            Text(
                              "Code d'identification",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0x33333333),
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Container(
                          margin: EdgeInsets.only(left: 16),
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(21),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.circle,
                                  size: 16, color: Colors.green.shade700),
                              SizedBox(width: 8),
                              Text(
                                "Auto",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      enabled: !autoGenerateCode,
                      initialValue: autoGenerateCode ? generatedCode : null,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onSaved: (val) => manualCode = val,
                      validator: (val) {
                        if (!autoGenerateCode &&
                            (val == null || val.length < 5)) {
                          return "Code trop court";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              /*Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Code d'identification",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Switch(
                    value: autoGenerateCode,
                    onChanged: (value) {
                      setState(() {
                        autoGenerateCode = value;
                        if (value) _generateCode();
                      });
                    },
                  ),
                  Text(autoGenerateCode ? "Auto" : "Manuel")
                ],
              ),*/

              /*SizedBox(height: 20),

              // Nom du bovin
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Nom du bovin (optionnel)",
                  hintText: "Ex : Bango, Mado, Simba...",
                  suffixIcon: Icon(Icons.shuffle),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onSaved: (val) => bovinName = val,
              ),*/
              SizedBox(height: 20),

              // Sexe
              Text("Sexe",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              /*Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                        color: sexe == null ? Colors.red : Colors.black,
                      ),

                      //margin: EdgeInsets.only(right: 10),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: RadioListTile<String>(
                        title: Text("🐂 Mâle"),
                        value: "Mâle",
                        groupValue: sexe,
                        onChanged: (val) => setState(() => sexe = val),
                      ),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text("🐄 Femelle"),
                      value: "Femelle",
                      groupValue: sexe,
                      onChanged: (val) => setState(() => sexe = val),
                    ),
                  )
                ],
              ),*/
              Row(
                children: [
                  /*Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: sexe == "Mâle"
                                ? Colors.transparent
                                : Color(0xff4a7b58)),
                        borderRadius: BorderRadius.circular(12),
                        color:
                            sexe == "Mâle" ? Color(0xff4a7b58) : Colors.white,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: ListTile(
                        leading: Text(
                          "🐂 Mâle",
                          style: TextStyle(
                            color: sexe == "Mâle" ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        trailing: Radio<String>(
                          value: "Mâle",
                          activeColor: Colors.white,
                          //focusColor: Colors.white,
                          groupValue: sexe,
                          onChanged: (val) => setState(() => sexe = val),
                        ),
                        onTap: () => setState(() => sexe = "Mâle"),
                      ),
                    ),
                  ),*/
                  // ...dans la Row des sexes...
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: sexe == "Femelle"
                                ? Colors.transparent
                                : Color(0xff4a7b58)),
                        borderRadius: BorderRadius.circular(12),
                        color: sexe == "Femelle"
                            ? Color(0xff4a7b58)
                            : Colors.white,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Text(
                            "🐄 Femelle",
                            style: TextStyle(
                              color: sexe == "Femelle"
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Radio<String>(
                            value: "Femelle",
                            autofocus: false,
                            activeColor: Colors.white,
                            groupValue: sexe,
                            onChanged: (val) => setState(() => sexe = val),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  /*Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: sexe == "Femelle"
                                ? Colors.transparent
                                : Color(0xff4a7b58)),
                        borderRadius: BorderRadius.circular(12),
                        color: sexe == "Femelle"
                            ? Color(0xff4a7b58)
                            : Colors.white,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: ListTile(
                        leading: Text(
                          "🐄 Femelle",
                          style: TextStyle(
                            color:
                                sexe == "Femelle" ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        trailing: Radio<String>(
                          value: "Femelle",

                          activeColor: Colors.white,
                          groupValue: sexe,
                          onChanged: (val) => setState(() => sexe = val),
                        ),
                        onTap: () => setState(() => sexe = "Femelle"),
                      ),
                    ),
                  ),*/
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: sexe == "Mâle"
                                ? Colors.transparent
                                : Color(0xff4a7b58)),
                        borderRadius: BorderRadius.circular(12),
                        color:
                            sexe == "Mâle" ? Color(0xff4a7b58) : Colors.white,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Text(
                            "🐂 Mâle",
                            style: TextStyle(
                              color:
                                  sexe == "Mâle" ? Colors.white : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Radio<String>(
                            value: "Mâle",
                            autofocus: true,
                            activeColor: Colors.white,
                            groupValue: sexe,
                            onChanged: (val) => setState(() => sexe = val),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (sexe == null)
                Text("⚠️ Champ obligatoire",
                    style: TextStyle(color: Colors.red)),
              SizedBox(height: 20),

              // Race
              /*Text("Race",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: races.map((r) {
                  return ChoiceChip(
                    label: Text(r),
                    selected: race == r,
                    onSelected: (_) => setState(() => race = r),
                  );
                }).toList(),
              ),
              if (race == 'Autre')
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: "Précisez la race"),
                    onSaved: (val) => autreRace = val,
                  ),
                ),*/
              // ...existing code...
// Race
              /*Text("Race",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: raceCards.map((raceCard) {
                  final isSelected = race == raceCard['label'];
                  return GestureDetector(
                    onTap: () => setState(() => race = raceCard['label']),
                    child: Container(
                      width: 90,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color(0xFF5A8C49).withOpacity(0.15)
                            : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? Color(0xFF5A8C49)
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: Color(0xFF5A8C49).withOpacity(0.1),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                        ],
                      ),
                      padding: EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Image.asset(
                            raceCard['image']!,
                            height: 48,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: 8),
                          Text(
                            raceCard['label']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Color(0xFF5A8C49)
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
// Champ "Précisez la race" si "Autre"
              if (race == 'Autre')
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: "Précisez la race"),
                    onSaved: (val) => autreRace = val,
                  ),
                ),*/
              // ...existing code...
              Text("Race",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              SizedBox(
                //height:
                //520, // Ajuste selon le nombre de races et la taille des images
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: raceCards.length,
                  itemBuilder: (context, index) {
                    final raceCard = raceCards[index];
                    final isSelected = race == raceCard['label'];
                    return GestureDetector(
                      onTap: () => setState(() => race = raceCard['label']),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(0xFF5A8C49).withOpacity(0.10)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border(
                            bottom: isSelected
                                ? BorderSide(
                                    color: Color(0xFF5A8C49),
                                    width: 4,
                                  )
                                : BorderSide.none,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        //padding: EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  raceCard['image']!,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            /*Image.asset(
                              raceCard['image']!,
                              //height: 56,
                              fit: BoxFit.contain,
                            ),*/
                            SizedBox(height: 12),
                            Text(
                              raceCard['label']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Color(0xFF5A8C49)
                                    : Colors.black87,
                              ),
                            ),
                            SizedBox(height: 12),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
// Champ "Précisez la race" si "Autre"
              if (race == 'Autre')
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: "Précisez la race"),
                    onSaved: (val) => autreRace = val,
                  ),
                ),
// ...existing code...
// ...existing code...
              SizedBox(height: 20),

              // Date de naissance
              Text("Date de naissance",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => birthDate = picked);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xfff5f5f5)),
                    color: Color(0xfff5f5f5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(FontAwesomeIcons.calendarAlt,
                          color: Color(0xff4B5563)),
                      SizedBox(width: 8),
                      Text(
                          birthDate == null
                              ? "Sélectionner une date"
                              : DateFormat('dd/MM/yyyy').format(birthDate!),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xff4B5563),
                            fontSize: 16,
                          )),
                      SizedBox(width: 8),
                      Icon(FontAwesomeIcons.angleDown,
                          size: 16, // Ajuste la taille de l'icône si nécessaire
                          color: Color(0xff4B5563)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Lieu de naissance
              Text("Lieu de naissance",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  hintText: "Ex : Ferme Ngomeka, Bertoua...",
                  prefixIcon: Icon(FontAwesomeIcons.locationCrosshairs,
                      color: Color(0xff4B5563)),
                  suffixIcon: Icon(FontAwesomeIcons.angleDown,
                      size: 16, // Ajuste la taille de l'icône si nécessaire
                      color: Color(0xff4B5563)),
                  filled: true,
                  fillColor: Color(0xfff5f5f5),
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12)),
                ),
                onSaved: (val) => birthPlace = val,
              ),
              SizedBox(height: 20),

              /*// Moyen d’identification
              Text("Moyen d’identification",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: idMethod == "qrCode"
                                ? Colors.transparent
                                : Color(0xff4a7b58)),
                        borderRadius: BorderRadius.circular(12),
                        color: idMethod == "qrCode"
                            ? Color(0xff4a7b58)
                            : Colors.white,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.qrcode,
                              color: idMethod == "qrCode"
                                  ? Colors.white
                                  : Colors.black),
                          Text(
                            "QR Code",
                            style: TextStyle(
                              color: idMethod == "qrCode"
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Radio<String>(
                            value: "qrCode",
                            activeColor: Colors.white,
                            groupValue: sexe,
                            onChanged: (val) => setState(() => sexe = val),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: idMethod == "manual"
                                ? Colors.transparent
                                : Color(0xff4a7b58)),
                        borderRadius: BorderRadius.circular(12),
                        color: idMethod == "manual"
                            ? Color(0xff4a7b58)
                            : Colors.white,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Text(
                            "Code manuel",
                            style: TextStyle(
                              color: idMethod == "manual"
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Radio<String>(
                            value: "manual",
                            activeColor: Colors.white,
                            groupValue: idMethod,
                            onChanged: (val) => setState(() => idMethod = val),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: Text("📷 Scan QR"),
                      value: true,
                      groupValue: useQRCode,
                      onChanged: (val) => setState(() => useQRCode = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: Text("✍️ Code manuel"),
                      value: false,
                      groupValue: useQRCode,
                      onChanged: (val) => setState(() => useQRCode = val!),
                    ),
                  )
                ],
              ),

              if (!useQRCode)
                TextFormField(
                  decoration: InputDecoration(labelText: "Entrer un code"),
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Code requis";
                    return null;
                  },
                  onSaved: (val) => manualCode = val,
                ),*/

              SizedBox(height: 30),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5A8C49), Color(0xFFAC6E3F)],
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: ElevatedButton.icon(
          icon: Icon(Icons.check_circle, color: Colors.white),
          label: Text("Enregistrer ce bovin"),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: _submitForm,
        ),
      ),
    );
  }
}
