import 'package:etrace/utils/veto_routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyAppVeto());
}

class MyAppVeto extends StatelessWidget {
  const MyAppVeto({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'eTrace',
      routerConfig: appRouter,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
