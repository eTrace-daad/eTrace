import 'dart:async';
import 'dart:math';
import 'package:etrace/appbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lottie/lottie.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class ContEvent extends StatelessWidget {
  const ContEvent({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: Colors.white,
      ),
      child: ContEventScreen(),
    );
  }
}

class ContEventScreen extends StatefulWidget {
  final String? code;
  final Map<String, dynamic>? owner;
  final Map<String, dynamic>? bovinData;
  final String? dateScan;

  const ContEventScreen({
    Key? key,
    this.code,
    this.owner,
    this.bovinData,
    this.dateScan,
  }) : super(key: key);

  @override
  _ContEventScreenState createState() => _ContEventScreenState();

  // Factory pour récupérer les infos depuis GoRouter
  static ContEventScreen fromGoRouter(BuildContext context) {
    final state = GoRouterState.of(context);
    final extra = state.extra as Map<String, dynamic>? ?? {};
    return ContEventScreen(
      code: extra['code'] as String?,
      owner: extra['owner'] as Map<String, dynamic>?,
      bovinData: extra['bovinData'] as Map<String, dynamic>?,
      dateScan: extra['dateScan'] as String?,
    );
  }
}

class _ContEventScreenState extends State<ContEventScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  bool autoGenerateCode = true;
  bool useQRCode = true;

  // Ajout des controllers pour tous les champs éditables
  final TextEditingController codeController = TextEditingController();
  final TextEditingController bovinNameController = TextEditingController();
  final TextEditingController birthPlaceController = TextEditingController();

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

  bool isScanning = false;
  bool isLoading = false;
  String? scanError;
  bool isFakeAlertSent = false;
  Map<String, dynamic>? scannedBovinData;
  Map<String, dynamic>? scannedOwnerData;

  // Ajoute ces variables si tu veux exploiter toutes les infos du bovin et du propriétaire
  String? statutSanitaire;
  String? statutMouvement;
  String? lastVet;
  List<dynamic>? vaccinations;
  List<dynamic>? alertes;

// Pour le propriétaire (si tu veux les champs séparés)
  String? ownerName;
  String? ownerContact;
  String? ownerAdresse;
  String? ownerIdentifiant;

  static const String _aesKey =
      'votre_cle_secrete_32caracteres!!'; // 32 caractères
  static const String _aesIV = '16caracteresiv12'; // 16 caractères

  // Animation controllers
  late AnimationController _fadeSlideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Ajoute ces variables pour les champs dynamiques
  final _venteFormKey = GlobalKey<FormState>();
  final _volFormKey = GlobalKey<FormState>();
  final _decesFormKey = GlobalKey<FormState>();

// Vente
  DateTime? venteDate;
  String? acheteurNom;
  String? acheteurContact;
  String? motifVente;
  String? remarqueVente;

// Vol
  DateTime? volDate;
  String? dernierLieuObserve;
  bool? plainteDeposee;
  List<String> piecesJointes = [];
  String? circonstancesVol;
  bool bovinDisparu = false;

