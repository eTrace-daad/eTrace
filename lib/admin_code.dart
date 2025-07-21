import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

void main() => runApp(ContHealth());

class ContHealth extends StatelessWidget {
  const ContHealth({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: Colors.white,
      ),
      child: QRGeneratorScreen(),
    );
  }
}

class QRGeneratorScreen extends StatefulWidget {
  const QRGeneratorScreen({super.key});

  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  final TextEditingController _countCtrl = TextEditingController(text: "1");
  final TextEditingController _prefixCtrl = TextEditingController(text: "BOV");
  String _selectedRegion = "CEN";
  bool _isLoading = false;
  List<_QRPreview> _previews = [];
  DateTime _date = DateTime.now();

  static const String _aesKey =
      'votre_cle_secrete_32caracteres!!'; // 32 caractères
  static const String _aesIV = '16caracteresiv12'; // 16 caractères

  String encryptData(String plainText) {
    final key = encrypt.Key.fromUtf8(_aesKey);
    final iv = encrypt.IV.fromUtf8(_aesIV);
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  String decryptData(String encryptedText) {
    final key = encrypt.Key.fromUtf8(_aesKey);
    final iv = encrypt.IV.fromUtf8(_aesIV);
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    return decrypted;
  }

  static const Map<String, String> regions = {
    "CEN": "Centre",
    "DOU": "Douala",
    "MAR": "Maroua",
    "BER": "Bertoua",
    "NGA": "Ngaoundéré",
    "GAR": "Garoua",
    "BAM": "Bamenda",
    "EBO": "Ebolowa",
    "LIT": "Littoral",
    "OUE": "Ouest",
    "ADA": "Adamaoua",
    "EXT": "Extrême-Nord",
    "SUD": "Sud",
    "NOU": "Nord-Ouest",
    "EST": "Est",
  };

  /*Future<void> _generateQRCodes() async {
    setState(() {
      _isLoading = true;
      _previews.clear();
    });
    final int count = int.tryParse(_countCtrl.text) ?? 1;
    final String prefix = _prefixCtrl.text.trim().toUpperCase();
    final String region = _selectedRegion;
    final String dateStr =
        "${_date.year}${_date.month.toString().padLeft(2, '0')}${_date.day.toString().padLeft(2, '0')}";

    List<_QRPreview> previews = [];
    for (int i = 1; i <= count; i++) {
      final code = "$prefix-$region-$dateStr-${i.toString().padLeft(4, '0')}";
      final url = await _fetchQRCodeUrl(code);
      if (url != null) {
        previews.add(_QRPreview(code: code, svg: url));
      } else {
        debugPrint("QR code non généré pour le code : $code");
      }
    }
    if (previews.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Aucun QR code n'a pu être généré. Vérifiez votre connexion ou le quota de l'API.")),
      );
    }
    setState(() {
      _previews = previews;
      _isLoading = false;
    });
  }*/

  Future<void> _generateQRCodes() async {
    setState(() {
      _isLoading = true;
      _previews.clear();
    });
    final int count = int.tryParse(_countCtrl.text) ?? 1;
    final String prefix = _prefixCtrl.text.trim().toUpperCase();
    final String region = _selectedRegion;
    final String dateStr =
        "${_date.year}${_date.month.toString().padLeft(2, '0')}${_date.day.toString().padLeft(2, '0')}";

    List<_QRPreview> previews = [];
    for (int i = 1; i <= count; i++) {
      final code = "$prefix-$region-$dateStr-${i.toString().padLeft(4, '0')}";
      final encryptedCode = encryptData(code); // Chiffre le code
      final url =
          await _fetchQRCodeUrl(encryptedCode); // Utilise le code chiffré
      if (url != null) {
        previews
            .add(_QRPreview(code: code, svg: url, encrypted: encryptedCode));
      } else {
        debugPrint("QR code non généré pour le code : $code");
      }
    }
    if (previews.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Aucun QR code n'a pu être généré. Vérifiez votre connexion ou le quota de l'API.")),
      );
    }
    setState(() {
      _previews = previews;
      _isLoading = false;
    });
  }

