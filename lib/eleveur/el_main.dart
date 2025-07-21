import 'package:etrace/login.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

class ElMain extends StatefulWidget {
  const ElMain({super.key});

  @override
  State<ElMain> createState() => _ElMainState();
}

class _ElMainState extends State<ElMain> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _showPendingRequests = false;

  // Variables dynamiques
  String displayName = '';
  String role = '';
  String photoUrl = '';

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('eleveurs')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        displayName = data['displayName'] ?? '';
        role = data['role'] ?? 'eleveur';
        photoUrl = data['photoURL'] ?? '';
      });
    }
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Profil"),
            onTap: () {
              Navigator.pop(ctx);
              _showProfileDialog(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Déconnexion", style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Déconnexion réussie")),
              );
              if (mounted) {
                /*Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MyLogin()),
                  (Route<dynamic> route) => false,
                );*/
                Navigator.of(context, rootNavigator: true).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MyLogin()),
                );
              }
              //Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }

  void _showProfileDialog(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    final doc = await FirebaseFirestore.instance
        .collection('eleveurs')
        .doc(user?.uid)
        .get();
    final data = doc.data() ?? {};
    final TextEditingController nameController = TextEditingController(
      text: data['displayName'] ?? '',
    );
    final TextEditingController emailController = TextEditingController(
      text: data['email'] ?? '',
    );
    final TextEditingController phoneController = TextEditingController(
      text: data['phoneNumber'] ?? '',
    );

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: Duration(milliseconds: 600),
      pageBuilder: (ctx, anim1, anim2) => SizedBox.shrink(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.elasticOut.transform(anim1.value),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text("Mon Profil"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : AssetImage('assets/images/frame.png') as ImageProvider,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Nom"),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  readOnly: true,
                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: "Téléphone"),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text("Fermer"),
                onPressed: () => Navigator.pop(ctx),
              ),
              ElevatedButton(
                child: Text("Mettre à jour"),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user?.uid)
                      .update({
                    'displayName': nameController.text,
                    'phoneNumber': phoneController.text,
                  });
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Profil mis à jour")));
                  Navigator.pop(ctx);
                  setState(() {
                    displayName = nameController.text;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _setupAuthListener() {
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User signed out');
      } else {
        print('User signed in');
      }
    });
  }

  Future<void> _signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MyLogin()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de déconnexion: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildProfileSection(DocumentSnapshot userDoc, User user) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.blue.shade50,
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundImage: user.photoURL != null
                ? NetworkImage(user.photoURL!)
                : const AssetImage('assets/images/autre.png') as ImageProvider,
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userDoc['displayName'] ?? 'Nom non renseigné',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userDoc['phoneNumber'] ?? 'Téléphone non renseigné',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    color: Colors.blueGrey.shade400,
                  ),
                ),
                Text(
                  '${userDoc['ville'] ?? 'Ville non renseignée'}, ${userDoc['region'] ?? 'Région non renseignée'}',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    color: Colors.blueGrey.shade400,
                  ),
                ),
                Text(
                  "Email: ${user.email ?? 'Email non renseigné'}",
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: Colors.blueGrey.shade300,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _signOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Déconnexion'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendAlerteSanitaire(String userId, String userName) async {
    try {
      await _firestore.collection('alertes_sanitaires').add({
        'eleveurId': userId,
        'eleveurNom': userName,
        'date': FieldValue.serverTimestamp(),
        'statut': 'nouvelle',
        'traitee': false,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alerte sanitaire envoyée au MINEPIA'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'envoi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildPendingRequestsSection(AsyncSnapshot<QuerySnapshot> snapshot) {
    final demandes = snapshot.data?.docs ?? [];
    if (demandes.isEmpty) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        InkWell(
          onTap: () =>
              setState(() => _showPendingRequests = !_showPendingRequests),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Demandes QR en attente (${demandes.length})",
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue.shade800,
                  ),
                ),
                Icon(
                  _showPendingRequests ? Icons.expand_less : Icons.expand_more,
                  color: Colors.blue.shade800,
                ),
              ],
            ),
          ),
        ),
        if (_showPendingRequests) ...[
          const SizedBox(height: 12),
          ...demandes.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${data['nombreQR']} QR code(s) demandé(s)",
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Chip(
                          backgroundColor: Colors.orange.shade100,
                          label: const Text(
                            "En attente",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(data['description']),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          "${data['ville']}, ${data['departement']}, ${data['region']}",
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy à HH:mm').format(
                              (data['dateCreation'] as Timestamp).toDate()),
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  Widget _statCard(String label, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label : ",
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            "$value",
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 21,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Center(child: Text('Utilisateur non connecté'));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Hero(
              tag: "qr_icon",
              child: Icon(Icons.qr_code_2, color: Color(0xFF1976D2), size: 30),
            ),
            const SizedBox(width: 10),
            Text(
              "Tableau Eleveur",
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: const Color(0xFF1976D2),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.black),
              //onPressed: () {},
              onPressed: () => _showSettingsMenu(context),
            ),
          ],
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1976D2)),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('eleveurs').doc(user.uid).snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return const Center(
                child: Text('Données utilisateur non trouvées'));
          }

          final userDoc = userSnapshot.data!;

          return StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('eleveurs')
                .doc(user.uid)
                .collection('bovins')
                .snapshots(),
            builder: (context, bovinsSnapshot) {
              if (bovinsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final bovins = bovinsSnapshot.data?.docs ?? [];
              final total = bovins.length;
              final males = bovins.where((b) => b['sexe'] == 'Mâle').length;
              final femelles =
                  bovins.where((b) => b['sexe'] == 'Femelle').length;
              final naissances =
                  bovins.where((b) => b['naissance'] == true).length;
              final malades = bovins.where((b) => b['malade'] == true).length;
              final traitements =
                  bovins.where((b) => b['traitement'] == true).length;
              final abattus = bovins.where((b) => b['abattu'] == true).length;

              return StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('eleveurs')
                    .doc(user.uid)
                    .collection('demandes')
                    .where('statut', isEqualTo: 'en_attente')
                    .snapshots(),
                builder: (context, demandesSnapshot) {
                  if (demandesSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final demandesQr = demandesSnapshot.data?.docs.fold<int>(0,
                          (sum, doc) => sum + (doc['nombreQR'] as int? ?? 0)) ??
                      0;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profil Eleveur
                        _buildProfileSection(userDoc, user),
                        const SizedBox(height: 18),

                        // Statistiques bovins
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 18, horizontal: 12),
                            child: Column(
                              children: [
                                Text(
                                  "Statistiques de vos bovins",
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.blueGrey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  childAspectRatio: 2.7,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  children: [
                                    _statCard("Total", total, Icons.pets,
                                        Colors.blue.shade700),
                                    _statCard("Mâles", males,
                                        FontAwesomeIcons.mars, Colors.blue),
                                    _statCard("Femelles", femelles,
                                        FontAwesomeIcons.venus, Colors.pink),
                                    _statCard("Naissances", naissances,
                                        Icons.cake_outlined, Colors.green),
                                    _statCard(
                                        "Malades",
                                        malades,
                                        Icons.warning_amber_rounded,
                                        Colors.red),
                                    _statCard("Traitement", traitements,
                                        Icons.medical_services, Colors.orange),
                                    _statCard("Abattus", abattus,
                                        Icons.cancel_outlined, Colors.brown),
                                    _statCard("Demandes QR", demandesQr,
                                        Icons.qr_code_2, Colors.purple),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Demandes en attente
                        _buildPendingRequestsSection(demandesSnapshot),

                        const SizedBox(height: 16),

                        // Boutons actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => context.go('/vol'),
                              icon: const Icon(Icons.warning_amber),
                              label: const Text("Déclarer un vol"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade700,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                textStyle: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 14,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => context.go('/demande'),
                              icon: const Icon(Icons.qr_code_2),
                              label: const Text("Demande QR"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple.shade700,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                textStyle: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => context.go('/history'),
                              icon: const Icon(Icons.warning_amber),
                              label: const Text("Historique"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                textStyle: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 14,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _sendAlerteSanitaire(user.uid,
                                  userDoc['displayName'] ?? 'Nom inconnu'),
                              icon: const Icon(Icons.qr_code_2),
                              label: const Text("Alerte Sanitaire"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                textStyle: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

/*import 'package:etrace/login.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

class ElMain extends StatefulWidget {
  const ElMain({super.key});

  @override
  State<ElMain> createState() => _ElMainState();
}

class _ElMainState extends State<ElMain> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Map<String, dynamic>? eleveur;
  List<Map<String, dynamic>> bovins = [];
  List<Map<String, dynamic>> demandesEnAttente = [];
  int demandesQr = 0;
  bool _isLoading = true;
  bool _showPendingRequests = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadBovinsData();
    _loadPendingRequests();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
  }

  /*Future<void> _signOut() async {
    try {
      setState(() => _isLoading = true);
      await _auth.signOut();
      await _googleSignIn.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MyLogin()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de déconnexion: ${e.toString()}')),
      );
      setState(() => _isLoading = false);
    }
  }*/

  Future<void> _signOut() async {
    try {
      setState(() => _isLoading = true);

      // Déconnexion synchrone pour éviter les problèmes de timing
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);

      if (mounted) {
        // Navigation avec remplacement pour éviter de revenir en arrière
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MyLogin()),
          (Route<dynamic> route) => false,
        );

        // Message de confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Déconnexion réussie'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de déconnexion: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildProfileSection() {
    if (eleveur == null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.blue.shade50,
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.blue.shade50,
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundImage: eleveur!['photo'].toString().startsWith('http')
                ? NetworkImage(eleveur!['photo'])
                : AssetImage(eleveur!['photo']) as ImageProvider,
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(eleveur!['nom'],
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 4),
                Text(eleveur!['contact'],
                    style: GoogleFonts.nunito(
                        fontSize: 15, color: Colors.blueGrey.shade400)),
                Text(eleveur!['adresse'] as String,
                    style: GoogleFonts.nunito(
                        fontSize: 15, color: Colors.blueGrey.shade400)),
                Text("Email: ${eleveur!['identifiant']}",
                    style: GoogleFonts.nunito(
                        fontSize: 14, color: Colors.blueGrey.shade300)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _signOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Déconnexion'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendAlerteSanitaire() async {
    try {
      setState(() => _isLoading = true);
      final User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('alertes_sanitaires').add({
          'eleveurId': user.uid,
          'eleveurNom': eleveur?['nom'] ?? 'Nom inconnu',
          'date': FieldValue.serverTimestamp(),
          'statut': 'nouvelle',
          'traitee': false,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alerte sanitaire envoyée au MINEPIA'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'envoi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('eleveurs').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            eleveur = {
              'nom': doc['displayName'] ?? 'Nom non renseigné',
              'contact': doc['phoneNumber'] ?? 'Téléphone non renseigné',
              'adresse':
                  '${doc['ville'] ?? 'Ville non renseignée'}, ${doc['region'] ?? 'Région non renseignée'}',
              'identifiant': user.email ?? 'Email non renseigné',
              'photo': user.photoURL ?? 'assets/images/autre.png',
            };
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadBovinsData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final query = await _firestore
            .collection('eleveurs')
            .doc(user.uid)
            .collection('bovins')
            .get();

        final List<Map<String, dynamic>> loadedBovins = [];
        int qrDemands = 0;

        for (var doc in query.docs) {
          final data = doc.data();
          loadedBovins.add({
            'code': doc.id,
            'sexe': data['sexe'] ?? 'Non spécifié',
            'etat': data['etat'] ?? 'Sain',
            'naissance': data['naissance'] ?? false,
            'malade': data['malade'] ?? false,
            'traitement': data['traitement'] ?? false,
            'abattu': data['abattu'] ?? false,
          });

          if (data['demandeQr'] == true) {
            qrDemands++;
          }
        }

        setState(() {
          bovins = loadedBovins;
          demandesQr = qrDemands;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadPendingRequests() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final query = await _firestore
            .collection('eleveurs')
            .doc(user.uid)
            .collection('demandes')
            .where('statut', isEqualTo: 'en_attente')
            //.orderBy('dateCreation', descending: true)
            .get();

        final List<Map<String, dynamic>> loadedDemandes = [];
        int totalQrDemandes = 0; // Variable pour le total des QR demandés

        for (var doc in query.docs) {
          final data = doc.data();
          final nombreQR = data['nombreQR'] ?? 0;
          totalQrDemandes += nombreQR as int; // Ajouter au total

          loadedDemandes.add({
            'id': doc.id,
            'nombreQR': nombreQR,
            'description': data['description'],
            'dateCreation': data['dateCreation']?.toDate(),
            'region': data['region'],
            'departement': data['departement'],
            'ville': data['ville'],
          });
        }

        setState(() {
          demandesEnAttente = loadedDemandes;
          demandesQr =
              totalQrDemandes; // Mettre à jour le total des QR demandés
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement: ${e.toString()}')),
      );
      setState(() => _isLoading = false);
    }
  }

  Widget _buildPendingRequestsSection() {
    if (demandesEnAttente.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        InkWell(
          onTap: () =>
              setState(() => _showPendingRequests = !_showPendingRequests),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Demandes QR en attente (${demandesEnAttente.length})",
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue.shade800,
                  ),
                ),
                Icon(
                  _showPendingRequests ? Icons.expand_less : Icons.expand_more,
                  color: Colors.blue.shade800,
                ),
              ],
            ),
          ),
        ),
        if (_showPendingRequests) ...[
          const SizedBox(height: 12),
          ...demandesEnAttente
              .map((demande) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${demande['nombreQR']} QR code(s) demandé(s)",
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Chip(
                                backgroundColor: Colors.orange.shade100,
                                label: Text(
                                  "En attente",
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            demande['description'],
                            style: GoogleFonts.nunito(),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                "${demande['ville']}, ${demande['departement']}, ${demande['region']}",
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('dd/MM/yyyy à HH:mm')
                                    .format(demande['dateCreation']),
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = bovins.length;
    final males = bovins.where((b) => b['sexe'] == 'Mâle').length;
    final femelles = bovins.where((b) => b['sexe'] == 'Femelle').length;
    final naissances = bovins.where((b) => b['naissance'] == true).length;
    final malades = bovins.where((b) => b['malade'] == true).length;
    final traitements = bovins.where((b) => b['traitement'] == true).length;
    final abattus = bovins.where((b) => b['abattu'] == true).length;

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
              child: Icon(Icons.qr_code_2,
                  color: const Color(0xFF1976D2), size: 30),
            ),
            const SizedBox(width: 10),
            Text("Tableau Eleveur",
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: const Color(0xFF1976D2))),
          ],
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1976D2)),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profil Eleveur
                  _buildProfileSection(),
                  const SizedBox(height: 18),

                  // Statistiques bovins arrangées en grille
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 12),
                      child: Column(
                        children: [
                          Text("Statistiques de vos bovins",
                              style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.blueGrey.shade700)),
                          const SizedBox(height: 18),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 2.7,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            children: [
                              _statCard("Total", total, Icons.pets,
                                  Colors.blue.shade700),
                              _statCard("Mâles", males, FontAwesomeIcons.mars,
                                  Colors.blue),
                              _statCard("Femelles", femelles,
                                  FontAwesomeIcons.venus, Colors.pink),
                              _statCard("Naissances", naissances,
                                  Icons.cake_outlined, Colors.green),
                              _statCard("Malades", malades,
                                  Icons.warning_amber_rounded, Colors.red),
                              _statCard("Traitement", traitements,
                                  Icons.medical_services, Colors.orange),
                              _statCard("Abattus", abattus,
                                  Icons.cancel_outlined, Colors.brown),
                              //_statCard("Demandes QR", demandesQr,
                              //Icons.qr_code_2, Colors.purple),
                              _statCard(
                                "Demandes QR",
                                demandesQr, // Utilisation du total calculé
                                Icons.qr_code_2,
                                Colors.purple,
                                //suffix: "QR", // Ajout d'un suffixe
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Section des demandes en attente
                  _buildPendingRequestsSection(),

                  const SizedBox(height: 16),

                  // Boutons actions globales
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          context.go('/vol', extra: {});
                        },
                        icon: const Icon(Icons.warning_amber),
                        label: const Text("Déclarer un vol"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          textStyle: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 14),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.go('/demande', extra: {});
                        },
                        icon: const Icon(Icons.qr_code_2),
                        label: const Text("Demande QR"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          textStyle: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          context.go('/history', extra: {});
                        },
                        icon: const Icon(Icons.warning_amber),
                        label: const Text("Historique"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          textStyle: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 14),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _sendAlerteSanitaire,
                        icon: const Icon(Icons.qr_code_2),
                        label: const Text("Alerte Sanitaire"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          textStyle: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statCard(String label, int value, IconData icon, Color color,
      {String? suffix}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label : ",
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w600, color: color, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            "$value${suffix != null ? ' $suffix' : ''}", // Ajout du suffixe conditionnel
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold, color: color, fontSize: 21),
          ),
        ],
      ),
    );
  }
}*/

/*import 'package:etrace/login.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ElMain extends StatefulWidget {
  const ElMain({super.key});

  @override
  State<ElMain> createState() => _ElMainState();
}

class _ElMainState extends State<ElMain> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Map<String, dynamic>? eleveur;
  List<Map<String, dynamic>> bovins = [];
  int demandesQr = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadBovinsData();
  }

  Future<void> _loadUserData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('eleveurs').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            eleveur = {
              'nom': doc['displayName'] ?? 'Nom non renseigné',
              'contact': doc['phoneNumber'] ?? 'Téléphone non renseigné',
              'adresse':
                  '${doc['ville'] ?? 'Ville non renseignée'}, ${doc['region'] ?? 'Région non renseignée'}',
              'identifiant': user.email ?? 'Email non renseigné',
              'photo': user.photoURL ?? 'assets/images/autre.png',
            };
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadBovinsData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final query = await _firestore
            .collection('eleveurs')
            .doc(user.uid)
            .collection('bovins')
            .get();

        final List<Map<String, dynamic>> loadedBovins = [];
        int qrDemands = 0;

        for (var doc in query.docs) {
          final data = doc.data();
          loadedBovins.add({
            'code': doc.id,
            'sexe': data['sexe'] ?? 'Non spécifié',
            'etat': data['etat'] ?? 'Sain',
            'naissance': data['naissance'] ?? false,
            'malade': data['malade'] ?? false,
            'traitement': data['traitement'] ?? false,
            'abattu': data['abattu'] ?? false,
          });

          if (data['demandeQr'] == true) {
            qrDemands++;
          }
        }

        setState(() {
          bovins = loadedBovins;
          demandesQr = qrDemands;
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement: ${e.toString()}')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    try {
      setState(() => _isLoading = true);
      await _auth.signOut();
      await _googleSignIn.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MyLogin()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de déconnexion: ${e.toString()}')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendAlerteSanitaire() async {
    try {
      setState(() => _isLoading = true);
      final User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('alertes_sanitaires').add({
          'eleveurId': user.uid,
          'eleveurNom': eleveur?['nom'] ?? 'Nom inconnu',
          'date': FieldValue.serverTimestamp(),
          'statut': 'nouvelle',
          'traitee': false,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alerte sanitaire envoyée au MINEPIA'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'envoi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildProfileSection() {
    if (eleveur == null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.blue.shade50,
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.blue.shade50,
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundImage: eleveur!['photo'].toString().startsWith('http')
                ? NetworkImage(eleveur!['photo'])
                : AssetImage(eleveur!['photo']) as ImageProvider,
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(eleveur!['nom'],
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 4),
                Text(eleveur!['contact'],
                    style: GoogleFonts.nunito(
                        fontSize: 15, color: Colors.blueGrey.shade400)),
                Text(eleveur!['adresse'] as String,
                    style: GoogleFonts.nunito(
                        fontSize: 15, color: Colors.blueGrey.shade400)),
                Text("Email: ${eleveur!['identifiant']}",
                    style: GoogleFonts.nunito(
                        fontSize: 14, color: Colors.blueGrey.shade300)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _signOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Déconnexion'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = bovins.length;
    final males = bovins.where((b) => b['sexe'] == 'Mâle').length;
    final femelles = bovins.where((b) => b['sexe'] == 'Femelle').length;
    final naissances = bovins.where((b) => b['naissance'] == true).length;
    final malades = bovins.where((b) => b['malade'] == true).length;
    final traitements = bovins.where((b) => b['traitement'] == true).length;
    final abattus = bovins.where((b) => b['abattu'] == true).length;

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
              child: Icon(Icons.qr_code_2,
                  color: const Color(0xFF1976D2), size: 30),
            ),
            const SizedBox(width: 10),
            Text("Tableau Eleveur",
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: const Color(0xFF1976D2))),
          ],
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1976D2)),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profil Eleveur
                  _buildProfileSection(),
                  const SizedBox(height: 18),

                  // Statistiques bovins arrangées en grille
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 12),
                      child: Column(
                        children: [
                          Text("Statistiques de vos bovins",
                              style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.blueGrey.shade700)),
                          const SizedBox(height: 18),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 2.7,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            children: [
                              _statCard("Total", total, Icons.pets,
                                  Colors.blue.shade700),
                              _statCard("Mâles", males, FontAwesomeIcons.mars,
                                  Colors.blue),
                              _statCard("Femelles", femelles,
                                  FontAwesomeIcons.venus, Colors.pink),
                              _statCard("Naissances", naissances,
                                  Icons.cake_outlined, Colors.green),
                              _statCard("Malades", malades,
                                  Icons.warning_amber_rounded, Colors.red),
                              _statCard("Traitement", traitements,
                                  Icons.medical_services, Colors.orange),
                              _statCard("Abattus", abattus,
                                  Icons.cancel_outlined, Colors.brown),
                              _statCard("Demandes QR", demandesQr,
                                  Icons.qr_code_2, Colors.purple),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Boutons actions globales
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          context.go('/vol', extra: {});
                        },
                        icon: const Icon(Icons.warning_amber),
                        label: const Text("Déclarer un vol"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          textStyle: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 14),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.go('/demande', extra: {});
                        },
                        icon: const Icon(Icons.qr_code_2),
                        label: const Text("Demande QR"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          textStyle: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          context.go('/history', extra: {});
                        },
                        icon: const Icon(Icons.warning_amber),
                        label: const Text("Historique"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          textStyle: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 14),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _sendAlerteSanitaire,
                        icon: const Icon(Icons.qr_code_2),
                        label: const Text("Alerte Sanitaire"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          textStyle: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statCard(String label, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label : ",
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w600, color: color, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            "$value",
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold, color: color, fontSize: 21),
          ),
        ],
      ),
    );
  }
}*/

/*import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';

class ElMain extends StatefulWidget {
  const ElMain({super.key});

  @override
  State<ElMain> createState() => _ElMainState();
}

class _ElMainState extends State<ElMain> with TickerProviderStateMixin {
  // Dummy profile data
  final Map<String, dynamic> eleveur = {
    'nom': 'M. Kamga Paul',
    'contact': '+237 655 123 789',
    'adresse': 'Bafia, Centre',
    'identifiant': 'ELV-2025-003',
    'photo': 'assets/images/autre.png',
  };

  // Dummy bovin stats
  final List<Map<String, dynamic>> bovins = [
    {
      'code': 'BOV-CEN-20250621-0001',
      'sexe': 'Femelle',
      'etat': 'Sain',
      'naissance': true,
      'malade': false,
      'traitement': false,
      'abattu': false,
    },
    {
      'code': 'BOV-CEN-20250621-0002',
      'sexe': 'Mâle',
      'etat': 'Malade',
      'naissance': false,
      'malade': true,
      'traitement': true,
      'abattu': false,
    },
    {
      'code': 'BOV-CEN-20250621-0003',
      'sexe': 'Femelle',
      'etat': 'Sain',
      'naissance': false,
      'malade': false,
      'traitement': false,
      'abattu': false,
    },
    {
      'code': 'BOV-CEN-20250621-0004',
      'sexe': 'Mâle',
      'etat': 'Abattu',
      'naissance': false,
      'malade': false,
      'traitement': false,
      'abattu': true,
    },
  ];

  final int demandesQr = 2;

  // ...existing code...
  @override
  Widget build(BuildContext context) {
    final total = bovins.length;
    final males = bovins.where((b) => b['sexe'] == 'Mâle').length;
    final femelles = bovins.where((b) => b['sexe'] == 'Femelle').length;
    final naissances = bovins.where((b) => b['naissance'] == true).length;
    final malades = bovins.where((b) => b['malade'] == true).length;
    final traitements = bovins.where((b) => b['traitement'] == true).length;
    final abattus = bovins.where((b) => b['abattu'] == true).length;

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
              child: Icon(Icons.qr_code_2,
                  color: const Color(0xFF1976D2), size: 30),
            ),
            const SizedBox(width: 10),
            Text("Tableau Eleveur",
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profil Eleveur
              Container(
                //elevation: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.blue.shade50,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundImage: AssetImage(eleveur['photo']),
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(eleveur['nom'],
                                style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                            const SizedBox(height: 4),
                            Text(eleveur['contact'],
                                style: GoogleFonts.nunito(
                                    fontSize: 15,
                                    color: Colors.blueGrey.shade400)),
                            Text(eleveur['adresse'],
                                style: GoogleFonts.nunito(
                                    fontSize: 15,
                                    color: Colors.blueGrey.shade400)),
                            Text("ID: ${eleveur['identifiant']}",
                                style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    color: Colors.blueGrey.shade300)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Statistiques bovins arrangées en grille
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                  child: Column(
                    children: [
                      Text("Statistiques de vos bovins",
                          style: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.blueGrey.shade700)),
                      const SizedBox(height: 18),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 2.7,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        children: [
                          _statCard(
                              "Total", total, Icons.pets, Colors.blue.shade700),
                          _statCard("Mâles", males, FontAwesomeIcons.mars,
                              Colors.blue),
                          _statCard("Femelles", femelles,
                              FontAwesomeIcons.venus, Colors.pink),
                          _statCard("Naissances", naissances,
                              Icons.cake_outlined, Colors.green),
                          _statCard("Malades", malades,
                              Icons.warning_amber_rounded, Colors.red),
                          _statCard("Traitement", traitements,
                              Icons.medical_services, Colors.orange),
                          _statCard("Abattus", abattus, Icons.cancel_outlined,
                              Colors.brown),
                          _statCard("Demandes QR", demandesQr, Icons.qr_code_2,
                              Colors.purple),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Boutons actions globales
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      context.go('/vol', extra: {});
                      //Navigator.of(context).pushNamed('declaration_vol');
                    },
                    icon: const Icon(Icons.warning_amber),
                    label: const Text("Déclarer un vol"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      textStyle: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 14),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.go('/demande', extra: {});
                      //Navigator.of(context).pushNamed('demande_qr');
                    },
                    icon: const Icon(Icons.qr_code_2),
                    label: const Text("Demande QR"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      textStyle: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      context.go('/history', extra: {});
                      //Navigator.of(context).pushNamed('declaration_vol');
                    },
                    icon: const Icon(Icons.warning_amber),
                    label: const Text("Historique"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      textStyle: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 14),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.go('/alert', extra: {});
                      //Navigator.of(context).pushNamed('demande_qr');
                    },
                    icon: const Icon(Icons.qr_code_2),
                    label: const Text("Alerte Sanitaire"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      textStyle: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label : ",
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w600, color: color, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            "$value",
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold, color: color, fontSize: 21),
          ),
        ],
      ),
    );
  }
}*/
