import 'package:etrace/veto/veto_certificat.dart';
import 'package:etrace/veto/veto_inter.dart';
import 'package:etrace/veto/veto_main.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const VetoMainScreen(),
      routes: [
        GoRoute(
          path: 'certificat',
          builder: (context, state) => const VetoCertificat(),
        ),
        GoRoute(
          path: 'intervention',
          builder: (context, state) =>
              VetoInterventionScreen.fromGoRouter(context),
        ),
      ],
    ),
  ],
);
