import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';

import 'package:encrypt/encrypt.dart' as encrypt;

class AbaScanScreen extends StatefulWidget {
  const AbaScanScreen({super.key});

  @override
  State<AbaScanScreen> createState() => _AbaScanScreenState();
}

class _AbaScanScreenState extends State<AbaScanScreen>
    with TickerProviderStateMixin {
  bool hasScanned = false;
  bool isError = false;
  Map<String, dynamic>? bovinData;
  String? lastCode;
  String? scanError;
  bool isLoading = false;
  bool isDeclaring = false;
  String? declarationError;
  String? declarationSuccess;
  String? selectedMethod;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  bool showScanner = false;
  bool isFakeAlertSent = false;

  Set<String> declaredBovins = {};
  bool isConsultOnly = false;
  bool isNewBovinDialogShown = false;
  bool isFalsifiedCode = false;

  static const String _aesKey =
      'votre_cle_secrete_32caracteres!!'; // 32 caractères
  static const String _aesIV = '16caracteresiv12'; // 16 caractères

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnim =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // Simule la récupération des données du bovin à partir du QR
  Future<Map<String, dynamic>?> _fetchBovinData(String code) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (code.isEmpty) throw Exception("QR code vide");
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

  Future<void> _declareAbattage() async {
    setState(() {
      isDeclaring = true;
      declarationError = null;
      declarationSuccess = null;
    });
    try {
      if (bovinData == null) throw Exception("Aucune donnée à déclarer.");
      if (selectedMethod == null) {
        throw Exception("Veuillez choisir une méthode d'abattage.");
      }
      if (declaredBovins.contains(bovinData!['code'])) {
        throw Exception("Ce bovin a déjà été déclaré abattu.");
      }
      await Future.delayed(const Duration(milliseconds: 1200));
      if (bovinData!['statutSanitaire'] != 'Conforme') {
        throw Exception("Déclaration impossible : bovin non conforme.");
      }
      setState(() {
        declarationSuccess = "Déclaration enregistrée avec succès !";
        declaredBovins.add(bovinData!['code']);
      });
    } catch (e) {
      setState(() {
        declarationError = e.toString();
      });
    } finally {
      setState(() {
        isDeclaring = false;
      });
    }
  }

  /*void _onDetect(BarcodeCapture capture) async {
    if (hasScanned || isLoading) return;
    setState(() {
      scanError = null;
      isLoading = true;
      isFakeAlertSent = false;
      
      //declarationError = null;
      //declarationSuccess = null;
    });
    try {
      final code =
          capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
      if (code == null || code.trim().isEmpty) {
        setState(() {
          scanError = "QR code vide ou illisible.";
          isError = true;
          hasScanned = true;
          bovinData = null;
          lastCode = null;
          isLoading = false;
          showScanner = false;
        });
        return;
      }
      if (code == lastCode) {
        setState(() {
          scanError = "Ce QR code a déjà été scanné.";
          isError = true;
          hasScanned = true;
          bovinData = null;
          isLoading = false;
          showScanner = false;
        });
        return;
      }
      lastCode = code;
      final data = await _fetchBovinData(code);
      setState(() {
        hasScanned = true;
        isLoading = false;
        showScanner = false;
        if (data != null) {
          isError = false;
          bovinData = data;
          selectedMethod = null;
          _fadeController.forward(from: 0);
        } else {
          isError = true;
          bovinData = null;
          scanError = "Ce QR code est inconnu ou falsifié.";
        }
      });
    } catch (e) {
      setState(() {
        scanError = "Erreur lors du scan : ${e.toString()}";
        isError = true;
        hasScanned = true;
        bovinData = null;
        isLoading = false;
        showScanner = false;
      });
    }
  }*/

  String decryptData(String encryptedText) {
    final key = encrypt.Key.fromUtf8(_aesKey);
    final iv = encrypt.IV.fromUtf8(_aesIV);
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    return decrypted;
  }

  void _onDetect(BarcodeCapture capture) async {
    if (isLoading) return;
    setState(() {
      /*scanError = null;
      isLoading = true;
      isFakeAlertSent = false;
      isConsultOnly = false;
      declarationError = null;
      declarationSuccess = null;*/
      scanError = null;
      isLoading = true;
      isFakeAlertSent = false;
      isConsultOnly = false;
      declarationError = null;
      declarationSuccess = null;
      isFalsifiedCode = false;
      isNewBovinDialogShown = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.qr_code, color: Colors.white),
            const SizedBox(width: 8),
            const Text("QR code détecté, analyse en cours..."),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
    try {
      //final code =
      //capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
      final encrypted =
          capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
      String? code;
      // Décryptage du code si besoin (exemple: AES, à adapter selon ton projet)
      if (encrypted != null && encrypted.trim().isNotEmpty) {
        // Remplace par ta logique de décryptage si nécessaire
        //code = encrypted; // Si pas de cryptage, sinon: code = decryptData(encrypted);
        code = decryptData(encrypted);
      }
      if (code == null || code.trim().isEmpty) {
        setState(() {
          scanError = "QR code vide ou illisible.";
          isError = true;
          hasScanned = true;
          bovinData = null;
          lastCode = null;
          isLoading = false;
          showScanner = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                const Text("QR code vide ou illisible."),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
      final alreadyDeclared = declaredBovins.contains(code);
      final data = await _fetchBovinData(code);
      if (data == null) {
        setState(() {
          scanError = "Ce QR code est inconnu ou falsifié.";
          isError = true;
          hasScanned = true;
          bovinData = null;
          lastCode = code;
          isLoading = false;
          showScanner = false;
          isFalsifiedCode = true;
        });
        _showFalsificationDialog(code, scanError);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                const Text("QR code inconnu ou falsifié."),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }
      // Gestion nouveau bovin non enregistré
      if (data['isNewBovin'] == true) {
        setState(() {
          scanError = "Ce bovin n'est pas encore enregistré.";
          isError = true;
          hasScanned = true;
          bovinData = null;
          lastCode = code;
          isLoading = false;
          showScanner = false;
          isNewBovinDialogShown = true;
        });
        _showNewBovinDialog(code, data);
        return;
      }

      if (alreadyDeclared) {
        // Animation + dialogue pour demander si consultation seulement
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => /*ScaleTransition(
            scale: CurvedAnimation(
              parent: AnimationController(
                vsync: this,
                duration: const Duration(milliseconds: 400),
              )..forward(),
              curve: Curves.elasticOut,
            ),
            child:*/
                  AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            title: Row(
              children: [
                const Icon(Icons.info, color: Color(0xFF1976D2)),
                const SizedBox(width: 8),
                Text("Bovin déjà déclaré",
                    style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              "Ce bovin a déjà été déclaré abattu.\n"
              "Voulez-vous simplement consulter ses informations ?",
              style: GoogleFonts.nunito(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    isLoading = false;
                    showScanner = false;
                    hasScanned = false;
                    isError = false;
                    bovinData = null;
                    lastCode = null;
                  });
                },
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    isConsultOnly = true;
                    hasScanned = true;
                    isError = false;
                    bovinData = data;
                    lastCode = code;
                    isLoading = false;
                    showScanner = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Consulter"),
              ),
            ],
          ),
          //),
        );
        return;
      }

      // Gestion bovin non conforme
      if (data['statutSanitaire'] != 'Conforme') {
        setState(() {
          scanError = "Abattage interdit : bovin non conforme.";
          isError = true;
          hasScanned = true;
          bovinData = data;
          lastCode = code;
          isLoading = false;
          showScanner = false;
        });
        _showNonConformeDialog(code, data);
        return;
      }

      setState(() {
        hasScanned = true;
        isError = false;
        bovinData = data;
        lastCode = code;
        isLoading = false;
        showScanner = false;
        isConsultOnly = false;
        _fadeController.forward(from: 0);
      });
    } catch (e) {
      setState(() {
        scanError = "Erreur lors du scan : ${e.toString()}";
        isError = true;
        hasScanned = true;
        bovinData = null;
        isLoading = false;
        showScanner = false;
      });
    }
  }

  // Dialog pour code falsifié/inconnu
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
                  setState(() {
                    isLoading = false;
                    showScanner = false;
                    hasScanned = false;
                    isError = false;
                    bovinData = null;
                    lastCode = null;
                    isFalsifiedCode = false;
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

  // Dialog pour nouveau bovin non enregistré
  void _showNewBovinDialog(String code, Map<String, dynamic>? data) {
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
              Lottie.asset('assets/lottie/new.json'),
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
                  GoRouter.of(context).go('/enregistrement_bovin');
                },
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                label: const Text("Aller à l'enregistrement"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
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
                    isLoading = false;
                    showScanner = false;
                    hasScanned = false;
                    isError = false;
                    bovinData = null;
                    lastCode = null;
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

  // Dialog pour bovin non conforme
  void _showNonConformeDialog(String code, Map<String, dynamic> data) {
    /*showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            const Icon(Icons.block, color: Colors.red),
            const SizedBox(width: 8),
            Text("Abattage interdit",
                style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          "Ce bovin n'est pas conforme sur le plan sanitaire et ne peut pas être déclaré à l'abattage.\n"
          "État sanitaire : ${data['statutSanitaire'] ?? '-'}\n"
          "Veuillez contacter le vétérinaire ou le responsable sanitaire.",
          style: GoogleFonts.nunito(),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                isLoading = false;
                showScanner = false;
                hasScanned = false;
                isError = false;
                bovinData = null;
                lastCode = null;
              });
            },
            icon: const Icon(Icons.close, color: Colors.red),
            label: const Text("Fermer"),
          ),
        ],
      ),
    );*/
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
              Lottie.asset('assets/lottie/error.json',
                  width: 110, repeat: false),
              const SizedBox(height: 18),
              Text(
                "Abattage interdit",
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.orange.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Ce bovin n'est pas conforme sur le plan sanitaire et ne peut pas être déclaré à l'abattage.\n"
                "État sanitaire : ${data['statutSanitaire'] ?? '-'}\n"
                "Veuillez contacter le vétérinaire ou le responsable sanitaire.",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: Colors.brown.shade400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              /*Text(
                "Code scanné : $code",
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: Colors.blueGrey.shade400,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),*/
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  GoRouter.of(context).go('/');
                },
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                label: const Text("Aller à l'accueil"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
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
                    isLoading = false;
                    showScanner = false;
                    hasScanned = false;
                    isError = false;
                    bovinData = null;
                    lastCode = null;
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

  Widget _buildNewBovinCard(String code) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/lottie/new.json', height: 90),
            const SizedBox(height: 16),
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
              "Ce QR code correspond à un nouvel animal non encore enregistré. Veuillez l'enregistrer dans l'interface principale avant toute déclaration.",
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
                GoRouter.of(context).go('/enregistrement_bovin');
              },
              icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
              label: const Text("Aller à l'enregistrement"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
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
          ],
        ),
      ),
    );
  }

  // Ajoute/modifie la méthode _buildErrorCard :
  Widget _buildErrorCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: const Color(0xFFFDE7E7),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animation d'alerte
            AnimatedScale(
              scale: 1.1,
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticInOut,
              child: const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFD94F4F), size: 56),
            ),
            const SizedBox(height: 16),
            Text(
              scanError ?? "QR code non reconnu",
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: const Color(0xFFD94F4F),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "Ce QR code est inconnu ou falsifié.\n"
              "Aucune donnée officielle n'a été trouvée pour ce bovin.\n"
              "Veuillez vérifier le support ou signaler une anomalie à MINEPIA.",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 15,
                color: Colors.brown.shade400,
              ),
            ),
            const SizedBox(height: 18),
            if (!isFakeAlertSent)
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    isFakeAlertSent = true;
                  });
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
                  // Ici, tu pourrais aussi appeler une API ou envoyer un mail à MINEPIA
                },
                icon:
                    const Icon(Icons.report_gmailerrorred, color: Colors.white),
                label: const Text("Signaler à MINEPIA"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD94F4F),
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
            const SizedBox(height: 18),
            /*ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  hasScanned = false;
                  isError = false;
                  bovinData = null;
                  lastCode = null;
                  scanError = null;
                  isLoading = false;
                  isFakeAlertSent = false;
                });
              },
              icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF5A8C49)),
              label: const Text("Nouveau scan"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE2D3B3),
                foregroundColor: const Color(0xFF5A8C49),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: GoogleFonts.nunito(
                    fontWeight: FontWeight.w600, fontSize: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),*/
          ],
        ),
      ),
    );
  }

  void _startScan() {
    setState(() {
      showScanner = true;
      scanError = null;
      isError = false;
      isLoading = false;
      hasScanned = false;
      bovinData = null;
      lastCode = null;
      declarationError = null;
      declarationSuccess = null;
      selectedMethod = null;
    });
  }

  /*Future<void> _showScanDialog() async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _ScanDialogPro(),
    );
    if (result != null) {
      setState(() {
        hasScanned = false;
        isError = false;
        bovinData = null;
        lastCode = null;
        scanError = null;
        isLoading = true;
        declarationError = null;
        declarationSuccess = null;
      });
      try {
        final data = await _fetchBovinData(result);
        setState(() {
          hasScanned = true;
          isLoading = false;
          if (data != null) {
            isError = false;
            bovinData = data;
            lastCode = result;
            selectedMethod = null;
            _fadeController.forward(from: 0);
          } else {
            isError = true;
            bovinData = null;
            scanError = "Ce QR code est inconnu ou falsifié.";
          }
        });
      } catch (e) {
        setState(() {
          scanError = "Erreur lors du scan : ${e.toString()}";
          isError = true;
          hasScanned = true;
          bovinData = null;
          isLoading = false;
        });
      }
    }
  }*/

  Future<void> _showScanDialog() async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _ScanDialogPro(),
    );
    if (result != null) {
      setState(() {
        hasScanned = false;
        isError = false;
        bovinData = null;
        lastCode = null;
        scanError = null;
        isLoading = true;
        declarationError = null;
        declarationSuccess = null;
        showScanner =
            false; // <-- Ajouté pour éviter le blocage sur _buildScanCard
      });
      try {
        // Décryptage du code si besoin
        String code = result;
        if (code.isNotEmpty) {
          code = decryptData(code);
        }
        final data = await _fetchBovinData(code);
        if (data != null) {
          setState(() {
            isError = false;
            bovinData = data;
            lastCode = code;
            selectedMethod = null;
            hasScanned = true;
            isLoading = false;
            showScanner = false;
            _fadeController.forward(from: 0);
          });
        } else {
          setState(() {
            isError = true;
            bovinData = null;
            scanError = "Ce QR code est inconnu ou falsifié.";
            hasScanned = true;
            isLoading = false;
            showScanner = false;
          });
        }
      } catch (e) {
        setState(() {
          scanError = "Erreur lors du scan : ${e.toString()}";
          isError = true;
          hasScanned = true;
          bovinData = null;
          isLoading = false;
          showScanner = false;
        });
      }
    } else {
      // Si le scan est annulé, afficher une indication
      setState(() {
        scanError = "Aucun QR code scanné. Veuillez réessayer.";
        isError = true;
        hasScanned = true;
        bovinData = null;
        isLoading = false;
        showScanner = false;
      });
    }
  }

  /*Widget _buildScanPrompt() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: "qr_icon_scan",
            child: Icon(Icons.qr_code_scanner,
                size: 100, color: Colors.blue.shade100),
          ),
          const SizedBox(height: 22),
          Text(
            "Aucun scan effectué",
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: Colors.blueGrey.shade700),
          ),
          const SizedBox(height: 12),
          Text(
            "Appuyez sur le bouton ci-dessous pour scanner le QR code d'un bovin et afficher toutes ses informations.",
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
                fontSize: 18, color: Colors.blueGrey.shade400),
          ),
          //const SizedBox(height: 32),
          /*AnimatedScale(
            scale: isLoading ? 0.95 : 1,
            duration: const Duration(milliseconds: 300),
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : _startScan,
              icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF1976D2)),
              label: const Text("Scanner un QR code"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEEF7FE),
                foregroundColor: const Color(0xFF1976D2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                textStyle: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700, fontSize: 18),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                elevation: 3,
              ),
            ),
          ),*/
        ],
      ),
    );
  }*/

  /*Widget _buildScanPrompt() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animation Lottie moderne (ex: abattage, vache, ou QR scan)
          /*SizedBox(
            height: 180,
            child: Lottie.asset(
              'assets/lottie/qr.json', // Place ici ton animation Lottie (voir note ci-dessous)
              repeat: true,
              fit: BoxFit.contain,
            ),
          ),*/
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Lottie.asset(
                  'assets/lottie/qr_code.json',
                  repeat: true,
                  fit: BoxFit.contain,
                ),
                if (isLoading)
                  Positioned(
                    bottom: 16,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 80,
                          height: 8,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.blue.shade100,
                            color: const Color(0xFF1976D2),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Analyse du QR code...",
                          style: GoogleFonts.nunito(
                            color: Colors.blueGrey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            "Prêt à scanner un bovin",
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: const Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Scannez le QR code d’un bovin pour afficher sa fiche complète, vérifier sa conformité sanitaire et déclarer son abattage en toute sécurité.",
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 18,
              color: Colors.blueGrey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 4,
            color: Colors.blue.shade50,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF1976D2)),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      "Le QR code contient toutes les informations officielles du bovin : identité, historique sanitaire, propriétaire, conformité, etc.",
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        color: Colors.blueGrey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          /*const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: isLoading ? null : _startScan,
            icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF1976D2)),
            label: const Text("Scanner un QR code"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEEF7FE),
              foregroundColor: const Color(0xFF1976D2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              textStyle:
                  GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 18),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              elevation: 3,
            ),
          ),*/
        ],
      ),
    );
  }*/

  Widget _buildScanPrompt() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Lottie.asset(
                  'assets/lottie/qr_code.json',
                  repeat: true,
                  fit: BoxFit.contain,
                ),
                if (isLoading)
                  Positioned(
                    bottom: 16,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 80,
                          height: 8,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.blue.shade100,
                            color: const Color(0xFF1976D2),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Analyse du QR code...",
                          style: GoogleFonts.nunito(
                            color: Colors.blueGrey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            hasScanned ? "Nouveau scan disponible" : "Prêt à scanner un bovin",
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: const Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            hasScanned
                ? "Appuyez sur 'Nouveau scan' pour scanner un autre bovin et afficher ses informations."
                : "Scannez le QR code d’un bovin pour afficher sa fiche complète, vérifier sa conformité sanitaire et déclarer son abattage en toute sécurité.",
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 18,
              color: Colors.blueGrey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 4,
            color: Colors.blue.shade50,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF1976D2)),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      hasScanned
                          ? "Vous pouvez scanner un nouveau QR code pour consulter ou déclarer un autre bovin."
                          : "Le QR code contient toutes les informations officielles du bovin : identité, historique sanitaire, propriétaire, conformité, etc.",
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        color: Colors.blueGrey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hasScanned && bovinData != null)
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Card(
                color: Colors.green.shade50,
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 22),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          "Dernier bovin scanné : ${bovinData?['code'] ?? ''}",
                          style: GoogleFonts.nunito(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (hasScanned && scanError != null)
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Card(
                color: Colors.red.shade50,
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 22),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          scanError!,
                          style: GoogleFonts.nunito(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScanCard() {
    return Card(
      elevation: 20,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Scanner le QR code du bovin",
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: const Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Placez le QR code devant la caméra pour afficher la fiche complète du bovin.",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 18,
                color: Colors.blueGrey.shade400,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF1976D2), width: 2.5),
                borderRadius: BorderRadius.circular(24),
              ),
              width: 300,
              height: 300,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: MobileScanner(
                  fit: BoxFit.cover,
                  onDetect: _onDetect,
                  controller: MobileScannerController(
                    detectionSpeed: DetectionSpeed.normal,
                    facing: CameraFacing.back,
                  ),
                  errorBuilder: (context, error, child) {
                    return Center(
                      child: Text(
                        "Erreur caméra : ${error.toString()}",
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 22),
            if (scanError != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  scanError!,
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () {
                          setState(() {
                            showScanner = false;
                            hasScanned = false;
                            isError = false;
                            bovinData = null;
                            lastCode = null;
                            scanError = null;
                            isLoading = false;
                            declarationError = null;
                            declarationSuccess = null;
                          });
                        },
                  icon: const Icon(Icons.close, color: Color(0xFFD32F2F)),
                  label: const Text("Annuler"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEBEE),
                    foregroundColor: const Color(0xFFD32F2F),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    textStyle: GoogleFonts.nunito(
                        fontWeight: FontWeight.w600, fontSize: 17),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : () => setState(() {}),
                  icon: const Icon(Icons.refresh, color: Color(0xFF1976D2)),
                  label: const Text("Relancer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEEF7FE),
                    foregroundColor: const Color(0xFF1976D2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    textStyle: GoogleFonts.nunito(
                        fontWeight: FontWeight.w600, fontSize: 17),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBovinInfoCard(Map<String, dynamic> data) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        key: const ValueKey("bovin_info_card"),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white, //Color(0xff4F7B58).withOpacity(.1),
          borderRadius: BorderRadius.circular(16),
        ),
        //elevation: 18,
        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        //color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isConsultOnly)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AnimatedOpacity(
                    opacity: 1,
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: Color(0xFF1976D2)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Ce bovin a déjà été déclaré abattu. Vous ne pouvez plus le déclarer à nouveau, mais vous pouvez consulter ses informations.",
                              style: GoogleFonts.nunito(
                                color: const Color(0xFF1976D2),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Container(
                  key: const ValueKey("bovin_info_card"),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xff4F7B58).withOpacity(.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Hero(
                                  tag: "qr_icon_bovin",
                                  child: Icon(FontAwesomeIcons.cow,
                                      size: 32, color: const Color(0xFF1976D2)),
                                ),
                                //const Spacer(),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Text(
                                    data['code'] ?? "",
                                    style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 26,
                                      color: const Color(0xFF1976D2),
                                    ),
                                  ),
                                ),
                                /*Tooltip(
                    message: "Scanner un nouveau QR code",
                    child: AnimatedScale(
                      scale: 1,
                      duration: const Duration(milliseconds: 200),
                      child: IconButton(
                        icon: const Icon(Icons.qr_code_scanner,
                            size: 34, color: Color(0xFF1976D2)),
                        onPressed: _showScanDialog,
                      ),
                    ),
                  ),*/
                              ],
                            ),
                            const SizedBox(height: 18),
                            /*SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _InfoPicto(
                        icon: Icons.female,
                        label: data['sexe'] ?? "",
                        color: Colors.pink.shade400),
                    const SizedBox(width: 12),
                    _InfoPicto(
                        icon: Icons.pets,
                        label: data['race'] ?? "",
                        color: Colors.blueGrey.shade400),
                    const SizedBox(width: 12),
                    _InfoPicto(
                        icon: Icons.cake,
                        label: data['dateNaissance'] ?? "",
                        color: Colors.orange.shade400),
                    const SizedBox(width: 12),
                    _InfoPicto(
                        icon: Icons.place,
                        label: data['lieuNaissance'] ?? "",
                        color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    _InfoPicto(
                        icon: Icons.fingerprint,
                        label: data['identifiant'] ?? "",
                        color: Colors.blueGrey.shade700),
                  ],
                ),
              ),*/
                            const SizedBox(height: 14),
                            _InfoPicto(
                              animated: true,
                              icon: Icons.female,
                              label: data['sexe'] ?? "",
                              color: Colors.pink.shade400,
                              text: 'Sexe: ',
                            ),
                            const SizedBox(height: 12),
                            _InfoPicto(
                              animated: true,
                              icon: Icons.pets,
                              label: data['race'] ?? "",
                              color: Colors.blueGrey.shade400,
                              text: 'Race: ',
                            ),
                            const SizedBox(height: 12),
                            _InfoPicto(
                              animated: true,
                              icon: Icons.cake,
                              label: data['dateNaissance'] ?? "",
                              color: Colors.orange.shade400,
                              text: 'Date de naissance: ',
                            ),
                            const SizedBox(height: 12),
                            _InfoPicto(
                              animated: true,
                              icon: Icons.place,
                              label: data['lieuNaissance'] ?? "",
                              color: Colors.green.shade700,
                              text: 'Lieu de naissance: ',
                            ),
                            const SizedBox(height: 12),
                            _InfoPicto(
                              animated: true,
                              icon: Icons.fingerprint,
                              label: data['identifiant'] ?? "",
                              color: Colors.blueGrey.shade700,
                              text: 'Identifiant: ',
                            ),
                            const SizedBox(height: 12),
                            _InfoPicto(
                              animated: true,
                              icon: Icons.medical_services,
                              label: "Dernière véto: ${data['lastVet'] ?? ""}",
                              color: Colors.blue.shade400,
                              text: 'Dernière véto: ',
                            ),
                          ]))),
              const SizedBox(height: 22),
              if (data['proprietaire'] != null)
                _buildOwnerCard(data['proprietaire']),
              const SizedBox(height: 16),
              _buildConformiteCard(data),
              const SizedBox(height: 16),
              _buildDeclarationCard(),
              if (declarationError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: AnimatedOpacity(
                    opacity: 1,
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      declarationError!,
                      style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              if (declarationSuccess != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: AnimatedOpacity(
                    opacity: 1,
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      declarationSuccess!,
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              const SizedBox(height: 22),
              /*AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: isDeclaring
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF1976D2)))
                    : ElevatedButton.icon(
                        key: ValueKey(selectedMethod),
                        onPressed: (bovinData != null &&
                                !isError &&
                                selectedMethod != null &&
                                !isDeclaring)
                            ? () async {
                                await _declareAbattage();
                                if (declarationSuccess != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.check_circle,
                                              color: Colors.white),
                                          const SizedBox(width: 8),
                                          Text(declarationSuccess!),
                                        ],
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                } else if (declarationError != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.error,
                                              color: Colors.white),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              declarationError!,
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
                                }
                              }
                            : null,
                        icon: const Icon(Icons.local_fire_department),
                        label: const Text("Déclarer l'abattage"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          textStyle: GoogleFonts.nunito(
                              fontWeight: FontWeight.w700, fontSize: 18),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 18),
                        ),
                      ),
              ),*/
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: isDeclaring
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF1976D2)))
                    : ElevatedButton.icon(
                        key: ValueKey(selectedMethod),
                        onPressed: (bovinData != null &&
                                !isError &&
                                selectedMethod != null &&
                                !isDeclaring &&
                                !isConsultOnly)
                            ? () async {
                                await _declareAbattage();
                                if (declarationSuccess != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.check_circle,
                                              color: Colors.white),
                                          const SizedBox(width: 8),
                                          Text(declarationSuccess!),
                                        ],
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                } else if (declarationError != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.error,
                                              color: Colors.white),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              declarationError!,
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
                                }
                              }
                            : null,
                        icon: const Icon(Icons.local_fire_department),
                        label: isConsultOnly
                            ? const Text("Déjà déclaré")
                            : const Text("Déclarer l'abattage"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isConsultOnly
                              ? Colors.grey
                              : const Color(0xFFD32F2F),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          textStyle: GoogleFonts.nunito(
                              fontWeight: FontWeight.w700, fontSize: 18),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 18),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOwnerCard(Map<String, dynamic> owner) {
    return Container(
      //elevation: 6,
      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.withOpacity(.1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF1976D2),
              child: Icon(Icons.person, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(owner['nom'] ?? "-",
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 2),
                  Text(owner['contact'] ?? "-",
                      style: GoogleFonts.nunito(
                          fontSize: 15, color: Colors.blueGrey.shade400)),
                  const SizedBox(height: 2),
                  Text(owner['adresse'] ?? "-",
                      style: GoogleFonts.nunito(
                          fontSize: 15, color: Colors.blueGrey.shade400)),
                  const SizedBox(height: 2),
                  Text("ID: ${owner['identifiant'] ?? '-'}",
                      style: GoogleFonts.nunito(
                          fontSize: 14, color: Colors.blueGrey.shade300)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConformiteCard(Map<String, dynamic> data) {
    final vaccinations = data['vaccinations'] as List<dynamic>? ?? [];
    final alertes = data['alertes'] as List<dynamic>? ?? [];
    final isConforme = data['statutSanitaire'] == 'Conforme';

    return Container(
      //elevation: 4,
      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      //color: const Color(0xFFF5F7FA),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Contrôles de conformité",
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.verified,
                    color: isConforme ? Colors.green : Colors.red, size: 22),
                const SizedBox(width: 8),
                Text(
                  "État sanitaire : ${data['statutSanitaire'] ?? '-'}",
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    //fontWeight: FontWeight.w600,
                    color: isConforme ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text("Vaccinations :",
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                )),
            ...vaccinations.map((v) => Row(
                  children: [
                    Icon(
                      v['valide'] == true ? Icons.check_circle : Icons.cancel,
                      color: v['valide'] == true ? Colors.green : Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text("${v['nom']} (${v['date']})",
                        style: GoogleFonts.nunito(fontSize: 16)),
                  ],
                )),
            const SizedBox(height: 8),
            if (alertes.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Alertes :",
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      )),
                  ...alertes.map((a) => Row(
                        children: [
                          const Icon(Icons.warning,
                              color: Colors.red, size: 18),
                          const SizedBox(width: 6),
                          Text("${a['message']} (${a['date']})",
                              style: GoogleFonts.nunito(
                                  fontSize: 16, color: Colors.red)),
                        ],
                      )),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeclarationCard() {
    final now = DateTime.now();
    final dateStr =
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    final heureStr =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    final lieu = "Abattoir Central de Yaoundé";

    return Container(
      //elevation: 4,
      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      //color: const Color(0xFFF5F7FA),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Déclaration d'abattage",
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            _infoRow("Date", dateStr),
            _infoRow("Heure", heureStr),
            _infoRow("Lieu d'abattage", lieu),
            const SizedBox(height: 16),
            Text("Méthode d'abattage :",
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 6),
            /*Wrap(
              spacing: 0,
              alignment: WrapAlignment.center,
              children: [
                _methodChoice("Traditionnel"),
                _methodChoice("Mécanique"),
                _methodChoice("Électrique"),
              ],
            ),*/
            Row(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _methodChoice("Traditionnel"),
                //const SizedBox(width: 12),
                _methodChoice("Mécanique"),
                //const SizedBox(width: 12),
                _methodChoice("Électrique"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /*Widget _methodChoice(String method) {
    final isSelected = selectedMethod == method;
    return ChoiceChip(
      key: ValueKey(method),
      showCheckmark: false,
      label:
          Text(method, style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
      selected: isSelected,
      onSelected: isDeclaring
          ? null
          : (v) {
              setState(() {
                selectedMethod = method;
              });
            },
      selectedColor: const Color(0xFF1976D2),
      backgroundColor: const Color(0xFFEEF7FE),
      labelStyle:
          TextStyle(color: isSelected ? Colors.white : const Color(0xFF1976D2)),
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }*/

  Widget _methodChoice(String method) {
    final isSelected = selectedMethod == method;

    // Définir une icône contextuelle selon la méthode
    IconData icon;
    Color iconColor;
    switch (method) {
      case "Traditionnel":
        icon = Icons.handyman;
        iconColor = const Color(0xFF5A8C49);
        break;
      case "Mécanique":
        icon = Icons.precision_manufacturing;
        iconColor = Colors.blueGrey.shade700;
        break;
      case "Électrique":
        icon = Icons.electrical_services;
        iconColor = Colors.amber.shade800;
        break;
      default:
        icon = Icons.device_unknown;
        iconColor = Colors.grey;
    }

    return Expanded(
      child: GestureDetector(
        onTap: isDeclaring
            ? null
            : () {
                setState(() {
                  selectedMethod = method;
                });
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.ease,
          //width: 100,
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF2C5530).withOpacity(.10)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: isSelected
                ? Border(
                    bottom: BorderSide(
                      color: const Color(0xFF5A8C49),
                      width: 4,
                    ),
                  )
                : Border.all(
                    color: Colors.grey.shade400,
                    width: 1,
                  ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: const Color(0xFF5A8C49).withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(height: 6),
              Text(
                method,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isSelected
                      ? const Color(0xFF5A8C49)
                      : Colors.brown.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text("$label :",
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey.shade700)),
          ),
          Expanded(
            flex: 3,
            child: Text(value,
                style: GoogleFonts.nunito(color: Colors.blueGrey.shade900)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, //Color(0xFFF3F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: "qr_icon",
              child: Icon(Icons.qr_code_2,
                  color: const Color(0xFF1976D2), size: 30),
            ),
            const SizedBox(width: 10),
            Text("Déclaration Abattage",
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: const Color(0xFF1976D2))),
          ],
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1976D2)),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 22),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    //maxWidth: 520,
                    minHeight: constraints.maxHeight * 0.85,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: showScanner
                        ? _buildScanCard()
                        : isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFF1976D2)))
                            : isNewBovinDialogShown && !hasScanned != null
                                ? _buildNewBovinCard(lastCode!)
                                : !hasScanned
                                    ? _buildScanPrompt()
                                    : isError
                                        ? _buildErrorCard()
                                        : (bovinData != null &&
                                                bovinData!.isNotEmpty)
                                            ? (!isNewBovinDialogShown
                                                ? _buildBovinInfoCard(
                                                    bovinData!)
                                                : _buildScanPrompt())
                                            : _buildScanPrompt(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (showScanner) {
            setState(() {
              showScanner = false;
              hasScanned = false;
              isError = false;
              bovinData = null;
              lastCode = null;
              scanError = null;
              isLoading = false;
              declarationError = null;
              declarationSuccess = null;
              selectedMethod = null;
            });
          } else if (!hasScanned) {
            _startScan();
          } else {
            _showScanDialog();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.qr_code_scanner, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text("Démarrage du scan du QR code bovin..."),
                ],
              ),
              backgroundColor: const Color(0xFF1976D2),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: Text(
          (!hasScanned || showScanner) ? "Scanner" : "Nouveau scan",
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 5,
      ),
    );
  }
}

class _InfoPicto extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool animated;
  final String text;
  const _InfoPicto({
    required this.icon,
    required this.label,
    required this.color,
    this.animated = false,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(icon, color: color, size: 22);
    if (animated) {
      iconWidget = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.1),
        duration: const Duration(milliseconds: 700),
        curve: Curves.elasticOut,
        builder: (context, value, child) => Transform.scale(
          scale: value,
          child: child,
        ),
        child: iconWidget,
      );
    }
    return Row(
      //mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          iconWidget,
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: Colors.blueGrey.shade800,
            ),
          ),
        ]),
        //iconWidget,
        //const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.blueGrey.shade800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanDialogPro extends StatefulWidget {
  const _ScanDialogPro();

  @override
  State<_ScanDialogPro> createState() => _ScanDialogProState();
}