  Future<String?> _fetchQRCodeUrl(String code) async {
    const apiUrl = "https://api.qrcode-monkey.com/qr/custom";
    final body = {
      "data": code,
      "config": {
        "body": "pointed-edge-cut",
        "eye": "frame1",
        "eyeBall": "ball1",
        //"erf1": [],
        //"erf2": ["fh"],
        //"erf3": ["fv"],
        //"brf1": [],
        //"brf2": ["fh"],
        //"brf3": ["fv"],
        "bodyColor": "#000000",
        "bgColor": "#FFFFFF",
        //"eye1Color": "#3F6B2B",
        //"eye2Color": "#3F6B2B",
        //"eye3Color": "#3F6B2B",
        //"eyeBall1Color": "#60A541",
        //"eyeBall2Color": "#60A541",
        //"eyeBall3Color": "#60A541",
        //"gradientColor1": "#5C8B29",
        //"gradientColor2": "#25492F",
        //"gradientType": "radial",
        //"gradientOnEyes": false,
        "logo": "",
        //"https://zfpjouefehuupibmexqa.supabase.co/storage/v1/object/public/etrace-content/images/icon_app.png", // Mets ton logo ici si besoin
      },
      "size": 300,
      "download": false,
      "file": "svg"
    };
    try {
      final resp = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      if (resp.statusCode == 200) {
        final contentType = resp.headers['content-type'] ?? '';
        if (contentType.contains('application/json')) {
          final json = jsonDecode(resp.body);
          if (json['imageUrl'] != null) {
            // Optionnel: tu pourrais télécharger le SVG via l'URL ici si tu veux
            return await http.read(
                Uri.parse("https://www.qrcode-monkey.com${json['imageUrl']}"));
          }
        } else if (contentType.contains('image/svg+xml') ||
            resp.body.startsWith('<?xml')) {
          // Retourne le SVG brut
          return resp.body;
        }
      }
    } catch (e) {
      debugPrint("Exception: $e");
    }
    return null;
  }

  /*Future<String?> _fetchQRCodeUrl(String code) async {
    // Utilise l'API qrcode-monkey pour générer un QR code personnalisé avec logo
    const apiUrl = "https://api.qrcode-monkey.com//qr/custom";
    final body = {
      "data": code,
      "config": {
        "body": "square",
        "eye": "frame13",
        "eyeBall": "ball14",
        "bgColor": "#ffffff",
        "bodyColor": "#1976D2",
        "eye1Color": "#1976D2",
        "eye2Color": "#1976D2",
        "eye3Color": "#1976D2",
        "logo":
            "https://www.qrcode-monkey.com/img/monkey_face.png", // Remplace par ton logo si besoin
        "logoMode": "default"
      },
      "size": 600,
      "download": false,
      "file": "png"
    };
    try {
      final resp = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body);
        if (json['imageUrl'] != null) {
          return "https://www.qrcode-monkey.com" + json['imageUrl'];
        }
      }
    } catch (e) {
      // ignore
    }
    return null;
  }*/

  /*Future<String?> _fetchQRCodeUrl(String code) async {
    const apiUrl = "https://api.qrcode-monkey.com/qr/custom";
    final body = {
      "data": code,
      "config": {
        "body": "rounded-pointed",
        "eye": "frame14",
        "eyeBall": "ball16",
        "erf1": [],
        "erf2": ["fh"],
        "erf3": ["fv"],
        "brf1": [],
        "brf2": ["fh"],
        "brf3": ["fv"],
        "bodyColor": "#5C8B29",
        "bgColor": "#FFFFFF",
        "eye1Color": "#3F6B2B",
        "eye2Color": "#3F6B2B",
        "eye3Color": "#3F6B2B",
        "eyeBall1Color": "#60A541",
        "eyeBall2Color": "#60A541",
        "eyeBall3Color": "#60A541",
        "gradientColor1": "#5C8B29",
        "gradientColor2": "#25492F",
        "gradientType": "radial",
        "gradientOnEyes": false,
        "logo": ""
      },
      "size": 300,
      "download": false,
      "file": "svg"
    };
    try {
      final resp = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body);
        if (json['imageUrl'] != null) {
          return "https://www.qrcode-monkey.com" + json['imageUrl'];
        } else {
          debugPrint("API response missing imageUrl: ${resp.body}");
        }
      } else {
        debugPrint("API error: ${resp.statusCode} - ${resp.body}");
      }
    } catch (e) {
      debugPrint("Exception: $e");
    }
    return null;
  }*/

