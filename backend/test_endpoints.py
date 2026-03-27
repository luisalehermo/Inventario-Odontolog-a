import urllib.request
import urllib.parse
import json

BASE = 'http://127.0.0.1:8000'

def get_json(path):
    url = BASE + path
    print('GET', url)
    try:
        with urllib.request.urlopen(url, timeout=5) as resp:
            text = resp.read().decode('utf-8')
            try:
                return json.loads(text)
            except Exception:
                print('Respuesta no JSON:', text)
                return None
    except Exception as e:
        print('Error al consultar', url, e)
        return None

if __name__ == '__main__':
    # Primero comprobar el listado de rutas en openapi
    openapi = get_json('/openapi.json')
    if openapi and 'paths' in openapi:
        print('Rutas expuestas (ejemplos):', list(openapi['paths'].keys())[:20])
    else:
        print('No se pudo obtener openapi.json')
    # 1) probar /libros/?q=
    q = urllib.parse.quote('el quijote')
    libros = get_json(f'/libros/?q={q}')
    print('libros:', libros)

    # 2) si hay libros, pedir préstamo activo del primer libro
    if isinstance(libros, list) and len(libros) > 0:
        first = libros[0]
        id_libro = first.get('id_libro')
        print('Primer libro id:', id_libro)
        prest = get_json(f'/prestamos/libro/{id_libro}')
        print('préstamo activo:', prest)
    else:
        print('No hay libros para probar.')
