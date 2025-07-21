import 'package:etrace/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

void main() => runApp(ElHealth());

class ElHealth extends StatelessWidget {
  const ElHealth({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: Colors.white,
      ),
      child: ElHealthScreen(),
    );
  }
}

/*class ElHealthScreen extends StatefulWidget {
  const ElHealthScreen({super.key});

  @override
  _ElHealthScreenState createState() => _ElHealthScreenState();
}

class _ElHealthScreenState extends State<ElHealthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Santé du bovin"),
      ),
      body: Center(
        child: Text("Informations de santé du bovin"),
      ),
    );
  }
}*/

// Dummy data models
class Vet {
  final String name;
  final String? photoUrl;
  Vet(this.name, {this.photoUrl});
}

class SanitaryEvent {
  final String type; // 'vaccination', 'treatment', 'disease', 'document'
  final String title;
  final DateTime date;
  final Vet vet;
  final String? details;
  final String? medoc;
  final String? posology;
  final String? duration;
  final String? state;
  final bool alert;
  final String? pdfUrl;
  final String? docLabel;

  SanitaryEvent({
    required this.type,
    required this.title,
    required this.date,
    required this.vet,
    this.details,
    this.medoc,
    this.posology,
    this.duration,
    this.state,
    this.alert = false,
    this.pdfUrl,
    this.docLabel,
  });
}

// Dummy data for demo
final List<SanitaryEvent> allEvents = [
  SanitaryEvent(
    type: 'vaccination',
    title: 'Vaccination contre la brucellose',
    date: DateTime(2025, 6, 3),
    vet: Vet('Dr. Koffi', photoUrl: null),
    medoc: 'BrucellaVac',
    posology: '1 dose',
    duration: 'Unique',
    state: 'Stabilisé',
    //pdfUrl: null,
    alert: false,
  ),
  SanitaryEvent(
    type: 'treatment',
    title: 'Soins vétérinaires',
    date: DateTime(2025, 5, 20),
    vet: Vet('Dr. Amina', photoUrl: null),
    medoc: 'Ivermectine',
    posology: '10ml/jour',
    duration: '5 jours',
    state: 'Sous observation',
    //pdfUrl: 'https://example.com/ordonnance.pdf',
    docLabel: 'Télécharger ordonnance',
    alert: false,
  ),
  SanitaryEvent(
    type: 'disease',
    title: 'Suspicion de trypanosomiase',
    date: DateTime(2025, 5, 20),
    vet: Vet('Dr. Amina', photoUrl: null),
    details: 'Fièvre, abattement, baisse de production',
    alert: true,
    state: 'Sous surveillance',
  ),
  SanitaryEvent(
    type: 'document',
    title: 'Fiche maladie',
    date: DateTime(2025, 5, 10),
    vet: Vet('Dr. Baobab', photoUrl: null),
    //pdfUrl: 'https://example.com/fiche.pdf',
    docLabel: 'Voir fiche PDF',
    alert: false,
  ),
];

// Filter types
const eventFilters = [
  {
    'type': 'vaccination',
    'label': 'Vaccinations',
    'icon': '💉',
    'color': Color(0xFF5A8C49)
  },
  {
    'type': 'treatment',
    'label': 'Soins / traitements',
    'icon': '⚕️',
    'color': Color(0xFFB97A56)
  },
  {
    'type': 'disease',
    'label': 'Maladies détectées',
    'icon': '☣️',
    'color': Color(0xFFD94F4F)
  },
  {
    'type': 'document',
    'label': 'Documents joints',
    'icon': '📄',
    'color': Color(0xFF8B5E3C)
  },
];

class ElHealthScreen extends StatefulWidget {
  //final String bovinName;
  //final String? bovinPhoto;
  final String? code;
  const ElHealthScreen({super.key, this.code});

  @override
  State<ElHealthScreen> createState() => _ElHealthScreenState();
  static ElHealthScreen fromGoRouter(BuildContext context) {
    final state = GoRouterState.of(context);
    final extra = state.extra as Map<String, dynamic>? ?? {};
    return ElHealthScreen(
      code: extra['code'] as String?,
    );
  }
}