  /*Future<String?> _fetchQRCodeUrl(String code) async {
    const apiUrl = "https://api.qrcode-monkey.com//qr/custom";
    final body = {
      "data": code,
      "config": {
        "body": "square",
        "eye": "frame13",
        "eyeBall": "ball14",
        "bgColor": "#ffffff",
        "bodyColor": "#1976D2",
        "eye1Color": "#1976D2",
        "eye2Color": "#1976D2",
        "eye3Color": "#1976D2",
        "logo": "https://www.qrcode-monkey.com/img/monkey_face.png",
        "logoMode": "default"
      },
      "size": 600,
      "download": false,
      "file": "png"
    };
    try {
      final resp = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body);
        if (json['imageUrl'] != null) {
          return "https://www.qrcode-monkey.com" + json['imageUrl'];
        } else {
          debugPrint("API response missing imageUrl: ${resp.body}");
        }
      } else {
        debugPrint("API error: ${resp.statusCode} - ${resp.body}");
      }
    } catch (e) {
      debugPrint("Exception: $e");
    }
    return null;
  }*/

  Future<Uint8List> _generateQrPng(String data, {int size = 300}) async {
    final qrValidationResult = QrValidator.validate(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );
    if (qrValidationResult.status != QrValidationStatus.valid) {
      throw Exception("QR code data invalid");
    }
    final qrCode = qrValidationResult.qrCode!;
    final painter = QrPainter.withQr(
      qr: qrCode,
      color: const Color(0xFF5C8B29),
      emptyColor: Colors.white,
      gapless: true,
      embeddedImageStyle: null,
      embeddedImage: null,
    );
    final picData = await painter.toImageData(size.toDouble(),
        format: ui.ImageByteFormat.png);
    return picData!.buffer.asUint8List();
  }

  /*Future<void> _saveAsPdf() async {
    if (_previews.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aucun QR code à enregistrer.")),
      );
      return;
    }

    try {
      final pdf = pw.Document();
      final now = DateTime.now();
      final dateStr = "${now.day.toString().padLeft(2, '0')}/"
          "${now.month.toString().padLeft(2, '0')}/"
          "${now.year} ${now.hour.toString().padLeft(2, '0')}:"
          "${now.minute.toString().padLeft(2, '0')}";

      // Charge l'icône de l'app
      pw.ImageProvider? appIcon;
      try {
        final bytes = await rootBundle.load('assets/app/icon_app.png');
        appIcon = pw.MemoryImage(bytes.buffer.asUint8List());
      } catch (e) {
        appIcon = null;
      }

      // Génère les QR codes en PNG
      List<Uint8List?> qrPngs = [];
      for (final preview in _previews) {
        try {
          final pngBytes = await _generateQrPng(preview.code, size: 300);
          qrPngs.add(pngBytes);
        } catch (e) {
          qrPngs.add(null);
        }
      }

      // Paramètres de la grille
      const int columns = 4;
      const double qrSize = 110;
      const double cellPadding = 8;
      const double cellWidth = qrSize + cellPadding * 2;
      const double cellHeight = qrSize + 36 + cellPadding * 2;
      final rows = (qrPngs.length / columns).ceil();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(18),
          build: (context) {
            // En-tête
            final header = pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (appIcon != null) pw.Image(appIcon, width: 40, height: 40),
                pw.SizedBox(width: 12),
                pw.Text(
                  "eTrace - QR Codes Bovins",
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex("#1976D2"),
                  ),
                ),
                pw.Spacer(),
                pw.Text(
                  dateStr,
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
              ],
            );

            // Grille QR codes
            final tableRows = <pw.TableRow>[];
            int idx = 0;
            for (int row = 0; row < rows; row++) {
              final cells = <pw.Widget>[];
              for (int col = 0; col < columns; col++) {
                if (idx < qrPngs.length && qrPngs[idx] != null) {
                  cells.add(
                    pw.Container(
                      width: cellWidth,
                      height: cellHeight,
                      padding: const pw.EdgeInsets.all(cellPadding),
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Image(
                            pw.MemoryImage(qrPngs[idx]!),
                            width: qrSize,
                            height: qrSize,
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            _previews[idx].code,
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (idx < qrPngs.length && qrPngs[idx] == null) {
                  cells.add(
                    pw.Container(
                      width: cellWidth,
                      height: cellHeight,
                      color: PdfColors.grey300,
                      child: pw.Center(child: pw.Text("Erreur QR")),
                    ),
                  );
                } else {
                  cells.add(
                    pw.Container(
                      width: cellWidth,
                      height: cellHeight,
                    ),
                  );
                }
                idx++;
              }
              tableRows.add(pw.TableRow(children: cells));
            }

            // Table avec QR codes
            final qrTable = pw.Table(
              border: null,
              defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
              children: tableRows,
            );

            // Traits pointillés horizontaux et verticaux
            final List<pw.Widget> dashedLines = [];
            // Horizontaux
            for (int r = 1; r < rows; r++) {
              dashedLines.add(
                pw.Positioned(
                  top: 73 + r * cellHeight,
                  left: 0,
                  right: 0,
                  child: pw.Container(
                    height: 1,
                    child: pw.LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints?.maxWidth;
                        const dashWidth = 6.0;
                        const dashSpace = 4.0;
                        final dashCount =
                            (width! / (dashWidth + dashSpace)).floor();
                        return pw.Row(
                          children: List.generate(dashCount, (i) {
                            return pw.Container(
                              width: dashWidth,
                              height: 1,
                              color: PdfColors.grey400,
                              margin: pw.EdgeInsets.only(
                                  right: i == dashCount - 1 ? 0 : dashSpace),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ),
              );
            }
            // Verticaux
            for (int c = 1; c < columns; c++) {
              dashedLines.add(
                pw.Positioned(
                  top: 73,
                  left: c * cellWidth,
                  bottom: 0,
                  child: pw.Container(
                    width: 1,
                    child: pw.LayoutBuilder(
                      builder: (context, constraints) {
                        final height = constraints?.maxHeight;
                        const dashHeight = 6.0;
                        const dashSpace = 4.0;
                        final dashCount =
                            (height! / (dashHeight + dashSpace)).floor();
                        return pw.Column(
                          children: List.generate(dashCount, (i) {
                            return pw.Container(
                              width: 1,
                              height: dashHeight,
                              color: PdfColors.grey400,
                              margin: pw.EdgeInsets.only(
                                  bottom: i == dashCount - 1 ? 0 : dashSpace),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ),
              );
            }

            return pw.Stack(
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    header,
                    pw.Divider(thickness: 1),
                    pw.SizedBox(height: 12),
                    qrTable,
                  ],
                ),
                ...dashedLines,
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name:
            "etrace_qr_codes_${now.toIso8601String().replaceAll(':', '-')}.pdf",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PDF enregistré avec succès.")),
      );
    } catch (e) {
      debugPrint("Erreur PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'enregistrement du PDF : $e")),
      );
    }
  }*/

