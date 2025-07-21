import 'package:etrace/abator/aba_main.dart';
import 'package:go_router/go_router.dart';

import '../abator/aba_declaration.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AbaScanScreen(),
      routes: [
        GoRoute(
          path: 'declaration',
          builder: (context, state) => const AbaDeclaration(),
        ),
        /*GoRoute(
          path: 'product',
          builder: (context, state) => const SellerProduct(),
        ),
        GoRoute(
          path: 'commands',
          builder: (context, state) => const SellerViewCommands(),
        ),
        GoRoute(
          path: 'abonnement',
          builder: (context, state) => const AllAbonnement(),
        ),*/
      ],
    ),
  ],
);
