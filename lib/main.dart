import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'providers/clima_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(ChangeNotifierProvider(create: (_) => ClimaProvider(), child: const ClimaBrasilApp()));
}

class ClimaBrasilApp extends StatelessWidget {
  const ClimaBrasilApp({super.key, this.home = const HomeScreen()});

  final Widget home;

  static ThemeData get tema {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Outfit',
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4FA3E0), brightness: Brightness.dark),
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xF0121A2B),
        contentTextStyle: TextStyle(color: Colors.white, fontFamily: 'Outfit', fontSize: 15),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: const Color(0xEE121A2B), borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Clima Brasil', debugShowCheckedModeBanner: false, theme: tema, home: home);
  }
}
