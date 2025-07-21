import 'package:etrace/utils/el_routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyAppEl());
}

class MyAppEl extends StatelessWidget {
  const MyAppEl({super.key});

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
