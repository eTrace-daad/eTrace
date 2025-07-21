import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

/// Simule la base de données MINEPIA pour les codes validés
const Set<String> minepiaCodes = {
  "BOV-CEN-20250621-0001", // Code validé pour ajout nouveau bovin
  "BOV-CEN-20250621-0003", // Code avec fiche complète
  "BOV-CEN-20250621-0004", // Code avec fiche complète
};

/// Simule la base de données interne de l'entreprise
const Set<String> entrepriseCodes = {
  "BOV-CEN-20250621-0003",
  "BOV-CEN-20250621-0004",
};

class VetoMainScreen extends StatefulWidget {
  const VetoMainScreen({super.key});

  @override
  State<VetoMainScreen> createState() => _VetoMainScreenState();
}

class _VetoMainScreenState extends State<VetoMainScreen>
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
  bool isConsultOnly = false;
  bool isNewBovin = false;
  Map<String, dynamic>? ownerData;

  Set<String> declaredBovins = {};

  static const String _aesKey =
      'votre_cle_secrete_32caracteres!!'; // 32 caractères
  static const String _aesIV = '16caracteresiv12'; // 16 caractères

  String decryptData(String encryptedText) {
    final key = encrypt.Key.fromUtf8(_aesKey);
    final iv = encrypt.IV.fromUtf8(_aesIV);
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    return decrypted;
  }

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

  /// Simule la récupération des données du bovin à partir du QR
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
    // Cas d'un code validé par MINEPIA mais pas encore dans la base entreprise
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
    // Code inconnu/falsifié
    return null;
  }

  void _showFalsificationDialog(String code, String? errorMsg) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Falsification",
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ScaleTransition(
              scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
              child: Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
                backgroundColor: Colors.white,
                elevation: 12,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 32, horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 12),
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
                                        const Icon(Icons.send,
                                            color: Colors.white),
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
                                elevation: 4,
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
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    // Bouton fermer en haut à droite
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.red, size: 28),
                          splashRadius: 22,
                          tooltip: "Fermer",
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            setState(() {
                              hasScanned = false;
                              isError = false;
                              scanError = null;
                              bovinData = null;
                              lastCode = null;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: child,
        );
      },
    );
  }

  void _onDetect(BarcodeCapture capture) async {
    if (isLoading) return;
    setState(() {
      scanError = null;
      isLoading = true;
      isFakeAlertSent = false;
      isConsultOnly = false;
      declarationError = null;
      declarationSuccess = null;
      isNewBovin = false;
      ownerData = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.qr_code, color: Colors.white),
            const SizedBox(width: 8),
            const Flexible(
                child: Text("QR code détecté, analyse en cours...",
                    maxLines: 2, overflow: TextOverflow.ellipsis)),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
    final encrypted =
        capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
    String? code;
    try {
      //final code =
      //capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
      if (encrypted != null && encrypted.trim().isNotEmpty) {
        code = decryptData(encrypted); // Déchiffre le code du QR
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

      // Vérification code validé MINEPIA
      if (!minepiaCodes.contains(code)) {
        setState(() {
          scanError =
              "Ce QR code n'est pas reconnu par MINEPIA et n'est pas valide. Il peut s'agir d'un code falsifié.";
          isError = true;
          hasScanned = true;
          bovinData = null;
          lastCode = code;
          isLoading = false;
          showScanner = false;
        });
        _showFalsificationDialog(code, scanError);
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
        final data = await _fetchBovinData(code);
        setState(() {
          isNewBovin = true;
          ownerData = data?['proprietaire'];
          bovinData = data;
          lastCode = code;
          isError = false;
          hasScanned = true;
          isLoading = false;
          showScanner = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info, color: Colors.white),
                const SizedBox(width: 8),
                const Flexible(
                    child: Text(
                        "Ce code est valide pour un nouveau bovin. Mais seul l'agent MINEPIA peut ajouter les informations.",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis)),
              ],
            ),
            backgroundColor: Colors.redAccent.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      // Cas d'un code connu avec fiche complète
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
      setState(() {
        hasScanned = true;
        isError = false;
        bovinData = data;
        lastCode = code;
        isLoading = false;
        showScanner = false;
        isNewBovin = false;
        ownerData = data['proprietaire'];
        _fadeController.forward(from: 0);
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
    } catch (e) {
      setState(() {
        scanError = "Erreur lors du scan : ${e.toString()}";
        isError = true;
        hasScanned = true;
        bovinData = null;
        isLoading = false;
        showScanner = false;
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
      isNewBovin = false;
      ownerData = null;
    });
  }

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
            "Prêt à scanner un bovin",
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: const Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Scannez le QR code d’un bovin pour afficher sa fiche complète, vérifier sa conformité sanitaire ou faites des interventions sanitaires et certifiez son état.",
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
                      "Le QR code contient toutes les informations officielles du bovin ou permet de faire des interventions sanitaires sur un bovin et certifie son état validé par MINEPIA.",
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
              "Placez le QR code devant la caméra pour afficher la fiche ou ajouter un nouveau bovin.",
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

  Widget _buildNewBovinCard() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(
        children: [
          Lottie.asset(
            'assets/lottie/bovin_info.json',
            height: MediaQuery.of(context).size.width * 0.5,
            fit: BoxFit.contain,
            repeat: true,
          ),
          const SizedBox(height: 32),
          Card(
            elevation: 10,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Nouveau bovin détecté",
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: const Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Ce code QR est validé par MINEPIA pour le propriétaire suivant.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 17,
                      color: Colors.blueGrey.shade700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (ownerData != null) _buildOwnerCard(ownerData!),
                  const SizedBox(height: 22),
                  /*ElevatedButton.icon(
                    onPressed: () {
                      context.go('/save', extra: {
                        'code': bovinData?['code'],
                        'owner': ownerData,
                        'bovinData':
                            bovinData, // on peut tout transmettre pour plus de souplesse
                        'dateScan': DateTime.now().toIso8601String(),
                        // Ajoute ici d'autres infos métier si besoin
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.add, color: Colors.white),
                              const SizedBox(width: 8),
                              const Flexible(
                                  child: Text("Ajout d'un nouveau bovin...",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                          backgroundColor: Colors.blue,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text("Ajouter un nouveau bovin"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      textStyle: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700, fontSize: 18),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 18),
                    ),
                  ),*/
                  Text(
                    "Mais vous n'avez pas les autorisations nécessaires pour ajouter les informations de ce bovin.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 17,
                      color: Colors.redAccent.shade700,
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
            Lottie.asset(
              'assets/lottie/error.json',
              height: 80,
              repeat: false,
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
                  // Appel API ou email à MINEPIA ici
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
          ],
        ),
      ),
    );
  }

  Widget _buildBovinShortCard(Map<String, dynamic> data) {
    final Color primaryColor = const Color(0xFF1976D2);
    final Color cardBg = Colors.blue.shade50;
    final bool hasAlert =
        (data['alertes'] != null && data['alertes'].isNotEmpty);

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animation et titre
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Lottie.asset(
                      'assets/lottie/bovin_info.json',
                      height: 90,
                      width: 90,
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.verified,
                                  color: primaryColor, size: 26),
                              const SizedBox(width: 6),
                              Text(
                                "Bovin reconnu",
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Code : ${data['code'] ?? '-'}",
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.blueGrey.shade800,
                            ),
                          ),
                          if (hasAlert)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded,
                                      color: Colors.red.shade700, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Alerte sanitaire",
                                    style: GoogleFonts.nunito(
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if (data['race'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Chip(
                                    side: BorderSide.none,
                                    avatar: const Icon(Icons.pets,
                                        color: Colors.brown),
                                    label: Text("${data['race']}"),
                                    backgroundColor: Colors.brown.shade50,
                                    labelStyle: GoogleFonts.nunito(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.brown),
                                  ),
                                ),
                              if (data['sexe'] != null)
                                Chip(
                                  side: BorderSide.none,
                                  avatar: Icon(
                                    data['sexe'] == "Femelle"
                                        ? FontAwesomeIcons.venus
                                        : FontAwesomeIcons.mars,
                                    color: data['sexe'] == "Femelle"
                                        ? Colors.pink
                                        : Colors.blue,
                                    size: 18,
                                  ),
                                  label: Text("${data['sexe']}"),
                                  backgroundColor: Colors.pink.shade50,
                                  labelStyle: GoogleFonts.nunito(
                                      fontWeight: FontWeight.w600,
                                      color: data['sexe'] == "Femelle"
                                          ? Colors.pink
                                          : Colors.blue),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              if (data['proprietaire'] != null)
                Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Propriétaire",
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildOwnerCard(data['proprietaire']),
                  ],
                ),
              // Vaccinations
              if (data['vaccinations'] != null &&
                  (data['vaccinations'] as List).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Vaccinations",
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...List.generate(
                        (data['vaccinations'] as List).length,
                        (i) {
                          final v = data['vaccinations'][i];
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              v['valide'] == true
                                  ? Icons.verified_rounded
                                  : Icons.warning_amber_rounded,
                              color: v['valide'] == true
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            title: Text(
                              v['nom'],
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w600,
                                color: v['valide'] == true
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            subtitle: Text(
                              "Date : ${v['date']}",
                              style: GoogleFonts.nunito(fontSize: 13),
                            ),
                            trailing: v['valide'] == true
                                ? const Icon(Icons.check, color: Colors.green)
                                : const Icon(Icons.close, color: Colors.red),
                          );
                        },
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),
              Divider(thickness: 1.2, color: Colors.blueGrey.shade100),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF1976D2)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Actions rapides : consultez, intervenez ou delivrez un certificat sanitaire.",
                          //"Actions rapides : consultez, déclarez ou suivez ce bovin en un clic.",
                          style: GoogleFonts.nunito(
                            color: const Color(0xFF1976D2),
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.6,
                children: [
                  _actionButton(
                    icon: Icons.event,
                    label: "Demande Certificat",
                    color: Colors.orange.shade700,
                    onTap: () {
                      //context.go('/event', extra: {'bovin': data});
                      /*context.go('/certificat', extra: {
                        'code': bovinData?['code'],
                        'owner': ownerData,
                        'bovinData': bovinData,
                        'dateScan': DateTime.now().toIso8601String(),
                      });*/
                      if (bovinData == null || ownerData == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                "Aucune donnée disponible pour le certificat."),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        return;
                      }
                      if (bovinData!['alertes'] != null &&
                          bovinData!['alertes'].isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                "Ce bovin a des alertes sanitaires. Contactez MINEPIA pour plus d'informations."),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                        return;
                      }
                      if (bovinData!['aleters'] == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.event, color: Colors.white),
                                const SizedBox(width: 8),
                                const Flexible(
                                    child: Text(
                                        "Une demande de certificat sanitaire a été envoyée au vétérinaire principal.",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                            backgroundColor: Colors.orange.shade700,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                          ),
                        );
                      }
                    },
                  ),
                  _actionButton(
                    icon: Icons.medical_services,
                    label: "Intervention sanitaire",
                    color: Colors.blue.shade700,
                    onTap: () {
                      //context.go('/intervention', extra: {'bovin': data});
                      context.go('/intervention', extra: {
                        'code': bovinData?['code'],
                        'owner': ownerData,
                        'bovinData': bovinData,
                        'dateScan': DateTime.now().toIso8601String(),
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.medical_services,
                                  color: Colors.white),
                              const SizedBox(width: 8),
                              const Flexible(
                                  child: Text("Intervention sanitaire...",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                          backgroundColor: Colors.blue.shade700,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                      );
                    },
                  ),
                  /*_actionButton(
                    icon: Icons.directions_bus,
                    label: "Suivi de transit",
                    color: Colors.green.shade700,
                    onTap: () {
                      context.go('/transit', extra: {'bovin': data});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.directions_bus,
                                  color: Colors.white),
                              const SizedBox(width: 8),
                              const Flexible(
                                  child: Text("Suivi de transit...",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                          backgroundColor: Colors.green.shade700,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                      );
                    },
                  ),*/
                  /*_actionButton(
                    icon: Icons.track_changes,
                    label: "Suivi du bovin",
                    color: Colors.purple.shade700,
                    onTap: () {
                      context.go('/suivi', extra: {'bovin': data});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.track_changes,
                                  color: Colors.white),
                              const SizedBox(width: 8),
                              const Flexible(
                                  child: Text("Suivi du bovin...",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                          backgroundColor: Colors.purple.shade700,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                      );
                    },
                  ),*/
                ],
              ),
              const SizedBox(height: 56),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle:
            GoogleFonts.nunito(fontWeight: FontWeight.w600, fontSize: 15),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        elevation: 3,
      ),
    );
  }

  Widget _buildOwnerCard(Map<String, dynamic> owner) {
    return Container(
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
              child: const Icon(Icons.person, color: Colors.white, size: 32),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: "qr_icon",
              child: Icon(Icons.verified,
                  color: const Color(0xFF1976D2), size: 30),
            ),
            const SizedBox(width: 10),
            Text("Vétérinaire",
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
                            : !hasScanned
                                ? _buildScanPrompt()
                                : isError
                                    ? _buildScanPrompt() //_buildErrorCard()
                                    : isNewBovin
                                        ? _buildNewBovinCard()
                                        : (bovinData != null &&
                                                bovinData!.isNotEmpty)
                                            ? _buildBovinShortCard(bovinData!)
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
              isNewBovin = false;
              ownerData = null;
            });
          } else if (!hasScanned) {
            _startScan();
          } else {
            _startScan();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.qr_code_scanner, color: Colors.white),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text(
                      "Démarrage du scan du QR code bovin...",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
