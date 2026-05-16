import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Busca os dados iniciais assim que a tela for montada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().loadInitialData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchCity() {
    final city = _searchController.text.trim();
    if (city.isNotEmpty) {
      context.read<WeatherProvider>().fetchWeatherForCity(city);
      FocusScope.of(context).unfocus(); // Esconde o teclado
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Clima Brasil', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Consumer<WeatherProvider>(
            builder: (context, provider, child) {
              if (provider.currentWeather != null && !provider.isLoading) {
                return IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {
                    final weather = provider.currentWeather!;
                    Share.share(
                      'Confira o clima em ${weather.cityName}! Agora faz ${weather.temperature.toStringAsFixed(1)}°C. - Enviado via App Clima Brasil',
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F2027), // Escuro profundo
              Color(0xFF203A43), // Azul petróleo
              Color(0xFF2C5364), // Azul acinzentado
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Barra de Busca
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar cidade...',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _searchCity,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: (_) => _searchCity(),
                ),
                const SizedBox(height: 40),

                // Exibição do Clima
                Expanded(
                  child: Consumer<WeatherProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      if (provider.errorMessage != null) {
                        return Center(
                          child: Text(
                            provider.errorMessage!,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      final weather = provider.currentWeather;
                      if (weather == null) {
                        return const Center(
                          child: Text(
                            'Busque uma cidade para ver o clima.',
                            style: TextStyle(color: Colors.white70, fontSize: 18),
                          ),
                        );
                      }

                      return ListView(
                        children: [
                          Icon(
                            _getIconData(weather.weatherCode),
                            size: 100,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            weather.cityName,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${weather.temperature.toStringAsFixed(1)}°C',
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            weather.weatherDescription,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Card de detalhes com Glassmorphism
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildDetailItem(Icons.air, '${weather.windSpeed} km/h', 'Vento'),
                                    _buildDetailItem(Icons.water_drop_outlined, 'Variável', 'Umidade'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Gráfico de Previsão
                          WeatherChart(weatherData: weather),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 30),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  IconData _getIconData(int code) {
    if (code == 0) return Icons.wb_sunny;
    if (code <= 3) return Icons.cloud;
    if (code <= 65) return Icons.water_drop;
    if (code <= 75) return Icons.ac_unit;
    if (code == 95) return Icons.thunderstorm;
    return Icons.cloud;
  }
}
