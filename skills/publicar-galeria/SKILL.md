---
name: publicar-galeria
description: Arma una página con los videos de anuncio y, debajo de cada uno, el ángulo, el guion, el texto del anuncio y la voz, y la publica en Cloudflare Pages para revisarlos desde el celular antes de subirlos. Úsala cuando pidan "pasame la galería", "quiero ver los videos en el celular" o "publicá los videos para revisar".
---

# Galería de videos para revisar

## Para qué
Revisar desde el celular, en un solo link, todos los videos de una tanda antes de subirlos a Meta, con todo lo que hace falta para aprobarlos.

## Pasos
1. Poné los videos en una carpeta. Cada uno debería pesar menos de 25 MB, que es el límite de Cloudflare Pages por archivo.
2. Si querés portadas, poné un `.jpg` con el mismo nombre que el video.
3. Escribí un `datos.json` con un objeto por video. Ejemplo en `examples/galeria/datos.json`:
   ```json
   [{ "archivo": "V1.mp4", "titulo": "V1 · Historia", "angulo": "...", "guion": "...", "copy": "...", "voz": "..." }]
   ```
4. Generá la página:
   ```powershell
   .\scripts\galeria\nueva-galeria.ps1 -Carpeta .\videos -Datos .\videos\datos.json -Titulo "Videos para revisar"
   ```
5. Publicala, con una cuenta gratis de Cloudflare y `npx wrangler login` hecho una vez:
   ```powershell
   .\scripts\galeria\nueva-galeria.ps1 -Carpeta .\videos -Datos .\videos\datos.json -Titulo "Videos" -Publicar -Proyecto mis-videos
   ```
   Queda en `https://mis-videos.pages.dev`.

## Buenas prácticas
- `preload="none"` en los videos, para que la página cargue rápido con datos lentos (el script ya lo hace).
- `noindex`, para que la galería no aparezca en Google (también lo hace el script).
- Nunca pongas en la galería métricas privadas, IDs de cuentas ni links internos.
