import 'package:etrace/agent/checkpoint/check_move.dart';
import 'package:etrace/agent/checkpoint/check_transit.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const CheckMove(),
      routes: [
        GoRoute(
          path: 'transit',
          builder: (context, state) => const CheckTransit(),
        ),
        GoRoute(
          path: 'move',
          builder: (context, state) => const CheckMove(),
        ),
      ],
    ),
  ],
);
