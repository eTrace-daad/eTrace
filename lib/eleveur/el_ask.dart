import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Listes Cameroun
const List<String> regionsCM = [
  'Adamaoua',
  'Centre',
  'Est',
  'Extrême-Nord',
  'Littoral',
  'Nord',
  'Nord-Ouest',
  'Ouest',
  'Sud',
  'Sud-Ouest'
];

const Map<String, List<String>> departementsCM = {
  'Adamaoua': ['Djérem', 'Faro-et-Déo', 'Mbéré', 'Vina', 'Ngaoundéré'],
  'Centre': [
    'Mbam-et-Inoubou',
    'Mbam-et-Kim',
    'Méfou-et-Afamba',
    'Méfou-et-Akono',
    'Nyong-et-Kéllé',
    'Nyong-et-Mfoumou',
    'Nyong-et-So'
  ],
  'Est': ['Boumba-et-Ngoko', 'Haut-Nyong', 'Kadey', 'Lom-et-Djérem'],
  'Extrême-Nord': [
    'Diamaré',
    'Logone-et-Chari',
    'Mayo-Danay',
    'Mayo-Kani',
    'Mayo-Sava',
    'Mayo-Tsanaga'
  ],
  'Littoral': ['Moungo', 'Nkam', 'Sanaga-Maritime', 'Wouri'],
  'Nord': ['Bénoué', 'Faro', 'Mayo-Louti', 'Mayo-Rey'],
  'Nord-Ouest': [
    'Boyo',
    'Bui',
    'Donga-Mantung',
    'Menchum',
    'Momo',
    'Ngoketunjia',
    'Mezam'
  ],
  'Ouest': [
    'Bamboutos',
    'Hauts-Plateaux',
    'Koung-Khi',
    'Ménoua',
    'Mifi',
    'Ndé',
    'Noun'
  ],
  'Sud': ['Dja-et-Lobo', 'Mvila', 'Océan', 'Vallée-du-Ntem'],
  'Sud-Ouest': [
    'Fako',
    'Koupé-Manengouba',
    'Lebialem',
    'Manyu',
    'Meme',
    'Ndian'
  ],
};

const Map<String, List<String>> villesCM = {
  'Adamaoua': ['Ngaoundéré', 'Meiganga', 'Tignère'],
  'Centre': ['Yaoundé', 'Bafia', 'Mbalmayo'],
  'Est': ['Bertoua', 'Batouri', 'Abong-Mbang'],
  'Extrême-Nord': ['Maroua', 'Kousséri', 'Mora'],
  'Littoral': ['Douala', 'Nkongsamba', 'Edéa'],
  'Nord': ['Garoua', 'Faro', 'Guider'],
  'Nord-Ouest': ['Bamenda', 'Kumbo', 'Ndop'],
  'Ouest': ['Bafoussam', 'Dschang', 'Foumban'],
  'Sud': ['Ebolowa', 'Kribi', 'Sangmélima'],
  'Sud-Ouest': ['Limbe', 'Buea', 'Kumba'],
};

class ElAsksQR extends StatefulWidget {
  const ElAsksQR({super.key});

  @override
  State<ElAsksQR> createState() => _ElAsksQRState();
}

