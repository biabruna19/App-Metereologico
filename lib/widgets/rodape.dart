import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class Rodape extends StatelessWidget {
  const Rodape({super.key});

  TextSpan _link(String texto, String url) => TextSpan(
    text: texto,
    style: const TextStyle(color: Colors.white, decoration: TextDecoration.underline, decorationColor: Colors.white54),
    recognizer: TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse(url)),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 12),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.7),
          children: [
            const TextSpan(text: 'Dados meteorológicos: '),
            _link('Open-Meteo', 'https://open-meteo.com/'),
            const TextSpan(text: '\nDesenvolvido por Beatriz Oliveira · '),
            _link('GitHub', 'https://github.com/biabruna19'),
            const TextSpan(text: ' · '),
            _link('LinkedIn', 'https://www.linkedin.com/in/beatriz-oliveira-759867294/'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
