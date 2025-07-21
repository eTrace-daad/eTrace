import 'package:etrace/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etrace/abator/aba.dart';
import 'package:etrace/agent/controler/cont.dart';
import 'package:etrace/veto/veto.dart';
import 'package:etrace/eleveur/el.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Supabase.initialize(
    url: 'https://zfpjouefehuupibmexqa.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpmcGpvdWVmZWh1dXBpYm1leHFhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA1MjQxNzAsImV4cCI6MjA2NjEwMDE3MH0.YsYGWDbuJi4bqEVwPhIaKUc1J2fcvQ04BVyJ1NA3o2Y',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LinkaCao',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Timer(const Duration(milliseconds: 2500), () async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Vérifie le rôle dans Firestore
          String? role;
          final firestore = FirebaseFirestore.instance;
          final collections = {
            'minepia_agents': MyAppCont(),
            'abattage_agents': MyAppAba(),
            'vetos': MyAppVeto(),
            'eleveurs': MyAppEl(),
          };
          Widget? dashboard;

          for (final entry in collections.entries) {
            final doc =
                await firestore.collection(entry.key).doc(user.uid).get();
            if (doc.exists) {
              dashboard = entry.value;
              break;
            }
          }

          if (dashboard != null) {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 1700),
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      dashboard!,
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            }
            return;
          }
        }
        // Si pas connecté ou pas trouvé, va sur MyLogin
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 1700),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const MyLogin(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _logoAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoAnimation.value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: _logoAnimation.value,
                    child: child,
                  ),
                );
              },
              child: SizedBox(
                height: 124,
                child: Image.asset(
                  'assets/app/icon_app.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _textFadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _textFadeAnimation.value.clamp(0.0, 1.0),
                  child: child,
                );
              },
              child: Text(
                'eTrace',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff1A1A1A),
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*import 'package:etrace/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Supabase.initialize(
    url: 'https://zfpjouefehuupibmexqa.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpmcGpvdWVmZWh1dXBpYm1leHFhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA1MjQxNzAsImV4cCI6MjA2NjEwMDE3MH0.YsYGWDbuJi4bqEVwPhIaKUc1J2fcvQ04BVyJ1NA3o2Y',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LinkaCao',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      //routes: AppRoutes.routes,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(const Duration(milliseconds: 2500), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 1700),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  MyLogin(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                // Fade transition douce
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _logoAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoAnimation.value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: _logoAnimation.value,
                    child: child,
                  ),
                );
              },
              child: SizedBox(
                height: 124,
                child: Image.asset(
                  'assets/app/icon_app.png', // Placez votre logo ici
                  fit: BoxFit.contain,
                ),
              ),
            ),
            //const SizedBox(height: 4),
            AnimatedBuilder(
              animation: _textFadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _textFadeAnimation.value.clamp(0.0, 1.0),
                  child: child,
                );
              },
              child: Text(
                'eTrace',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff1A1A1A),
                  fontSize: 24,
                  //letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/
