import 'package:etrace/eleveur/el_ask.dart';
import 'package:etrace/eleveur/el_event.dart';
import 'package:etrace/eleveur/el_health.dart';
import 'package:etrace/eleveur/el_main.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ElMain(),
      routes: [
        GoRoute(
          path: 'demande',
          builder: (context, state) => const ElAsksQR(),
        ),
        GoRoute(
          path: 'vol',
          builder: (context, state) =>
              DeclarationVolScreen(), //const ElHealth(),
        ),
        GoRoute(
          path: 'alert',
          builder: (context, state) => const ElHealth(),
        ),
        GoRoute(
          path: 'history',
          builder: (context, state) => const ElHealth(),
        ),
      ],
    ),
  ],
);
