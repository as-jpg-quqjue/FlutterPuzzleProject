{{flutter_js}}
{{flutter_build_config}}

// Se carga la app sin el service worker propio de Flutter (en las versiones
// recientes ya no guarda nada para usar sin conexión); el modo sin conexión
// lo maneja sw.js, que se registra en index.html.
_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    const loading = document.getElementById('loading');
    if (loading) loading.remove();
    await appRunner.runApp();
  },
});
