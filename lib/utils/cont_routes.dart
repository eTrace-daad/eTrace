import 'package:etrace/agent/controler/cont_suivi.dart';
import 'package:etrace/agent/controler/cont_event.dart';
import 'package:etrace/agent/controler/cont_health.dart';
import 'package:etrace/agent/controler/cont_main.dart';
import 'package:etrace/agent/controler/cont_save.dart';
import 'package:etrace/agent/controler/cont_transit.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ContMainScreen(),
      routes: [
        /*GoRoute(
          path: 'save',
          builder: (context, state) => const ContSave(),
        ),*/
        GoRoute(
          path: 'save',
          builder: (context, state) => ContSaveScreen.fromGoRouter(context),
        ),
        GoRoute(
          path: 'transit',
          builder: (context, state) => const SuiviTransit(),
        ),
        GoRoute(
          path: 'suivi',
          builder: (context, state) => const SuiviBetail(),
        ),
        GoRoute(
          path: 'event',
          builder: (context, state) => ContEventScreen.fromGoRouter(context),
        ),
        GoRoute(
          path: 'health',
          builder: (context, state) => ContHealthScreen.fromGoRouter(context),
        ),
      ],
    ),
  ],
);