class _ScanDialogProState extends State<_ScanDialogPro>
    with SingleTickerProviderStateMixin {
  String? error;
  bool isClosed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _closeDialog([String? code]) {
    isClosed = true;
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: [
            Icon(Icons.qr_code_scanner,
                color: const Color(0xFF1976D2), size: 28),
            const SizedBox(width: 10),
            Text(
              "Nouveau scan",
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: const Color(0xFF1976D2)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Placez le QR code devant la caméra pour scanner un autre bovin.",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                  fontSize: 16, color: Colors.blueGrey.shade400),
            ),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF1976D2), width: 2),
                borderRadius: BorderRadius.circular(18),
              ),
              width: 260,
              height: 260,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: MobileScanner(
                  fit: BoxFit.cover,
                  onDetect: (capture) {
                    if (isClosed) return;
                    final code = capture.barcodes.isNotEmpty
                        ? capture.barcodes.first.rawValue
                        : null;
                    if (code == null || code.trim().isEmpty) {
                      setState(() {
                        error = "QR code vide ou illisible.";
                      });
                      return;
                    }
                    _closeDialog(code);
                  },
                  controller: MobileScannerController(
                    detectionSpeed: DetectionSpeed.normal,
                    facing: CameraFacing.back,
                  ),
                  errorBuilder: (context, err, child) => Center(
                    child: Text(
                      "Erreur caméra : ${err.toString()}",
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(error!,
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _closeDialog(),
            icon: const Icon(Icons.close, color: Color(0xFFD32F2F)),
            label: Text(
              "Annuler",
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold, color: const Color(0xFFD32F2F)),
            ),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFD32F2F),
              textStyle: GoogleFonts.nunito(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
