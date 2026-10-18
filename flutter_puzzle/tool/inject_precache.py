"""Agrega al inicio de sw.js la lista de archivos de la versión web.

Uso: python3 tool/inject_precache.py build/web <version>

Así el service worker guarda todo en la primera visita y la app funciona
sin conexión desde la segunda carga.
"""
import json
import os
import sys

EXCLUDE = {'sw.js', 'flutter_service_worker.js', '.last_build_id'}


def main() -> None:
    web_dir, version = sys.argv[1], sys.argv[2]
    files = ['./']
    # Sin compilación WebAssembly (--wasm) la app usa CanvasKit, no skwasm.
    uses_wasm = os.path.exists(os.path.join(web_dir, 'main.dart.wasm'))
    for root, _, names in os.walk(web_dir):
        for name in sorted(names):
            path = os.path.relpath(os.path.join(root, name), web_dir).replace(os.sep, '/')
            if path in EXCLUDE or path.endswith('.map') or path.endswith('.symbols'):
                continue
            if not uses_wasm and os.path.basename(path).startswith('skwasm'):
                continue
            files.append(path)
    sw_path = os.path.join(web_dir, 'sw.js')
    with open(sw_path, encoding='utf-8') as fh:
        source = fh.read()
    header = (
        f'self.__VERSION = {json.dumps(version[:12])};\n'
        f'self.__PRECACHE = {json.dumps(files)};\n'
    )
    with open(sw_path, 'w', encoding='utf-8') as fh:
        fh.write(header + source)
    print(f'sw.js: {len(files)} archivos para usar sin conexión (versión {version[:12]})')


if __name__ == '__main__':
    main()
