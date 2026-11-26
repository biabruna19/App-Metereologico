{{flutter_js}}
{{flutter_build_config}}

// Tira a tela de "Carregando…" assim que o app estiver pronto.
_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
    document.getElementById('carregando')?.remove();
  },
});
