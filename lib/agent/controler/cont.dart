import 'package:etrace/utils/cont_routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyAppCont());
}

class MyAppCont extends StatelessWidget {
  const MyAppCont({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'eTrace',
      // Changed title to 'eTrace' for consistency with other modules
      routerConfig: appRouter,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