  Future<void> _saveAsPdf() async {
    if (_previews.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aucun QR code à enregistrer.")),
      );
      return;
    }

    try {
      final pdf = pw.Document();
      final now = DateTime.now();
      final dateStr = "${now.day.toString().padLeft(2, '0')}/"
          "${now.month.toString().padLeft(2, '0')}/"
          "${now.year} ${now.hour.toString().padLeft(2, '0')}:"
          "${now.minute.toString().padLeft(2, '0')}";

      // Charge l'icône de l'app
      pw.ImageProvider? appIcon;
      try {
        final bytes = await rootBundle.load('assets/app/icon_app.png');
        appIcon = pw.MemoryImage(bytes.buffer.asUint8List());
      } catch (e) {
        appIcon = null;
      }

      // Paramètres de la grille
      const int columns = 4;
      const double qrSize = 110;
      const double cellPadding = 8;
      const double cellWidth = qrSize + cellPadding * 2;
      const double cellHeight = qrSize + 36 + cellPadding * 2;
      final rows = (_previews.length / columns).ceil();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(18),
          build: (context) {
            // En-tête
            final header = pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (appIcon != null) pw.Image(appIcon, width: 40, height: 40),
                pw.SizedBox(width: 12),
                pw.Text(
                  "eTrace - QR Codes Bovins",
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex("#1976D2"),
                  ),
                ),
                pw.Spacer(),
                pw.Text(
                  dateStr,
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
              ],
            );