class _ElHealthScreenState extends State<ElHealthScreen>
    with TickerProviderStateMixin {
  List<String> activeFilters = [];
  late List<SanitaryEvent> filteredEvents;
  bool showFilters = false;
  bool isSyncing = false;
  String search = '';
  late AnimationController _timelineController;

  @override
  void initState() {
    super.initState();
    filteredEvents = _applyFilters();
    _timelineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _timelineController.dispose();
    super.dispose();
  }

  List<SanitaryEvent> _applyFilters() {
    List<SanitaryEvent> events = allEvents;
    if (activeFilters.isNotEmpty) {
      events = events.where((e) => activeFilters.contains(e.type)).toList();
    }
    if (search.trim().isNotEmpty) {
      events = events
          .where((e) =>
              e.title.toLowerCase().contains(search.toLowerCase()) ||
              (e.medoc?.toLowerCase().contains(search.toLowerCase()) ??
                  false) ||
              (e.details?.toLowerCase().contains(search.toLowerCase()) ??
                  false))
          .toList();
    }
    events.sort((a, b) => b.date.compareTo(a.date));
    return events;
  }

  void _toggleFilter(String type) {
    setState(() {
      if (activeFilters.contains(type)) {
        activeFilters.remove(type);
      } else {
        activeFilters.add(type);
      }
      filteredEvents = _applyFilters();
    });
  }

  void _syncEvents() async {
    setState(() => isSyncing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => isSyncing = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Synchronisation terminée !')));
  }

  void _onSearch(String value) {
    setState(() {
      search = value;
      filteredEvents = _applyFilters();
    });
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage:
                  AssetImage('assets/images/autre.png') //bovin_avatar.png')
                      as ImageProvider,
              backgroundColor: Colors.white, //const Color(0xFFF3E9D2),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.code ?? "Code Bovin Inconnu",
                      style: GoogleFonts.notoSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: const Color(0xFF333333),
                      )),
                  const SizedBox(height: 4),
                  Text(
                    "📚 Historique Sanitaire",
                    style: GoogleFonts.notoSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: const Color(0xFF4b5563),
                    ),
                  ),
                  Text(
                    "Suivez tous les événements de santé de ce bovin",
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      color: Colors.green.shade400,
                    ),
                  ),
                ],
              ),
            ),
            /*IconButton(
              icon: SvgPicture.asset(
                'assets/icons/login_google.svg',
                height: 28,
                colorFilter:
                    const ColorFilter.mode(Color(0xFF8B5E3C), BlendMode.srcIn),
              ),
              onPressed: () => setState(() => showFilters = !showFilters),
              tooltip: "Filtrer les événements",
            ),*/
          ],
        ),
        const SizedBox(height: 10),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 350),
          crossFadeState: showFilters
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: _buildFilters(),
          secondChild: const SizedBox.shrink(),
        ),
        const SizedBox(height: 10),
        _buildSearchAndSync(),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white, //const Color(0xFFF8F5EF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2D3B3), width: 1.2),
      ),
      child: Wrap(
        spacing: 12,
        children: eventFilters.map((f) {
          final isActive = activeFilters.contains(f['type']);
          return FilterChip(
            avatar:
                Text(f['icon'] as String, style: const TextStyle(fontSize: 18)),
            label: Text(f['label'] as String,
                style: GoogleFonts.notoSans(
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : Colors.brown.shade700,
                )),
            selected: isActive,
            backgroundColor: Colors.brown.shade50,
            selectedColor: (f['color'] as Color).withOpacity(0.85),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isActive ? (f['color'] as Color) : Colors.brown.shade200,
                width: isActive ? 2 : 1,
              ),
            ),
            onSelected: (_) => _toggleFilter(f['type'] as String),
            showCheckmark: false,
            elevation: isActive ? 4 : 0,
            shadowColor:
                isActive ? (f['color'] as Color).withOpacity(0.2) : null,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchAndSync() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: _onSearch,
            style: GoogleFonts.notoSans(fontSize: 15),
            decoration: InputDecoration(
              hintText: "🔎 Rechercher un événement, médicament...",
              filled: true,
              fillColor: const Color(0xFFf3f4f6),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Tooltip(
          message: "Synchroniser les derniers événements",
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: isSyncing ? null : _syncEvents,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: isSyncing
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.green.shade700,
                        ),
                      ),
                    )
                  /*: SvgPicture.asset(
                      'assets/icons/login_apple.svg',
                      height: 32,
                      colorFilter: ColorFilter.mode(
                        Colors.brown.shade700,
                        BlendMode.srcIn,
                      ),
                    ),*/
                  : Icon(
                      Icons.sync_outlined,
                      size: 28,
                      color: Color(0xFF4b5563),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    if (filteredEvents.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Image.asset(
                'assets/images/autre.png'), //sad_cow.png', height: 120),
            const SizedBox(height: 16),
            Text(
              "Aucun événement trouvé pour ce bovin",
              style: GoogleFonts.notoSans(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "L'historique sanitaire sera affiché ici dès qu'un événement sera enregistré.",
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: Colors.brown.shade400,
              ),
            ),
          ],
        ),
      );
    }

    // Group by date (same day)
    Map<String, List<SanitaryEvent>> grouped = {};
    for (var e in filteredEvents) {
      final key = "${e.date.year}-${e.date.month}-${e.date.day}";
      grouped.putIfAbsent(key, () => []).add(e);
    }
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Descending

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: sortedKeys.length,
      itemBuilder: (context, groupIdx) {
        final group = grouped[sortedKeys[groupIdx]]!;
        final date = group.first.date;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 18, bottom: 6),
              child: Text(
                "${date.day.toString().padLeft(2, '0')} "
                "${_monthName(date.month)} ${date.year}",
                style: GoogleFonts.notoSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.brown.shade600,
                ),
              ),
            ),
            ...List.generate(group.length, (i) {
              final event = group[i];
              return _TimelineEventCard(
                event: event,
                isFirst: i == 0,
                isLast: i == group.length - 1,
                animationDelay: (groupIdx * 0.15 + i * 0.08),
                controller: _timelineController,
              );
            }),
          ],
        );
      },
    );
  }

  String _monthName(int m) {
    const months = [
      '',
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre'
    ];
    return months[m];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, //const Color(0xFFF8F5EF),
      appBar: SoftAppBar(
        title: "Historique Sanitaire",
        /*actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF8B5E3C)),
            onPressed: () {},
          ),
        ],*/
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: _buildHeader(),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _buildTimeline(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Timeline event card with animation and afritude style
class _TimelineEventCard extends StatelessWidget {
  final SanitaryEvent event;
  final bool isFirst;
  final bool isLast;
  final double animationDelay;
  final AnimationController controller;

  const _TimelineEventCard({
    required this.event,
    required this.isFirst,
    required this.isLast,
    required this.animationDelay,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final Animation<double> anim = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(animationDelay, animationDelay + 0.35,
            curve: Curves.elasticOut),
      ),
    );

    final Color cardColor =
        event.alert ? const Color(0xFFFDE7E7) : const Color(0xFFFDF7F0);

    final Color borderColor =
        event.alert ? const Color(0xFFD94F4F) : const Color(0xFF8B5E3C);

    final String icon = event.type == 'vaccination'
        ? '💉'
        : event.type == 'treatment'
            ? '⚕️'
            : event.type == 'disease'
                ? '☣️'
                : '📄';

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: anim.value,
          child: Opacity(
            opacity: anim.value.clamp(0.0, 1.0),
            child: Stack(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.10),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: event.alert
                                      ? Colors.redAccent.withOpacity(0.15)
                                      : const Color(0xFF5A8C49)
                                          .withOpacity(.15),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  icon,
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                              //if (!isLast)
                              Container(
                                width: 4,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      event.alert
                                          ? const Color(0xFFD94F4F)
                                          : const Color(0xFF4b5563),
                                      Colors.brown.shade100,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                  image: const DecorationImage(
                                    image:
                                        AssetImage('assets/images/autre.png'),
                                    fit: BoxFit.cover,
                                    opacity: 0.25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      event.title,
                                      style: GoogleFonts.notoSans(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: event.alert
                                            ? const Color(0xFFD94F4F)
                                            : const Color(0xFF4b5563),
                                      ),
                                    ),
                                    if (event.alert)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: Icon(Icons.warning_amber_rounded,
                                            color: const Color(0xFFD94F4F),
                                            size: 20),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: 15, color: Colors.green.shade400),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${event.date.day.toString().padLeft(2, '0')} "
                                      "${_monthName(event.date.month)} ${event.date.year}",
                                      style: GoogleFonts.notoSans(
                                        fontSize: 13,
                                        color: Colors.green.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 13,
                                      backgroundImage: event.vet.photoUrl !=
                                              null
                                          ? NetworkImage(event.vet.photoUrl!)
                                          : AssetImage(
                                                  'assets/images/autre.png') //vet_avatar.png')
                                              as ImageProvider,
                                      backgroundColor: Colors.brown.shade100,
                                    ),
                                    const SizedBox(width: 7),
                                    Text(
                                      event.vet.name,
                                      style: GoogleFonts.notoSans(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.5,
                                        color: Colors.brown.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                if (event.medoc != null ||
                                    event.posology != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Icon(Icons.medical_services,
                                            size: 16,
                                            color: Colors.blue.shade400),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${event.medoc ?? ''}"
                                          "${event.posology != null ? ' • ${event.posology}' : ''}"
                                          "${event.duration != null ? ' • ${event.duration}' : ''}",
                                          style: GoogleFonts.notoSans(
                                            fontSize: 13,
                                            color: Colors.blue.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (event.details != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      event.details!,
                                      style: GoogleFonts.notoSans(
                                        fontSize: 13,
                                        color: Colors.brown.shade600,
                                      ),
                                    ),
                                  ),
                                if (event.state != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: event.state == "Stabilisé"
                                            ? const Color(0xFF5A8C49)
                                                .withOpacity(0.13)
                                            : event.state == "Sous observation"
                                                ? const Color(0xFFFFE082)
                                                    .withOpacity(0.18)
                                                : const Color(0xFFD94F4F)
                                                    .withOpacity(0.13),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        event.state!,
                                        style: GoogleFonts.notoSans(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12.5,
                                          color: event.state == "Stabilisé"
                                              ? const Color(0xFF5A8C49)
                                              : event.state ==
                                                      "Sous observation"
                                                  ? const Color(0xFFB97A56)
                                                  : const Color(0xFFD94F4F),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (event.pdfUrl != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            const Color(0xFF8B5E3C),
                                        side: const BorderSide(
                                            color: Color(0xFF8B5E3C)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      icon: const Icon(
                                          Icons.picture_as_pdf_rounded),
                                      label: Text(
                                          event.docLabel ?? "Voir fiche PDF"),
                                      onPressed: () {
                                        // TODO: ouvrir le PDF dans un viewer ou navigateur
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _monthName(int m) {
    const months = [
      '',
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre'
    ];
    return months[m];
  }
}

// Painter for spiral/corde timeline
class _TimelineSpiralPainter extends CustomPainter {
  final bool isFirst;
  final bool isLast;
  final bool alert;
  _TimelineSpiralPainter(
      {required this.isFirst, required this.isLast, required this.alert});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = alert ? const Color(0xFFD94F4F) : const Color(0xFF8B5E3C)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double top = isFirst ? size.height * 0.25 : 0;
    final double bottom = isLast ? size.height * 0.75 : size.height;

    // Dessine une ligne tressée façon corde africaine
    final path = Path();
    path.moveTo(size.width / 2, top);
    for (double y = top; y < bottom; y += 18) {
      path.relativeQuadraticBezierTo(
        -4,
        8,
        0,
        16,
      );
      path.relativeQuadraticBezierTo(
        4,
        8,
        0,
        16,
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TimelineSpiralPainter oldDelegate) => false;
}
