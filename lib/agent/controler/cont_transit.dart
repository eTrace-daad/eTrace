/*import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animations/animations.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(SuiviTransit());

class SuiviTransit extends StatelessWidget {
  const SuiviTransit({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.nunitoTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: Colors.white,
      ),
      child: SuiviTransitScreen(),
    );
  }
}

class SuiviTransitScreen extends StatelessWidget {
  const SuiviTransitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: const Text('Suivi de Transit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/cart_map.png',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            const Text('État Actuel',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            _animatedContainer(
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Checkpoint: Bertoua',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Par Oumma'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Points de Passage',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            _checkpointTile('Maroua', '05/06 08:12', true),
            _checkpointTile('Garoua', '05/06 14:30', true),
            _checkpointTile('Ngaoundéré', '06/06 09:27', true),
            _checkpointTile('Bertoua', '06/06 --:--', false, pending: true),
            _checkpointTile('Yaoundé', '07/06 --:--', false, isFuture: true),
            const SizedBox(height: 16),
            const Text('Valider le Checkpoint',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            _infoTile(Icons.calendar_today, '06 Juin 2024, 15:30'),
            _infoTile(Icons.person, 'Oumma'),
            _infoTile(Icons.directions_car, 'IMMAT-4383DHW93'),
            _textField('Ajouter une observation...'),
            const SizedBox(height: 16),
            /*SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Valider le Passage'),
                onPressed: () {},
              ),
            ),*/
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Valider le Passage'),
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 24),
            const Text('Prochain Arrêt',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            _animatedContainer(
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Expanded(child: Text('Yaoundé')),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _animatedContainer(Widget child) {
    return OpenContainer(
      closedElevation: 0,
      openElevation: 0,
      closedColor: Colors.transparent,
      openColor: Colors.white,
      transitionType: ContainerTransitionType.fade,
      closedBuilder: (context, openContainer) => GestureDetector(
        onTap: openContainer,
        child: child,
      ),
      openBuilder: (context, closeContainer) => Scaffold(
        appBar: AppBar(title: const Text('Détails')),
        body: Center(child: const Text('Détails du point de passage')),
      ),
    );
  }

  Widget _checkpointTile(String title, String time, bool completed,
      {bool pending = false, bool isFuture = false}) {
    Color iconColor;
    IconData iconData;
    String subtitle = time;

    if (completed) {
      iconColor = Colors.green;
      iconData = Icons.check_circle;
    } else if (pending) {
      iconColor = Colors.blue;
      iconData = Icons.location_on;
      subtitle = 'En attente de validation';
    } else {
      iconColor = Colors.grey;
      iconData = Icons.location_on_outlined;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(iconData, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _textField(String hint) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
        ),
        maxLines: null,
      ),
    );
  }
}*/

import 'package:etrace/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

void main() => runApp(SuiviTransit());

class SuiviTransit extends StatelessWidget {
  const SuiviTransit({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.nunitoTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: Colors.white,
      ),
      child: SuiviTransitScreen(),
    );
  }
}

class SuiviTransitScreen extends StatelessWidget {
  const SuiviTransitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SoftAppBar(
        title: "Suivi de Transit",
        actions: [Icon(Icons.settings_outlined)],
      ),
      /*title: const Text('Suivi de Transit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          )
        ],
      ),*/
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/cart_map.png',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/logo.svg',
                          height: 8,
                          width: 8,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'En Transit : Bertoua',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            /*ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/cart_map.png',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),*/
            const SizedBox(height: 16),
            const Text('État Actuel',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Checkpoint: Bertoua',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Par Oumma'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Points de Passage',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            _checkpointTile('Maroua', '05/06 08:12', true,
                pending: false, isFuture: false),
            _checkpointTile('Garoua', '05/06 14:30', true,
                pending: false, isFuture: false),
            _checkpointTile('Ngaoundéré', '06/06 09:27', true,
                pending: false, isFuture: false),
            _checkpointTile('Bertoua', '06/06 --:--', false, pending: true),
            _checkpointTile('Yaoundé', '07/06 --:--', false, isFuture: true),
            const SizedBox(height: 16),
            const Text('Valider le Checkpoint',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            _infoTile(Icons.calendar_today, '06 Juin 2024, 15:30'),
            _infoTile(Icons.person, 'Oumma'),
            _infoTile(Icons.directions_car, 'IMMAT-4383DHW93'),
            _textField('Ajouter une observation...'),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5A8C49), Color(0xFFAC6E3F)],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  //backgroundColor: const Color(0xFF4CAF50),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.check_circle_outline,
                    size: 24, color: Colors.white),
                label: const Text(
                  'Valider le Passage',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.send, color: Colors.white),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "Passage pour Bertoua validé avec succès !",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text('Prochain Arrêt',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Expanded(child: Text('Yaoundé')),
                  Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _checkpointTile(String title, String time, bool completed,
      {bool pending = false, bool isFuture = false}) {
    Color iconColor;
    IconData iconData;
    String subtitle = time;

    if (completed) {
      iconColor = Colors.green;
      iconData = Icons.check_circle;
    } else if (pending) {
      iconColor = Colors.blue;
      iconData = Icons.location_on;
      subtitle = 'En attente de validation';
    } else {
      iconColor = Colors.grey;
      iconData = Icons.location_on_outlined;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(iconData, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _textField(String hint) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
        ),
        maxLines: null,
      ),
    );
  }
}
