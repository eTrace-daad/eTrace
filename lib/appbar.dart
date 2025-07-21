import 'package:flutter/material.dart';

class SoftAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool centerTitle;
  final bool showBack;

  const SoftAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.backgroundColor,
    this.centerTitle = true,
    this.showBack = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Correction : Utiliser Navigator.canPop pour vérifier si on peut revenir en arrière
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.white,
      //elevation: 0.5,
      leading: showBack && Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xff1A1A1A),
              ),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Aucune page précédente.")),
                  );
                }
              },
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xff1A1A1A),
          fontWeight: FontWeight.bold,
          fontSize: 21,
        ),
      ),
      centerTitle: centerTitle,
      iconTheme: const IconThemeData(color: Color(0xff1A1A1A)),
      //actions: // ...existing code...
      actions:
          actions != null ? [...actions!, const SizedBox(width: 16)] : null,
      // ...existing code...,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
