import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Item do menu inferior da área logada (ver `MainLayout`).
class NavItem {
  final String label;
  final String route;
  final FaIconData icon;

  const NavItem(this.label, this.route, this.icon);
}
