import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';

class DeclarationVolScreen extends StatefulWidget {
  const DeclarationVolScreen({super.key});

  @override
  State<DeclarationVolScreen> createState() => _DeclarationVolScreenState();
}

class _DeclarationVolScreenState extends State<DeclarationVolScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Champs bovin volé
  //final TextEditingController codeBovinController = TextEditingController();
  //final TextEditingController nomBovinController = TextEditingController();
  final TextEditingController nombreBovinController = TextEditingController();
  final TextEditingController lieuVolController = TextEditingController();
  final TextEditingController circonstancesController = TextEditingController();

  //String? _selectedSexe;
  DateTime? _selectedDate;
  bool plainteDeposee = false;
  List<String> piecesJointes = [];

  // Animation
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    //codeBovinController.dispose();
    //nomBovinController.dispose();
    nombreBovinController.dispose();
    lieuVolController.dispose();
    circonstancesController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _importPieceJointe() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          piecesJointes.add(file.name);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Pièce jointe ajoutée : ${file.name}"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de l'import : $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Veuillez choisir la date du vol."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Déclaration de vol envoyée au MINEPIA avec succès.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
      // TODO: Envoyer les données vers l'API MINEPIA ici
      _formKey.currentState?.reset();
      //codeBovinController.clear();
      //nomBovinController.clear();
      nombreBovinController.clear();
      lieuVolController.clear();
      circonstancesController.clear();
      setState(() {
        //_selectedSexe = null;
        _selectedDate = null;
        plainteDeposee = false;
        piecesJointes.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez remplir tous les champs obligatoires.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Déclaration de vol de bovin"),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Color(0xFF1976D2)),
        titleTextStyle: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: const Color(0xFF1976D2)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Form(
          key: _formKey,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text("Informations sur le vol",
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blueGrey.shade700)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: nombreBovinController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.numbers, color: Color(0xff4B5563)),
                    hintText: "Nombre de bovins volés",
                    filled: true,
                    fillColor: const Color(0xfff5f5f5),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return "Nombre obligatoire";
                    }
                    final n = int.tryParse(v);
                    if (n == null || n <= 0) {
                      return "Entrez un nombre valide";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: TextEditingController(
                        text: _selectedDate == null
                            ? ""
                            : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.calendar_today,
                            color: Color(0xff4B5563)),
                        hintText: "Date du vol",
                        filled: true,
                        fillColor: const Color(0xfff5f5f5),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(12)),
                        suffixIcon: const Icon(Icons.date_range,
                            color: Color(0xff4B5563)),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? "Date obligatoire"
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: lieuVolController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_on_outlined,
                        color: Color(0xff4B5563)),
                    hintText: "Lieu du vol",
                    filled: true,
                    fillColor: const Color(0xfff5f5f5),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? "Lieu obligatoire" : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: circonstancesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.info_outline,
                        color: Color(0xff4B5563)),
                    hintText: "Circonstances du vol (description)",
                    filled: true,
                    fillColor: const Color(0xfff5f5f5),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? "Description obligatoire"
                      : null,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text("Avez-vous porté plainte ?",
                      style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: plainteDeposee
                              ? Colors.green
                              : Colors.grey.shade200,
                          foregroundColor:
                              plainteDeposee ? Colors.white : Colors.black,
                        ),
                        onPressed: () => setState(() => plainteDeposee = true),
                        child: const Text("Oui"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !plainteDeposee
                              ? Colors.red
                              : Colors.grey.shade200,
                          foregroundColor:
                              !plainteDeposee ? Colors.white : Colors.black,
                        ),
                        onPressed: () => setState(() => plainteDeposee = false),
                        child: const Text("Non"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text("Pièces jointes (plainte, photo, etc.)",
                    style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _importPieceJointe,
                  child: DottedBorder(
                    color: Colors.grey,
                    strokeWidth: 2,
                    dashPattern: [6, 4],
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(12),
                    child: Container(
                      width: double.infinity,
                      height: 70,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.attach_file, color: Colors.grey, size: 28),
                          Text("Importer un fichier",
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
                if (piecesJointes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Wrap(
                      spacing: 8,
                      children: piecesJointes
                          .map((f) => Chip(
                                backgroundColor: Colors.green.shade50,
                                avatar: const Icon(Icons.attach_file),
                                label: Text(f),
                                onDeleted: () => setState(() =>
                                    piecesJointes.removeWhere((e) => e == f)),
                              ))
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
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
                      "Envoyer la déclaration",
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
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
