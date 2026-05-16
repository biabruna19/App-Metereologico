# 🌦️ Aplicativo Meteorológico

Um aplicativo completo de previsão do tempo desenvolvido em **Flutter**, focado em fornecer dados meteorológicos em tempo real, com uma interface bonita e responsiva. O projeto inclui integração de APIs, gerenciamento de estado e um backend para histórico de buscas.

🌍 **Acesse o App na Web:** [App Meteorológico](https://biabruna19.github.io/App-Metereologico/)

---

## ✨ Funcionalidades

- **Previsão em Tempo Real:** Consulta de dados climáticos e temperatura atual de cidades (com foco no Brasil).
- **Gráficos de Temperatura:** Visualização interativa da variação de temperatura ao longo do tempo.
- **Histórico de Buscas:** O aplicativo salva as cidades pesquisadas anteriormente utilizando um banco de dados na nuvem.
- **Design Responsivo:** A interface se adapta perfeitamente a diferentes tamanhos de tela (Mobile e Web).
- **Deploy Automático:** O aplicativo web é atualizado automaticamente via GitHub Actions sempre que há uma nova alteração no código.

## 🛠️ Tecnologias Utilizadas

- **[Flutter](https://flutter.dev/):** Framework principal para desenvolvimento da interface (Mobile e Web).
- **[Dart](https://dart.dev/):** Linguagem de programação base do Flutter.
- **[Provider](https://pub.dev/packages/provider):** Gerenciamento de estado da aplicação.
- **[Open-Meteo API](https://open-meteo.com/):** Fornecimento de dados meteorológicos precisos e gratuitos.
- **[Supabase](https://supabase.com/):** Backend-as-a-Service (BaaS) utilizado para armazenar o histórico de buscas dos usuários.
- **GitHub Pages & Actions:** Hospedagem gratuita da versão web e pipeline de CI/CD para deploy automático.

## 🚀 Como executar o projeto localmente

Caso queira baixar e rodar o projeto na sua máquina, siga os passos abaixo.

### Pré-requisitos
- Ter o [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado.
- Ter uma IDE configurada (VS Code, Android Studio, etc).

### Passos

1. Clone o repositório:
   ```bash
   git clone https://github.com/biabruna19/App-Metereologico.git
   ```
2. Entre na pasta do projeto:
   ```bash
   cd App-Metereologico
   ```
3. Instale as dependências:
   ```bash
   flutter pub get
   ```
4. Execute o aplicativo:
   ```bash
   flutter run
   ```

---
*Desenvolvido por [Beatriz Oliveira](https://github.com/biabruna19)*.
