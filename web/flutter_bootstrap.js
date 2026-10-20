{{flutter_js}}
{{flutter_build_config}}

// The OPC PWA worker is registered by index.html. Do not also register
// Flutter's generated worker, which uses the same origin scope.
_flutter.loader.load();
