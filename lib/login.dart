import 'package:etrace/abator/aba.dart';
import 'package:etrace/agent/checkpoint/check.dart';
import 'package:etrace/agent/controler/cont.dart';
import 'package:etrace/eleveur/el.dart';
import 'package:etrace/veto/veto.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

enum UserRole { agentMinepia, agentAbattage, veterinaire, eleveur }

class MyLogin extends StatelessWidget {
  const MyLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eTrace',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const RoleSelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  UserRole? selectedRole;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _googleSignIn.disconnect();
    super.dispose();
  }

  Widget roleTile({
    required UserRole role,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Color(0xff4A7B58) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color:
              isSelected ? Color(0xff4A7B58).withOpacity(0.07) : Colors.white,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(0xff4A7B58).withOpacity(0.08),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 30,
                color: isSelected ? Color(0xff4A7B58) : Color(0xffB0B0B0)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: isSelected
                  ? Icon(
                      Icons.radio_button_checked,
                      color: Color(0xff4A7B58),
                      key: ValueKey(true),
                    )
                  : Icon(
                      Icons.radio_button_off,
                      color: Colors.grey,
                      key: ValueKey(false),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.agentMinepia:
        return 'Agent MINEPIA';
      case UserRole.agentAbattage:
        return 'Agent Abattage';
      case UserRole.veterinaire:
        return 'Vétérinaire';
      case UserRole.eleveur:
        return 'Éleveur';
    }
  }

  String getRoleCollection(UserRole role) {
    switch (role) {
      case UserRole.agentMinepia:
        return 'minepia_agents';
      case UserRole.agentAbattage:
        return 'abattage_agents';
      case UserRole.veterinaire:
        return 'vetos';
      case UserRole.eleveur:
        return 'eleveurs';
    }
  }

  Future<void> _signInWithGoogle() async {
    if (selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un rôle')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Démarrer le processus de connexion Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // L'utilisateur a annulé la connexion
      }

      // Obtenir les authentifications Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Créer un credential Google
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Connecter avec Firebase Auth
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Vérifier si l'utilisateur existe déjà dans Firestore
        final roleCollection = getRoleCollection(selectedRole!);
        final userDoc =
            await _firestore.collection(roleCollection).doc(user.uid).get();

        if (!userDoc.exists) {
          // Enregistrer le nouvel utilisateur dans Firestore
          await _firestore.collection(roleCollection).doc(user.uid).set({
            'uid': user.uid,
            'email': user.email,
            'displayName': user.displayName,
            'photoURL': user.photoURL,
            'phoneNumber': user.phoneNumber,
            'role': selectedRole.toString().split('.').last,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
          });
        } else {
          // Mettre à jour la dernière connexion
          await _firestore.collection(roleCollection).doc(user.uid).update({
            'lastLogin': FieldValue.serverTimestamp(),
          });
        }

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connecté en tant que ${user.displayName}'),
            backgroundColor: Colors.green,
          ),
        );

        // Rediriger vers le dashboard approprié
        _goToDashboard();
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Une erreur est survenue';
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage = 'Un compte existe déjà avec cette adresse email';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Identifiants invalides';
      } else if (e.code == 'operation-not-allowed') {
        errorMessage = 'Connexion Google non autorisée';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'Ce compte a été désactivé';
      } else if (e.code == 'user-not-found') {
        errorMessage = 'Utilisateur non trouvé';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Mot de passe incorrect';
      } else if (e.code == 'network-request-failed') {
        errorMessage = 'Problème de connexion internet';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur inattendue: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _signInWithApple() {
    if (selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un rôle')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Connexion avec Apple en tant que ${getRoleLabel(selectedRole!)}'),
      ),
    );
  }

  void _goToDashboard() {
    if (selectedRole == null) return;
    Widget dashboard;

    switch (selectedRole!) {
      case UserRole.agentMinepia:
        dashboard = MyAppCont();
        break;
      case UserRole.agentAbattage:
        dashboard = MyAppAba();
        break;
      case UserRole.veterinaire:
        dashboard = MyAppVeto();
        break;
      case UserRole.eleveur:
        dashboard = MyAppEl();
        break;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => dashboard),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 16),
                    Hero(
                      tag: 'logo-hero',
                      child: SvgPicture.asset('assets/icons/logo.svg',
                          height: 124),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'Bienvenue sur eTrace',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Choisissez votre rôle pour accéder à\n l'écosystème eTrace",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 18, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 24),
                    roleTile(
                      role: UserRole.agentMinepia,
                      icon: Icons.badge,
                      title: 'Agent MINEPIA',
                      subtitle: 'Gérez les activités officielles du secteur.',
                    ),
                    roleTile(
                      role: UserRole.agentAbattage,
                      icon: Icons.gavel,
                      title: 'Agent Abattage',
                      subtitle: 'Validez les opérations d\'abattage.',
                    ),
                    roleTile(
                      role: UserRole.veterinaire,
                      icon: Icons.medical_services,
                      title: 'Vétérinaire',
                      subtitle: 'Assurez le suivi sanitaire des bovins.',
                    ),
                    roleTile(
                      role: UserRole.eleveur,
                      icon: Icons.pets,
                      title: 'Éleveur',
                      subtitle: 'Gérez vos animaux et le suivi d\'élevage.',
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black),
                                ),
                              )
                            : SvgPicture.asset(
                                'assets/icons/login_google.svg',
                                width: 24,
                                height: 24,
                                colorFilter: ColorFilter.mode(
                                  Colors.black,
                                  BlendMode.srcIn,
                                ),
                              ),
                        label: Text(
                          _isLoading
                              ? "Connexion en cours..."
                              : "Continuer avec Google",
                          style: const TextStyle(color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _signInWithApple,
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
                            : SvgPicture.asset(
                                'assets/icons/login_apple.svg',
                                width: 24,
                                height: 24,
                                colorFilter: ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                        label: Text(
                          _isLoading
                              ? "Connexion en cours..."
                              : "Continuer avec Apple",
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedOpacity(
                      opacity: 1,
                      duration: const Duration(milliseconds: 900),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Vos données sont protégées. Elles servent uniquement à personnaliser votre expérience sur eTrace.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    AnimatedOpacity(
                      opacity: 1,
                      duration: const Duration(milliseconds: 900),
                      child: InkWell(
                        onTap: () async {
                          final url = Uri.parse(
                            'https://www.iubenda.com/privacy-policy/57831804',
                          );
                          await launchUrl(url);
                        },
                        child: const Text(
                          'Politique de confidentialité.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF2E7D32),
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const ModalBarrier(
                dismissible: false,
                color: Colors.black54,
              ),
            if (_isLoading)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xff4A7B58)),
                      ),
                      SizedBox(height: 16),
                      Text('Connexion en cours...'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/*import 'package:etrace/abator/aba.dart';
import 'package:etrace/agent/checkpoint/check.dart';
import 'package:etrace/agent/controler/cont.dart';
import 'package:etrace/eleveur/el.dart';
import 'package:etrace/veto/veto.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:url_launcher/url_launcher.dart';

enum UserRole { agentMinepia, agentAbattage, veterinaire, eleveur }

class MyLogin extends StatelessWidget {
  const MyLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eTrace',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const RoleSelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  UserRole? selectedRole;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget roleTile({
    required UserRole role,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Color(0xff4A7B58) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color:
              isSelected ? Color(0xff4A7B58).withOpacity(0.07) : Colors.white,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(0xff4A7B58).withOpacity(0.08),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 30,
                color: isSelected ? Color(0xff4A7B58) : Color(0xffB0B0B0)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: isSelected
                  ? Icon(
                      Icons.radio_button_checked,
                      color: Color(0xff4A7B58),
                      key: ValueKey(true),
                    )
                  : Icon(
                      Icons.radio_button_off,
                      color: Colors.grey,
                      key: ValueKey(false),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.agentMinepia:
        return 'Agent MINEPIA';
      case UserRole.agentAbattage:
        return 'Agent Abattage';
      case UserRole.veterinaire:
        return 'Vétérinaire';
      case UserRole.eleveur:
        return 'Éleveur';
    }
  }

  void _signInWithGoogle() {
    if (selectedRole == null) return;
    final roleLabel = getRoleLabel(selectedRole!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Connexion avec Google en tant que $roleLabel')),
    );

    _goToDashboard();
  }

  void _signInWithApple() {
    if (selectedRole == null) return;
    final roleLabel = getRoleLabel(selectedRole!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Connexion avec Apple en tant que $roleLabel')),
    );

    _goToDashboard();
  }

  void _goToDashboard() {
    if (selectedRole == null) return;
    Widget dashboard;

    switch (selectedRole!) {
      case UserRole.agentMinepia:
        dashboard = MyAppCont();
        break;
      case UserRole.agentAbattage:
        dashboard = MyAppAba();
        break;
      case UserRole.veterinaire:
        dashboard = MyAppVeto();
        break;
      case UserRole.eleveur:
        dashboard = MyAppEl();
        break;
    }
    // À adapter selon tes dashboards
    //dashboard = Container(); // Remplace par tes widgets
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => dashboard));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 16),
                Hero(
                  tag: 'logo-hero',
                  child: SvgPicture.asset('assets/icons/logo.svg', height: 124),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Bienvenue sur eTrace',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade800,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Choisissez votre rôle pour accéder à\n l'écosystème eTrace",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 24),
                roleTile(
                  role: UserRole.agentMinepia,
                  icon: Icons.badge,
                  title: 'Agent MINEPIA',
                  subtitle: 'Gérez les activités officielles du secteur.',
                ),
                roleTile(
                  role: UserRole.agentAbattage,
                  icon: Icons.gavel,
                  title: 'Agent Abattage',
                  subtitle: 'Validez les opérations d’abattage.',
                ),
                roleTile(
                  role: UserRole.veterinaire,
                  icon: Icons.medical_services,
                  title: 'Vétérinaire',
                  subtitle: 'Assurez le suivi sanitaire des bovins.',
                ),
                roleTile(
                  role: UserRole.eleveur,
                  icon: Icons.pets,
                  title: 'Éleveur',
                  subtitle: 'Gérez vos animaux et le suivi d’élevage.',
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton.icon(
                    onPressed: selectedRole != null ? _signInWithGoogle : null,
                    icon: SvgPicture.asset(
                      'assets/icons/login_google.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: const Text(
                      "Continuer avec Google",
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton.icon(
                    onPressed: selectedRole != null ? _signInWithApple : null,
                    icon: SvgPicture.asset(
                      'assets/icons/login_apple.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: const Text("Continuer avec Apple"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedOpacity(
                  opacity: 1,
                  duration: const Duration(milliseconds: 900),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Vos données sont protégées. Elles servent uniquement à personnaliser votre expérience sur eTrace.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedOpacity(
                  opacity: 1,
                  duration: const Duration(milliseconds: 900),
                  child: InkWell(
                    onTap: () async {
                      final url = Uri.parse(
                        'https://www.iubenda.com/privacy-policy/57831804',
                      );
                      await launchUrl(url);
                    },
                    child: const Text(
                      'Politique de confidentialité.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}*/