class _ElAsksQRState extends State<ElAsksQR> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController nombreQRController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedRegion;
  String? selectedDepartement;
  String? selectedVille;

  List<PlatformFile> piecesJointes = [];
  bool _isLoading = false;
  bool _isUploading = false;

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
    nombreQRController.dispose();
    descriptionController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _importPieceJointe() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          piecesJointes.addAll(result.files);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${result.files.length} fichier(s) ajouté(s)"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de l'import : ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<String>> _uploadFiles() async {
    if (piecesJointes.isEmpty) return [];

    setState(() => _isUploading = true);
    final List<String> downloadUrls = [];

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      for (final file in piecesJointes) {
        final ref = _storage.ref().child(
            'eleveurs/${user.uid}/demandes_qr/${DateTime.now().millisecondsSinceEpoch}_${file.name}');
        final uploadTask = ref.putData(file.bytes!);
        final snapshot = await uploadTask;
        final url = await snapshot.ref.getDownloadURL();
        downloadUrls.add(url);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur d'upload : ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUploading = false);
    }

    return downloadUrls;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir tous les champs obligatoires."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedRegion == null ||
        selectedDepartement == null ||
        selectedVille == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Veuillez sélectionner la région, le département et la ville."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      // Upload des pièces jointes
      final piecesJointesUrls = await _uploadFiles();

      // Enregistrement de la demande dans Firestore
      final demandeRef = _firestore
          .collection('eleveurs')
          .doc(user.uid)
          .collection('demandes')
          .doc();

      await demandeRef.set({
        'id': demandeRef.id,
        'eleveurId': user.uid,
        'eleveurNom': user.displayName ?? 'Nom non renseigné',
        'eleveurEmail': user.email,
        'region': selectedRegion,
        'departement': selectedDepartement,
        'ville': selectedVille,
        'nombreQR': int.parse(nombreQRController.text),
        'description': descriptionController.text,
        //'piecesJointes': piecesJointesUrls,
        'statut': 'en_attente', // en_attente, approuvee, rejetee
        'dateCreation': FieldValue.serverTimestamp(),
        'dateTraitement': null,
        'traitePar': null,
        'commentaire': null,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Demande de QR code envoyée avec succès."),
          backgroundColor: Colors.green,
        ),
      );

      // Réinitialisation du formulaire
      _formKey.currentState?.reset();
      nombreQRController.clear();
      descriptionController.clear();
      setState(() {
        selectedRegion = null;
        selectedDepartement = null;
        selectedVille = null;
        piecesJointes.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de l'envoi : ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtrage dynamique des villes et départements selon la région
    final departements =
        selectedRegion != null ? departementsCM[selectedRegion!] ?? [] : [];
    final villes =
        selectedRegion != null ? villesCM[selectedRegion!] ?? [] : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Demande de QR Code"),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Color(0xFF1976D2)),
        titleTextStyle: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: const Color(0xFF1976D2)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Form(
              key: _formKey,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text("Informations du champ",
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blueGrey.shade700)),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedRegion,
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.map, color: Color(0xff4B5563)),
                        hintText: "Région",
                        filled: true,
                        fillColor: const Color(0xfff5f5f5),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: regionsCM
                          .map(
                              (r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          selectedRegion = v;
                          selectedDepartement = null;
                          selectedVille = null;
                        });
                      },
                      validator: (v) =>
                          v == null || v.isEmpty ? "Région obligatoire" : null,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedDepartement,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.account_tree,
                            color: Color(0xff4B5563)),
                        hintText: "Département",
                        filled: true,
                        fillColor: const Color(0xfff5f5f5),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: departements
                          .map<DropdownMenuItem<String>>((d) =>
                              DropdownMenuItem<String>(
                                  value: d, child: Text(d)))
                          .toList(),
                      onChanged: (v) => setState(() => selectedDepartement = v),
                      validator: (v) => v == null || v.isEmpty
                          ? "Département obligatoire"
                          : null,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedVille,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.location_city,
                            color: Color(0xff4B5563)),
                        hintText: "Ville",
                        filled: true,
                        fillColor: const Color(0xfff5f5f5),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: villes
                          .map((v) => DropdownMenuItem<String>(
                              value: v, child: Text(v)))
                          .toList(),
                      onChanged: (v) => setState(() => selectedVille = v),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Ville obligatoire" : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: nombreQRController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.qr_code, color: Color(0xff4B5563)),
                        hintText: "Nombre de QR codes souhaités",
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
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.info_outline,
                            color: Color(0xff4B5563)),
                        hintText: "Description ou motif de la demande",
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
                    const SizedBox(height: 16),
                    Text("Pièces jointes (justificatif, photo, etc.)",
                        style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _isLoading ? null : _importPieceJointe,
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
                              Icon(Icons.attach_file,
                                  color: Colors.grey, size: 28),
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
                                    label: Text(f.name),
                                    onDeleted: _isLoading
                                        ? null
                                        : () => setState(() =>
                                            piecesJointes.removeWhere(
                                                (e) => e.name == f.name)),
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
                        icon: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Icon(Icons.check_circle_outline,
                                size: 24, color: Colors.white),
                        label: Text(
                          _isLoading
                              ? "Envoi en cours..."
                              : "Envoyer la demande",
                          style: const TextStyle(
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
                        onPressed: _isLoading ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isUploading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      "Upload des fichiers...",
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/*import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';

// Listes Cameroun
const List<String> regionsCM = [
  'Adamaoua',
  'Centre',
  'Est',
  'Extrême-Nord',
  'Littoral',
  'Nord',
  'Nord-Ouest',
  'Ouest',
  'Sud',
  'Sud-Ouest'
];

const Map<String, List<String>> departementsCM = {
  'Adamaoua': ['Djérem', 'Faro-et-Déo', 'Mbéré', 'Vina', 'Ngaoundéré'],
  'Centre': [
    'Mbam-et-Inoubou',
    'Mbam-et-Kim',
    'Méfou-et-Afamba',
    'Méfou-et-Akono',
    'Nyong-et-Kéllé',
    'Nyong-et-Mfoumou',
    'Nyong-et-So'
  ],
  'Est': ['Boumba-et-Ngoko', 'Haut-Nyong', 'Kadey', 'Lom-et-Djérem'],
  'Extrême-Nord': [
    'Diamaré',
    'Logone-et-Chari',
    'Mayo-Danay',
    'Mayo-Kani',
    'Mayo-Sava',
    'Mayo-Tsanaga'
  ],
  'Littoral': ['Moungo', 'Nkam', 'Sanaga-Maritime', 'Wouri'],
  'Nord': ['Bénoué', 'Faro', 'Mayo-Louti', 'Mayo-Rey'],
  'Nord-Ouest': [
    'Boyo',
    'Bui',
    'Donga-Mantung',
    'Menchum',
    'Momo',
    'Ngoketunjia',
    'Mezam'
  ],
  'Ouest': [
    'Bamboutos',
    'Hauts-Plateaux',
    'Koung-Khi',
    'Ménoua',
    'Mifi',
    'Ndé',
    'Noun'
  ],
  'Sud': ['Dja-et-Lobo', 'Mvila', 'Océan', 'Vallée-du-Ntem'],
  'Sud-Ouest': [
    'Fako',
    'Koupé-Manengouba',
    'Lebialem',
    'Manyu',
    'Meme',
    'Ndian'
  ],
};

const Map<String, List<String>> villesCM = {
  'Adamaoua': ['Ngaoundéré', 'Meiganga', 'Tignère'],
  'Centre': ['Yaoundé', 'Bafia', 'Mbalmayo'],
  'Est': ['Bertoua', 'Batouri', 'Abong-Mbang'],
  'Extrême-Nord': ['Maroua', 'Kousséri', 'Mora'],
  'Littoral': ['Douala', 'Nkongsamba', 'Edéa'],
  'Nord': ['Garoua', 'Faro', 'Guider'],
  'Nord-Ouest': ['Bamenda', 'Kumbo', 'Ndop'],
  'Ouest': ['Bafoussam', 'Dschang', 'Foumban'],
  'Sud': ['Ebolowa', 'Kribi', 'Sangmélima'],
  'Sud-Ouest': ['Limbe', 'Buea', 'Kumba'],
};

class ElAsksQR extends StatefulWidget {
  const ElAsksQR({super.key});

  @override
  State<ElAsksQR> createState() => _ElAsksQRState();
}

class _ElAsksQRState extends State<ElAsksQR> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  //final TextEditingController nomChampController = TextEditingController();
  final TextEditingController nombreQRController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedRegion;
  String? selectedDepartement;
  String? selectedVille;

  List<String> piecesJointes = [];

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
    //nomChampController.dispose();
    nombreQRController.dispose();
    descriptionController.dispose();
    _fadeController.dispose();
    super.dispose();
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
      if (selectedRegion == null ||
          selectedDepartement == null ||
          selectedVille == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Veuillez sélectionner la région, le département et la ville."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Demande de QR code envoyée avec succès.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
      // TODO: Envoyer les données vers l'API ici
      _formKey.currentState?.reset();
      //nomChampController.clear();
      nombreQRController.clear();
      descriptionController.clear();
      setState(() {
        selectedRegion = null;
        selectedDepartement = null;
        selectedVille = null;
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
    // Filtrage dynamique des villes et départements selon la région
    final departements =
        selectedRegion != null ? departementsCM[selectedRegion!] ?? [] : [];
    final villes =
        selectedRegion != null ? villesCM[selectedRegion!] ?? [] : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Demande de QR Code"),
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
                Text("Informations du champ",
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blueGrey.shade700)),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedRegion,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.map, color: Color(0xff4B5563)),
                    hintText: "Région",
                    filled: true,
                    fillColor: const Color(0xfff5f5f5),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: regionsCM
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedRegion = v;
                      selectedDepartement = null;
                      selectedVille = null;
                    });
                  },
                  validator: (v) =>
                      v == null || v.isEmpty ? "Région obligatoire" : null,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedDepartement,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.account_tree,
                        color: Color(0xff4B5563)),
                    hintText: "Département",
                    filled: true,
                    fillColor: const Color(0xfff5f5f5),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: departements
                      .map<DropdownMenuItem<String>>((d) =>
                          DropdownMenuItem<String>(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedDepartement = v),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Département obligatoire" : null,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedVille,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_city,
                        color: Color(0xff4B5563)),
                    hintText: "Ville",
                    filled: true,
                    fillColor: const Color(0xfff5f5f5),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: villes
                      .map((v) =>
                          DropdownMenuItem<String>(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedVille = v),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Ville obligatoire" : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: nombreQRController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.qr_code, color: Color(0xff4B5563)),
                    hintText: "Nombre de QR codes souhaités",
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
                TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.info_outline,
                        color: Color(0xff4B5563)),
                    hintText: "Description ou motif de la demande",
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
                const SizedBox(height: 16),
                Text("Pièces jointes (justificatif, photo, etc.)",
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
                      "Envoyer la demande",
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
}*/
