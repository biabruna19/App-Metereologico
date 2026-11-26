import 'package:material_ui/material_ui.dart';

/// Cartão translúcido usado em todas as seções.
/// Fundo levemente escuro para o texto branco ter contraste em qualquer céu.
class Painel extends StatelessWidget {
  const Painel({super.key, required this.child, this.padding = const EdgeInsets.all(20)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: child,
    );
  }
}

class TituloSecao extends StatelessWidget {
  const TituloSecao(this.texto, {super.key, required this.icone});

  final String texto;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icone, size: 18, color: Colors.white70),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              texto.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