            // Grille QR codes SVG
            final tableRows = <pw.TableRow>[];
            int idx = 0;
            for (int row = 0; row < rows; row++) {
              final cells = <pw.Widget>[];
              for (int col = 0; col < columns; col++) {
                if (idx < _previews.length) {
                  cells.add(
                    pw.Container(
                      width: cellWidth,
                      height: cellHeight,
                      padding: const pw.EdgeInsets.all(cellPadding),
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Container(
                            width: qrSize,
                            height: qrSize,
                            child: pw.SvgImage(svg: _previews[idx].svg),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            _previews[idx].code,
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  cells.add(
                    pw.Container(
                      width: cellWidth,
                      height: cellHeight,
                    ),
                  );
                }
                idx++;
              }
              tableRows.add(pw.TableRow(children: cells));
            }

            // Traits pointillés horizontaux et verticaux
            final List<pw.Widget> dashedLines = [];
            // Horizontaux
            for (int r = 1; r < rows; r++) {
              dashedLines.add(
                pw.Positioned(
                  top: 73 + r * cellHeight,
                  left: 0,
                  right: 0,
                  child: pw.Container(
                    height: 1,
                    child: pw.LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints!.maxWidth;
                        const dashWidth = 6.0;
                        const dashSpace = 4.0;
                        final dashCount =
                            (width / (dashWidth + dashSpace)).floor();
                        return pw.Row(
                          children: List.generate(dashCount, (i) {
                            return pw.Container(
                              width: dashWidth,
                              height: 1,
                              color: PdfColors.grey400,
                              margin: pw.EdgeInsets.only(
                                  right: i == dashCount - 1 ? 0 : dashSpace),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ),
              );
            }
            // Verticaux
            for (int c = 1; c < columns; c++) {
              dashedLines.add(
                pw.Positioned(
                  top: 73,
                  left: c * (cellWidth + 15),
                  bottom: 0,
                  child: pw.Container(
                    width: 1,
                    child: pw.LayoutBuilder(
                      builder: (context, constraints) {
                        final height = constraints!.maxHeight;
                        const dashHeight = 6.0;
                        const dashSpace = 4.0;
                        final dashCount =
                            (height / (dashHeight + dashSpace)).floor();
                        return pw.Column(
                          children: List.generate(dashCount, (i) {
                            return pw.Container(
                              width: 1,
                              height: dashHeight,
                              color: PdfColors.grey400,
                              margin: pw.EdgeInsets.only(
                                  bottom: i == dashCount - 1 ? 0 : dashSpace),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ),
              );
            }

            return pw.Stack(
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    header,
                    pw.Divider(thickness: 1),
                    pw.SizedBox(height: 12),
                    pw.Table(
                      border: null,
                      defaultVerticalAlignment:
                          pw.TableCellVerticalAlignment.middle,
                      children: tableRows,
                    ),
                  ],
                ),
                ...dashedLines,
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name:
            "etrace_qr_codes_${now.toIso8601String().replaceAll(':', '-')}.pdf",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PDF enregistré avec succès.")),
      );
    } catch (e) {
      debugPrint("Erreur PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'enregistrement du PDF : $e")),
      );
    }
  }

  /*Future<void> _saveAsPdf() async {
    final pdf = pw.Document();
    for (final preview in _previews) {
      final img = await networkImage(preview.svg); // fonctionne aussi avec SVG
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Center(
                child: pw.Image(img, width: 200, height: 200),
              ),
              pw.SizedBox(height: 12),
              pw.Text(preview.code,
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
      );
    }
    /*for (final preview in _previews) {
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            children: [
              pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: preview.code,
                width: 200,
                height: 200,
                color: PdfColor.fromHex('#5C8B29'), // bodyColor
                backgroundColor: PdfColor.fromHex('#FFFFFF'), // bgColor
              ),
              pw.SizedBox(height: 12),
              pw.Text(preview.code,
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
      );
    }*/
    /*for (final preview in _previews) {
      final qrCode = QrCode(4, QrErrorCorrectLevel.M);
      qrCode.addData(preview.code);
      final image = pw.BarcodeWidget(
        barcode: pw.Barcode.qrCode(),
        data: preview.code,
        width: 200,
        height: 200,
      );
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            children: [
              image,
              pw.SizedBox(height: 12),
              pw.Text(preview.code,
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
      );
    }*/
    /*for (final preview in _previews) {
      final img = await networkImage(preview.url);
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Center(
                child: pw.Image(img, width: 200, height: 200),
              ),
              pw.SizedBox(height: 12),
              pw.Text(preview.code,
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
            ],
          ),
        ),
      );
    }*/
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Générer des QR Codes Bovins"),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Paramètres de génération",
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            /*Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _countCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: "Nombre de QR codes à générer",
                        border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedRegion,
                    items: regions.entries
                        .map((e) => DropdownMenuItem(
                              value: e.key,
                              child: Text("${e.key} - ${e.value}"),
                            ))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedRegion = v!;
                      });
                    },
                    decoration: const InputDecoration(
                        labelText: "Région", border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),*/
            // ...existing code...
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _countCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: "Nombre de QR codes à générer",
                        border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  // <-- Ajoute cet Expanded ici
                  child: DropdownButtonFormField<String>(
                    value: _selectedRegion,
                    items: regions.entries
                        .map((e) => DropdownMenuItem(
                              value: e.key,
                              child: Text("${e.key} - ${e.value}"),
                            ))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedRegion = v!;
                      });
                    },
                    decoration: const InputDecoration(
                        labelText: "Région", border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
// ...existing code...
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _prefixCtrl,
                    decoration: const InputDecoration(
                        labelText: "Préfixe (ex: BOV)",
                        border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InputDatePickerFormField(
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    onDateSubmitted: (d) => setState(() => _date = d),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Center(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _generateQRCodes,
                icon: const Icon(Icons.qr_code_2),
                label: const Text("Générer les QR Codes"),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(const Color(0xFF1976D2)),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                  textStyle: MaterialStateProperty.all(GoogleFonts.nunito(
                      fontWeight: FontWeight.bold, fontSize: 18)),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_previews.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Aperçu des QR Codes générés :",
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    Expanded(
                      child: GridView.builder(
                        itemCount: _previews.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.85),
                        itemBuilder: (ctx, i) {
                          final prev = _previews[i];
                          return Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: SvgPicture.string(
                                      prev.svg,
                                      placeholderBuilder: (ctx) => const Center(
                                          child: CircularProgressIndicator()),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    prev.code,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.nunito(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              // ...dans GridView.builder :
                              /*child: QrImageView(
                                data: prev.code,
                                version: QrVersions.auto,
                                size: 180,
                                backgroundColor: Colors.white, // bgColor
                                eyeStyle: const QrEyeStyle(
                                  eyeShape:
                                      QrEyeShape.square, // closest to "frame14"
                                  color: Color(
                                      0xFF3F6B2B), // eye1Color/eye2Color/eye3Color
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape
                                      .circle, // closest to "rounded-pointed"
                                  color: Color(0xFF5C8B29), // bodyColor
                                ),
                                embeddedImage: AssetImage(
                                    'assets/app/icon_app.png'), // Mets ton logo ici si besoin
                                embeddedImageStyle:
                                    QrEmbeddedImageStyle(size: Size(40, 40)),
                              ),*/
                              /*child: QrImageView(
                                data: prev.code,
                                version: QrVersions.auto,
                                size: 180,
                                backgroundColor: Colors.white,
                                embeddedImage: NetworkImage(
                                    "https://www.qrcode-monkey.com/img/monkey_face.png"), // ou ton logo
                                embeddedImageStyle:
                                    QrEmbeddedImageStyle(size: Size(40, 40)),
                              ),*/
                              /*child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Image.network(
                                      prev.url,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    prev.code,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.nunito(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),*/
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _saveAsPdf,
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text("Enregistrer en PDF"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          textStyle: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold, fontSize: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/*class _QRPreview {
  final String code;
  final String svg;
  _QRPreview({required this.code, required this.svg});
}*/

class _QRPreview {
  final String code; // lisible (pour affichage dans l'app)
  final String svg;
  final String encrypted; // code chiffré (pour QR)
  _QRPreview({required this.code, required this.svg, required this.encrypted});
}

/*class _QRPreview {
  final String code;
  _QRPreview({required this.code});
}*/

// Pour ouvrir ce générateur depuis ton app principale, ajoute un bouton comme :
/*ElevatedButton.icon(
  icon: const Icon(Icons.qr_code_2),
  label: const Text("Générer des QR Codes Bovins"),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF1976D2),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    textStyle: GoogleFonts.nunito(fontWeight: FontWeight.bold),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ),
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const QRGeneratorScreen()),
    );
  },
);*/

// N'oublie pas d'ajouter les dépendances dans pubspec.yaml :
// http: ^1.2.1
// pdf: ^3.10.8
// printing: ^5.12.0

// ...existing code...

/*class ContHealthScreen extends StatefulWidget {
  const ContHealthScreen({super.key});

  @override
  _ContHealthScreenState createState() => _ContHealthScreenState();
}

class _ContHealthScreenState extends State<ContHealthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SoftAppBar(
        title: "Suivi de la santé",
        actions: [Icon(Icons.settings_outlined)],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Cette page vous permet de suivre la santé des bovins.",
              //style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}*/
