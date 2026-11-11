# claude-code-es-toolkit

Herramientas en español para usar **Claude Code** en un negocio digital **sin ser programador**.

Las armé usando Claude Code todos los días en un negocio real de productos digitales: investigar ofertas, armar landings y checkouts, producir videos de anuncio en varios idiomas y automatizar la rutina. Las publico limpias, sin datos privados, para que otros emprendedores de Latinoamérica puedan usarlas.

> Estado: **en construcción**. Lo que está acá funciona; voy sumando más a medida que lo limpio y lo documento.

## Qué hay

| Carpeta | Qué es | Para qué sirve |
|---|---|---|
| `skills/investigar-ofertas` | Skill de Claude Code | Encontrar en la Biblioteca de Anuncios de Meta ofertas que ya venden y separar **evidencia, inferencia y suposición** antes de gastar. |
| `skills/revisar-video-anuncio` | Skill de Claude Code | Rúbrica de 10 criterios para revisar un video de anuncio para público frío, con un revisor que no es el que editó. |
| `skills/checklist-lanzamiento` | Skill de Claude Code | Lo que tiene que estar listo antes de prender una campaña: producto, landing, checkout, tracking y reglas de corte. |
| `skills/publicar-galeria` | Skill de Claude Code | Cómo armar y publicar una galería de videos para revisarlos desde el celular antes de subirlos. |
| `scripts/galeria` | PowerShell | Genera la galería (`index.html`) desde una carpeta de videos y un JSON, y la publica en Cloudflare Pages. |
| `scripts/windows` | PowerShell | Ayudas de **UI Automation** para que Claude Code lea y maneje apps de Windows cuando no hay API: buscar botones, hacer clic y capturar una ventana aunque esté tapada. |

## Cómo usar las skills

1. Copiá la carpeta de la skill a `.claude/skills/` dentro de tu proyecto (o a `~/.claude/skills/` para tenerla en todos).
2. Abrí Claude Code en esa carpeta y pedila por su nombre, por ejemplo: `/revisar-video-anuncio`.

## Cómo usar los scripts

Requisitos: Windows 10/11 con PowerShell 5.1 (ya viene instalado). Para publicar galerías: una cuenta gratis de Cloudflare y `npx wrangler login` una vez.

```powershell
# Galería desde una carpeta de videos
.\scripts\galeria\nueva-galeria.ps1 -Carpeta .\mis-videos -Datos .\mis-videos\datos.json -Titulo "Videos para revisar"

# Ayudas de UI Automation
. .\scripts\windows\uia.ps1
Mostrar-Elementos -Proceso msedge -Nombre '*Guardar*'
```

## Reglas que siguen todas las herramientas

- **Nunca** se guardan claves, tokens ni contraseñas en el repositorio.
- Las skills separan lo comprobado de lo supuesto: que un anuncio exista no prueba que venda.
- Los anuncios **modelan** la estructura de lo que funciona; nunca copian el video, la marca ni el contenido de otro.
- Antes de gastar, el producto tiene que estar terminado y revisado por alguien que no lo hizo.

## English

Spanish-first toolkit to use Claude Code in a small digital-products business without being a developer: Claude Code skills (offer research in the Meta Ad Library, ad-video review rubric, launch checklist, review galleries), a PowerShell gallery generator for Cloudflare Pages, and Windows UI Automation helpers so Claude Code can drive desktop apps when there is no API. Early stage, actively being cleaned up and documented.

## Licencia

MIT. Ver `LICENSE`.
