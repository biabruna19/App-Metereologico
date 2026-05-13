import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'providers/weather_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Supabase com as chaves obtidas via dashboard
  await Supabase.initialize(
    url: 'https://rqkhxisvqbkcbyvntquo.supabase.co',
    anonKey: 'sb_publishable_WKfnAvpnTjBddnWjdULQ5Q_FPz4TIzz',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: const AppClimaBrasil(),
    ),
  );
}

class AppClimaBrasil extends StatelessWidget {
  const AppClimaBrasil({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clima Brasil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Inter', // Utilizando uma fonte limpa e moderna
      ),
      home: const HomeScreen(),
    );
  }
}