// Décès
  DateTime? decesDate;
  String? lieuDeces;
  String? causeDeces;
  String? observationsDeces;
  bool interventionVet = false;

  // Pour la sélection du type d'évènement
  String? selectedEventType;

  // Liste des types d'évènements
  final List<Map<String, dynamic>> eventTypes = [
    {
      'label': 'Vente',
      'icon': Icons.sell,
      'value': 'vente',
    },
    {
      'label': 'Vol',
      'icon': Icons.warning_amber_rounded,
      'value': 'vol',
    },
    {
      'label': 'Décès',
      'icon': Icons.sentiment_very_dissatisfied,
      'value': 'deces',
    },
  ];

  String decryptData(String encryptedText) {
    final key = encrypt.Key.fromUtf8(_aesKey);
    final iv = encrypt.IV.fromUtf8(_aesIV);
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    return decrypted;
  }

  /// Simule la base de données MINEPIA pour les codes validés
  final Set<String> minepiaCodes = {
    "BOV-CEN-20250621-0001",
    "BOV-CEN-20250621-0003",
    "BOV-CEN-20250621-0004",
  };

  /// Simule la base de données interne de l'entreprise
  final Set<String> entrepriseCodes = {
    "BOV-CEN-20250621-0003",
    "BOV-CEN-20250621-0004",
  };

  Future<Map<String, dynamic>?> _fetchBovinData(String code) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (code == "BOV-CEN-20250621-0003") {
      return {
        'code': 'BOV-CEN-20250621-0003',
        'sexe': 'Femelle',
        'race': 'Gudali',
        'dateNaissance': '02/03/2023',
        'lieuNaissance': 'Meiganga',
        'identifiant': '0xA1B2C3D4E5F6',
        'lastVet': '24/05/2025',
        'statutSanitaire': 'Conforme',
        'statutMouvement': 'En transit',
        'proprietaire': {
          'nom': 'M. Tchoumi Jean',
          'contact': '+237 690 123 456',
          'adresse': 'Meiganga, Adamaoua',
          'identifiant': 'ELV-2023-001',
        },
        'vaccinations': [
          {'nom': 'Fièvre aphteuse', 'date': '12/01/2024', 'valide': true},
          {'nom': 'Brucellose', 'date': '15/02/2024', 'valide': true},
        ],
        'alertes': [],
      };
    }
    if (code == "BOV-CEN-20250621-0004") {
      return {
        'code': 'BOV-CEN-20250621-0004',
        'sexe': 'Mâle',
        'race': 'Brahman',
        'dateNaissance': '10/01/2022',
        'lieuNaissance': 'Ngaoundéré',
        'identifiant': '0xB1C2D3E4F5A6',
        'lastVet': '01/06/2025',
        'statutSanitaire': 'Rechute',
        'statutMouvement': 'En alerte',
        'proprietaire': {
          'nom': 'Mme. Nguimfack Rose',
          'contact': '+237 699 987 654',
          'adresse': 'Ngaoundéré, Adamaoua',
          'identifiant': 'ELV-2022-002',
        },
        'vaccinations': [
          {'nom': 'Fièvre aphteuse', 'date': '10/01/2024', 'valide': false},
          {'nom': 'Brucellose', 'date': '15/02/2024', 'valide': true},
        ],
        'alertes': [
          {
            'type': 'Sanitaire',
            'message': 'Suspicion de maladie',
            'date': '10/06/2025'
          }
        ],
      };
    }
    if (code == "BOV-CEN-20250621-0001") {
      return {
        'code': 'BOV-CEN-20250621-0001',
        'proprietaire': {
          'nom': 'M. Kamga Paul',
          'contact': '+237 655 123 789',
          'adresse': 'Bafia, Centre',
          'identifiant': 'ELV-2025-003',
        },
        'isNewBovin': true,
      };
    }
    return null;
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

  @override
  void initState() {
    super.initState();
    // ...tes init...
    _fadeSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeSlideController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeSlideController,
      curve: Curves.easeOutCubic,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeSlideController.forward();
    });

    if (widget.code != null) {
      generatedCode = widget.code!;
    }
    if (widget.owner != null) {
      _updateOwnerFields(widget.owner!);
    }
    _generateCode();
    plainteDeposee = false;
  }

  @override
  void dispose() {
    codeController.dispose();
    bovinNameController.dispose();
    birthPlaceController.dispose();

    super.dispose();
  }

  void _generateCode() {
    final now = DateTime.now();
    final rand = Random().nextInt(9999).toString().padLeft(4, '0');
    if (!mounted) return;
    setState(() {
      generatedCode = 'BOV-${DateFormat('yyyyMMdd').format(now)}-$rand';
    });
  }

  // Met à jour les champs propriétaire (et controllers)
  void _updateOwnerFields(Map<String, dynamic> owner) {
    ownerName = owner['nom'];
    ownerContact = owner['contact'];
    ownerAdresse = owner['adresse'];
    ownerIdentifiant = owner['identifiant'];
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
    /*_formKey.currentState!.save();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("🐄 Bovin enregistré avec succès !"),
      backgroundColor: Colors.green[700],
    ));*/
    if (isFalsifiedCode || isNewBovinDialogShown) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          isFalsifiedCode
              ? "Impossible de déclarer un évènement sur un code falsifié."
              : "Impossible de déclarer un évènement sur un nouveau bovin. Veuillez l'enregistrer d'abord.",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
      return;
    }
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Veuillez remplir tous les champs obligatoires."),
        backgroundColor: Colors.red,
      ));
      return;
    }
    // Validation des forms dynamiques
    bool valid = true;
    if (selectedEventType == 'vente') {
      valid = _venteFormKey.currentState?.validate() ?? false;
      if (venteDate == null) valid = false;
    } else if (selectedEventType == 'vol') {
      valid = _volFormKey.currentState?.validate() ?? false;
      if (volDate == null) valid = false;
      if (plainteDeposee == null) valid = false;
    } else if (selectedEventType == 'deces') {
      valid = _decesFormKey.currentState?.validate() ?? false;
      if (decesDate == null) valid = false;
    }
    if (!valid) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Veuillez remplir tous les champs obligatoires."),
        backgroundColor: Colors.red,
      ));
      return;
    }
    _formKey.currentState!.save();
    if (selectedEventType == 'vente') _venteFormKey.currentState!.save();
    if (selectedEventType == 'vol') _volFormKey.currentState!.save();
    if (selectedEventType == 'deces') _decesFormKey.currentState!.save();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("🐄 Evènement déclaré avec succès !"),
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

  // 4. Ajoute la méthode pour afficher le dialog "nouveau bovin"
  void _showNewBovinDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie/new.json',
                //height: 110,
                //repeat: false,
              ),
              //const SizedBox(height: 18),
              Text(
                "Nouveau bovin détecté",
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.orange.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Ce QR code correspond à un nouvel animal non encore enregistré. Vous devez l'enregistrer dans l'interface d'enregistrement principale.",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: Colors.brown.shade400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Text(
                "Code scanné : $code",
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: Colors.blueGrey.shade400,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  // Aller à la page principale de scan/enregistrement
                  GoRouter.of(context).go('/cont_main');
                },
                icon: Icon(Icons.qr_code_scanner, color: Colors.white),
                label: Text("Aller à l'enregistrement"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: GoogleFonts.nunito(
                      fontWeight: FontWeight.w600, fontSize: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  setState(() {
                    isScanning = false;
                    scanError = null;
                    scannedBovinData = null;
                    scannedOwnerData = null;
                    isNewBovinDialogShown = false;
                  });
                },
                icon: const Icon(Icons.close, color: Colors.red),
                label: const Text("Annuler"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  textStyle: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
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

  // ...existing code...
  void _onDetect(BarcodeCapture capture) async {
    if (isLoading) return;
    if (!mounted) return;
    setState(() {
      scanError = null;
      isLoading = true;
      isFakeAlertSent = false;
      // Synchronisation : reset à chaque scan
      isFalsifiedCode = false;
      isNewBovinDialogShown = false;
    });
    final encrypted =
        capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
    String? code;
    try {
      if (encrypted != null && encrypted.trim().isNotEmpty) {
        code = decryptData(encrypted);
      }
      if (code == null || code.trim().isEmpty) {
        if (!mounted) return;
        setState(() {
          scanError = "QR code vide ou illisible.";
          isLoading = false;
          isScanning = false;
          // Synchronisation
          isFalsifiedCode = false;
          isNewBovinDialogShown = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                const Flexible(
                    child: Text("QR code vide ou illisible.",
                        maxLines: 2, overflow: TextOverflow.ellipsis)),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      if (!minepiaCodes.contains(code)) {
        if (!mounted) return;
        setState(() {
          scanError =
              "Ce QR code n'est pas reconnu par MINEPIA et n'est pas valide. Il peut s'agir d'un code falsifié.";
          isLoading = false;
          isScanning = false;
          isFalsifiedCode = true;
          isNewBovinDialogShown = false;
          scannedBovinData = null;
          scannedOwnerData = null;
        });
        _showFalsificationDialog(code!, scanError);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning, color: Colors.white),
                const SizedBox(width: 8),
                const Flexible(
                    child: Text(
                        "Code non validé par MINEPIA. Signalement recommandé.",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis)),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      // Cas d'un code validé par MINEPIA mais pas encore dans la base entreprise
      if (!entrepriseCodes.contains(code)) {
        final data = await _fetchBovinData(code!);
        if (!mounted) return;
        if (data?['isNewBovin'] == true) {
          setState(() {
            scannedBovinData = data;
            scannedOwnerData = data?['proprietaire'];
            isLoading = false;
            isScanning = false;
            isNewBovinDialogShown = true;
            scannedBovinData = null;
            scannedOwnerData = null;
          });

          _showNewBovinDialog(code!);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info, color: Colors.white),
                  const SizedBox(width: 8),
                  const Flexible(
                      child: Text(
                          "Ce code est valide pour un nouveau bovin. Ajoutez ses informations.",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis)),
                ],
              ),
              backgroundColor: Colors.blue,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );

          return;
        }

        // Si jamais ce n'est pas un nouveau bovin, recharge normalement
        setState(() {
          scannedBovinData = data;
          scannedOwnerData = data?['proprietaire'];
          isLoading = false;
          isScanning = false;
        });
        // Recharge les infos du formulaire avec les données récupérées
        _reloadFormWithScannedData(data);
        return;
      }

      // Cas d'un code connu avec fiche complète
      final data = await _fetchBovinData(code);

      if (data == null) {
        if (!mounted) return;
        setState(() {
          scanError = "Ce QR code est inconnu ou falsifié.";
          isLoading = false;
          isScanning = false;
          isFalsifiedCode = true;
          isNewBovinDialogShown = false;
          scannedBovinData = null;
          scannedOwnerData = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                const Flexible(
                    child: Text("QR code inconnu ou falsifié.",
                        maxLines: 2, overflow: TextOverflow.ellipsis)),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }
      if (!mounted) return;
      setState(() {
        scannedBovinData = data;
        scannedOwnerData = data['proprietaire'];
        isLoading = false;
        isScanning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                  child: Text("QR code reconnu : ${data['code'] ?? ''}",
                      maxLines: 2, overflow: TextOverflow.ellipsis)),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );

      if (data?['isNewBovin'] == true) {
        if (!mounted) return;
        setState(() {
          /*scannedBovinData = data;
          scannedOwnerData = data?['proprietaire'];
          isLoading = false;
          isScanning = false;*/
          isLoading = false;
          isScanning = false;
          isFalsifiedCode = false;
          isNewBovinDialogShown = true;
          scannedBovinData = null;
          scannedOwnerData = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Ce code correspond à un nouveau bovin. Veuillez enregistrer ses informations dans l'interface d'enregistrement, pas ici.",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }
      setState(() {
        scannedBovinData = data;
        scannedOwnerData = data['proprietaire'];
        isLoading = false;
        isScanning = false;
        isFalsifiedCode = false;
        isNewBovinDialogShown = false;
      });
      _reloadFormWithScannedData(data);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        scanError = "Erreur lors du scan : ${e.toString()}";
        isLoading = false;
        isScanning = false;
        isFalsifiedCode = true;
        isNewBovinDialogShown = false;
        scannedBovinData = null;
        scannedOwnerData = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                  child: Text("Erreur lors du scan : ${e.toString()}",
                      maxLines: 2, overflow: TextOverflow.ellipsis)),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // Recharge toutes les données du scan dans les variables ET les controllers
  void _reloadFormWithScannedData(Map<String, dynamic>? data) {
    //if (data == null || ) return;
    if (data == null) return;
    if (!mounted) return;
    setState(() {
      // Données du bovin
      generatedCode = data['code'] ?? generatedCode;
      codeController.text = generatedCode;
      sexe = data['sexe'];
      race = data['race'];
      autreRace = data['autreRace'];
      //autreRaceController.text = autreRace ?? '';
      birthPlace = data['lieuNaissance'];
      birthPlaceController.text = birthPlace ?? '';
      birthDate = data['dateNaissance'] != null
          ? DateFormat('dd/MM/yyyy').parse(data['dateNaissance'])
          : null;
      idMethod = data['identifiant'];
      bovinName = data['nom'];
      bovinNameController.text = bovinName ?? '';

      statutSanitaire = data['statutSanitaire'];
      statutMouvement = data['statutMouvement'];
      lastVet = data['lastVet'];
      vaccinations = data['vaccinations'];
      alertes = data['alertes'];

      // Données du propriétaire
      if (data['proprietaire'] != null) {
        scannedOwnerData = data['proprietaire'];
        _updateOwnerFields(data['proprietaire']);
      } else {
        scannedOwnerData = null;
        _updateOwnerFields({});
      }

      scannedBovinData = data;
    });

    // Animation de succès après rechargement
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Flexible(
                  child: Text("Données du bovin chargées avec succès !")),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showFalsificationDialog(String code, String? errorMsg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie/fake.json',
                height: 110,
                repeat: false,
              ),
              const SizedBox(height: 18),
              Text(
                "QR code falsifié ou inconnu",
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.red.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                errorMsg ??
                    "Ce QR code n'est pas reconnu par MINEPIA et n'est pas valide. Il peut s'agir d'un code falsifié ou non officiel.",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: Colors.brown.shade400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Text(
                "Code scanné : $code",
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: Colors.blueGrey.shade400,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              if (!isFakeAlertSent)
                ElevatedButton.icon(
                  onPressed: () {
                    if (!mounted) return;
                    setState(() {
                      isFakeAlertSent = true;
                    });
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.send, color: Colors.white),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                "Signalement transmis à MINEPIA pour analyse et vérification.",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                    // Appel API ou email à MINEPIA ici
                  },
                  icon: const Icon(Icons.report_gmailerrorred,
                      color: Colors.white),
                  label: const Text("Signaler à MINEPIA"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD94F4F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: GoogleFonts.nunito(
                        fontWeight: FontWeight.w600, fontSize: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              if (isFakeAlertSent)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        "Signalement envoyé à MINEPIA.",
                        style: GoogleFonts.nunito(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  if (!mounted) return;
                  setState(() {
                    isScanning = false;
                    scanError = null;
                    scannedBovinData = null;
                    scannedOwnerData = null;
                  });
                },
                icon: const Icon(Icons.close, color: Colors.red),
                label: const Text("Fermer"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  textStyle: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Ajoute cette méthode pour savoir si c'est un nouveau bovin
  bool get isNewBovin =>
      scannedBovinData?['isNewBovin'] == true ||
      (scannedBovinData == null && widget.bovinData == null);

  // Pour la logique métier des types d'évènement autorisés
  List<Map<String, dynamic>> get filteredEventTypes {
    return eventTypes;
    /*if (isNewBovin) {
      return eventTypes.where((e) => e['value'] == 'naissance').toList();
    } else {
      return eventTypes.where((e) => e['value'] != 'naissance').toList();
    }*/
  }

  bool isFalsifiedCode = false;
  bool isNewBovinDialogShown = false;

  @override
  Widget build(BuildContext context) {
    final paletteTerre = Color(0xFF8B5E3C);
    //final paletteSavane = Color(0xFF5A8C49);

    // Données pour la card info bovin
    final ownerDisplay = ownerName ?? widget.owner?['nom'] ?? 'À saisir';
    final lieuDisplay =
        birthPlace ?? widget.bovinData?['lieuNaissance'] ?? 'À saisir';
    final raceDisplay = race ?? widget.bovinData?['race'] ?? 'À saisir';
    final sexeDisplay = sexe ?? widget.bovinData?['sexe'] ?? 'À saisir';

    final bool blockAll = isFalsifiedCode || isNewBovinDialogShown;

    return Scaffold(
      appBar: SoftAppBar(
        title: "Déclarer un évènement",
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

              AnimatedSwitcher(
                duration: Duration(milliseconds: 600),
                child: (ownerName != null ||
                        ownerContact != null ||
                        ownerAdresse != null)
                    ? AnimatedContainer(
                        duration: Duration(milliseconds: 500),
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
                              backgroundColor:
                                  Color(0xff4a7b58).withOpacity(.5),
                              radius: 28,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ownerName ?? "-",
                                      style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                  Text(ownerContact ?? "-",
                                      style: GoogleFonts.nunito(
                                          fontSize: 15,
                                          color: Colors.blueGrey.shade400)),
                                  Text(ownerAdresse ?? "-",
                                      style: GoogleFonts.nunito(
                                          fontSize: 15,
                                          color: Colors.blueGrey.shade400)),
                                  Text("ID: ${ownerIdentifiant ?? '-'}",
                                      style: GoogleFonts.nunito(
                                          fontSize: 14,
                                          color: Colors.blueGrey.shade300)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox.shrink(),
              ),
              SizedBox(height: 16),
              Text("Signalez un évènement important dans la vie de l'animal.",
                  style: TextStyle(
                      color: Color(0xff4B5563),
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
              SizedBox(height: 20),

              Text(
                "Scanner un bovin",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) => Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                            backgroundColor: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Scannez le QR code du bovin",
                                      style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Color(0xFF1976D2))),
                                  SizedBox(height: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Color(0xFF1976D2), width: 2.5),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    width: 250,
                                    height: 250,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: MobileScanner(
                                        fit: BoxFit.cover,
                                        onDetect: (capture) async {
                                          Navigator.of(ctx)
                                              .pop(); // Ferme le dialog dès détection
                                          await Future.delayed(const Duration(
                                              milliseconds: 200));
                                          _onDetect(capture);
                                        },
                                        controller: MobileScannerController(
                                          detectionSpeed: DetectionSpeed.normal,
                                          facing: CameraFacing.back,
                                        ),
                                        errorBuilder: (context, error, child) {
                                          return Center(
                                            child: Text(
                                              "Erreur caméra : ${error.toString()}",
                                              style: const TextStyle(
                                                  color: Colors.red),
                                              textAlign: TextAlign.center,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 18),
                                  if (scanError != null)
                                    Text(
                                      scanError!,
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: isLoading
                                            ? null
                                            : () {
                                                Navigator.of(ctx).pop();
                                                if (!mounted) return;
                                                setState(() {
                                                  scanError = null;
                                                  isFakeAlertSent = false;
                                                  scannedBovinData = null;
                                                  scannedOwnerData = null;
                                                });
                                              },
                                        icon: Icon(Icons.close,
                                            color: Color(0xFFD32F2F)),
                                        label: Text("Annuler"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFFFFEBEE),
                                          foregroundColor: Color(0xFFD32F2F),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xff4a7b58),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FontAwesomeIcons.qrcode,
                                color: Colors.white, size: 18),
                            SizedBox(width: 12),
                            Text(
                              "Scanner un QR",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xff4B5563).withOpacity(0.2),
                        ),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.rectangleList,
                              color: Color(0xff4B5563), size: 18),
                          SizedBox(width: 12),
                          Text(
                            "Selectionner",
                            style: TextStyle(
                                color: Color(0xff4B5563),
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              AnimatedSwitcher(
                duration: Duration(milliseconds: 700),
                child: Container(
                  //elevation: 6,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Color(0xff4a7b58).withOpacity(.1)),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      children: [
                        // Illustration bovin
                        Hero(
                          tag: 'bovin_illustration',
                          child: Image.asset(
                            'assets/images/taurine.png',
                            width: 160,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _infoLine("Proprio", ownerDisplay),
                              _infoLine("Lieu", lieuDisplay),
                              _infoLine("Race", raceDisplay),
                              _infoLine("Sexe", sexeDisplay),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 18),

              // --- GridView Type d'évènement ---
              //if (!blockAll) ...[
              Text(
                "Type d'évènement",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 600),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: filteredEventTypes.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: .9,
                  ),
                  itemBuilder: (context, idx) {
                    final event = filteredEventTypes[idx];
                    final isSelected = selectedEventType == event['value'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedEventType = event['value'];
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Type d'évènement sélectionné : ${event['label']}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: Colors.blue.shade700,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: AnimatedContainer(
                        width: 300,
                        duration: Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    Colors.green.shade100,
                                    Colors.green.shade50
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color:
                              isSelected ? Colors.green.shade50 : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.green
                                : Colors.grey.shade300,
                            width: isSelected ? 2.5 : 1,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: Colors.green.withOpacity(0.12),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedScale(
                              scale: isSelected ? 1.2 : 1.0,
                              duration: Duration(milliseconds: 300),
                              child: CircleAvatar(
                                backgroundColor: isSelected
                                    ? Colors.green.shade700.withOpacity(0.15)
                                    : Colors.grey.shade100,
                                radius: 28,
                                child: Icon(
                                  event['icon'],
                                  size: 32,
                                  color: isSelected
                                      ? Colors.green.shade700
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              event['label'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.green.shade700
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: selectedEventType == null
                    ? SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 8),
                        child: _buildDynamicEventForm(),
                      ),
              ),
              _buildSubmitButton(),
            ],
            //],
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
          label: Text("Declarer l'évènement",
              style: TextStyle(color: Colors.white, fontSize: 16)),
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

  Widget _infoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text("$label : ",
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.grey[700]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 400),
              child: Text(
                value,
                key: ValueKey(value),
                maxLines: 1,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ...ajoute ce widget dans la classe :
  Widget _buildDynamicEventForm() {
    switch (selectedEventType) {
      case 'vente':
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Form(
            key: _venteFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateField(
                  label: "Date de la vente",
                  value: venteDate,
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => venteDate = picked);
                  },
                ),
                _buildTextField(
                  icon: Icons.person,
                  label: "Nom de l'acheteur",
                  onSaved: (v) => acheteurNom = v,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Champ requis" : null,
                ),
                _buildTextField(
                  icon: Icons.phone_outlined,
                  label: "Contact de l'acheteur",
                  onSaved: (v) => acheteurContact = v,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Champ requis" : null,
                ),
                _buildTextField(
                  icon: Icons.sell_outlined,
                  label: "Motif de vente",
                  onSaved: (v) => motifVente = v,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Champ requis" : null,
                ),
                _buildTextField(
                  icon: Icons.note_outlined,
                  label: "Remarque (optionnel)",
                  onSaved: (v) => remarqueVente = v,
                ),
              ],
            ),
          ),
        );
      case 'vol':
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Form(
            key: _volFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateField(
                  label: "Date supposée du vol",
                  value: volDate,
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => volDate = picked);
                  },
                ),
                _buildTextField(
                  icon: Icons.place_outlined,
                  label: "Dernier lieu observé",
                  onSaved: (v) => dernierLieuObserve = v,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Champ requis" : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text("Avez-vous porté plainte ?",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: plainteDeposee == true
                              ? Colors.green
                              : Colors.grey.shade200,
                          foregroundColor: plainteDeposee == true
                              ? Colors.white
                              : Colors.black,
                        ),
                        onPressed: () => setState(() => plainteDeposee = true),
                        child: Text("Oui"),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: plainteDeposee == false
                              ? Colors.red
                              : Colors.grey.shade200,
                          foregroundColor: plainteDeposee == false
                              ? Colors.white
                              : Colors.black,
                        ),
                        onPressed: () => setState(() => plainteDeposee = false),
                        child: Text("Non"),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text("Pièces jointes (plainte, photo, etc.)",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: _importPieceJointe,
                  child: DottedBorder(
                    color: Colors.grey,
                    strokeWidth: 2,
                    dashPattern: [6, 4],
                    borderType: BorderType.RRect,
                    radius: Radius.circular(12),
                    child: Container(
                      width: double.infinity,
                      height: 70,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                                //key: ValueKey(f),
                                backgroundColor: Colors.green.shade50,
                                avatar: Icon(Icons.attach_file),
                                label: Text(f),
                                onDeleted: () => setState(() =>
                                    piecesJointes.removeWhere((e) => e == f)),
                              ))
                          .toList(),
                    ),
                  ),
                _buildTextField(
                  icon: Icons.comment,
                  label: "Circonstances (optionnel)",
                  onSaved: (v) => circonstancesVol = v,
                ),
                SwitchListTile(
                  title: Text("Déclarer comme bovin disparu"),
                  value: bovinDisparu,
                  activeColor: Color(0xff4a7b58),
                  onChanged: (v) => setState(() => bovinDisparu = v),
                ),
              ],
            ),
          ),
        );
      case 'deces':
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Form(
            key: _decesFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateField(
                  label: "Date du décès",
                  value: decesDate,
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => decesDate = picked);
                  },
                ),
                _buildTextField(
                  icon: Icons.map_outlined,
                  label: "Lieu du décès",
                  onSaved: (v) => lieuDeces = v,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Champ requis" : null,
                ),
                _buildTextField(
                  icon: Icons.view_carousel_outlined,
                  label: "Cause estimée du décès",
                  onSaved: (v) => causeDeces = v,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Champ requis" : null,
                ),
                _buildTextField(
                  icon: Icons.comment,
                  label: "Observations (optionnel)",
                  onSaved: (v) => observationsDeces = v,
                ),
                SwitchListTile(
                  title: Text("Nécessite l'intervention vétérinaire ?",
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  value: interventionVet,
                  activeColor: Color(0xff4a7b58),
                  onChanged: (v) => setState(() => interventionVet = v),
                ),
              ],
            ),
          ),
        );
      default:
        return SizedBox.shrink();
    }
  }

// Helpers pour les champs dynamiques
  Widget _buildTextField({
    required String label,
    required IconData icon,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          prefixIcon: Icon(icon, color: Color(0xff4B5563)),
          fillColor: Color(0xfff5f5f5),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
        ),
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xfff5f5f5)),
            color: Color(0xfff5f5f5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(FontAwesomeIcons.calendarAlt, color: Color(0xff4B5563)),
              SizedBox(width: 8),
              Text(
                value == null ? label : DateFormat('dd/MM/yyyy').format(value),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xff4B5563),
                  fontSize: 16,
                ),
              ),
              Spacer(),
              Icon(FontAwesomeIcons.angleDown,
                  size: 16, color: Color(0xff4B5563)),
            ],
          ),
        ),
      ),
    );
  }
}
