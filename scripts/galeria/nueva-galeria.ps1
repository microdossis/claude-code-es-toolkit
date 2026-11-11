<#
.SYNOPSIS
  Genera una galería (index.html) con videos de anuncio y sus datos, y opcionalmente la publica en Cloudflare Pages.

.EXAMPLE
  .\nueva-galeria.ps1 -Carpeta .\videos -Datos .\videos\datos.json -Titulo "Videos para revisar"
  .\nueva-galeria.ps1 -Carpeta .\videos -Datos .\videos\datos.json -Titulo "Videos" -Publicar -Proyecto mis-videos

.NOTES
  datos.json: lista de objetos { archivo, titulo, angulo, guion, copy, voz }. Solo "archivo" es obligatorio.
  Para publicar hace falta Node.js y haber corrido una vez "npx wrangler login".
#>
param(
  [Parameter(Mandatory)] [string]$Carpeta,
  [Parameter(Mandatory)] [string]$Datos,
  [string]$Titulo = 'Videos para revisar',
  [switch]$Publicar,
  [string]$Proyecto
)
$ErrorActionPreference = 'Stop'

function Esc([string]$t) { if ($null -eq $t) { return '' }; [System.Net.WebUtility]::HtmlEncode($t) -replace "`r?`n", '<br>' }

$carpetaAbs = (Resolve-Path $Carpeta).Path
$items = Get-Content $Datos -Raw -Encoding UTF8 | ConvertFrom-Json
if (-not $items) { throw "El archivo de datos está vacío: $Datos" }

$tarjetas = foreach ($it in $items) {
  $archivo = [string]$it.archivo
  $ruta = Join-Path $carpetaAbs $archivo
  if (-not (Test-Path $ruta)) { Write-Warning "No existe el video: $archivo"; continue }
  $mb = [math]::Round((Get-Item $ruta).Length / 1MB, 1)
  if ($mb -gt 25) { Write-Warning "$archivo pesa $mb MB: Cloudflare Pages acepta hasta 25 MB por archivo." }
  $poster = [IO.Path]::ChangeExtension($archivo, '.jpg')
  $posterAttr = if (Test-Path (Join-Path $carpetaAbs $poster)) { " poster=`"$poster`"" } else { '' }
  $filas = @()
  foreach ($campo in @(@('angulo','Ángulo'), @('guion','Guion'), @('copy','Texto del anuncio'), @('voz','Voz'))) {
    $valor = $it.($campo[0])
    if ($valor) { $filas += "<details><summary>$($campo[1])</summary><p>$(Esc $valor)</p></details>" }
  }
  $tituloVideo = if ($it.titulo) { Esc $it.titulo } else { Esc $archivo }
@"
<article class="card">
  <video src="$archivo"$posterAttr preload="none" controls playsinline></video>
  <div class="body"><h2>$tituloVideo</h2><p class="meta">$mb MB</p>$($filas -join '')</div>
</article>
"@
}

$html = @"
<!doctype html>
<html lang="es"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="robots" content="noindex,nofollow">
<title>$(Esc $Titulo)</title>
<style>
:root{--bg:#f6f5f2;--card:#fff;--ink:#1d1d1f;--mute:#5f6168;--line:#e3e1dc}
@media (prefers-color-scheme:dark){:root{--bg:#121214;--card:#1b1b1f;--ink:#f2f2f3;--mute:#a3a5ad;--line:#2c2c33}}
*{box-sizing:border-box;margin:0}body{background:var(--bg);color:var(--ink);font:16px/1.5 system-ui,-apple-system,"Segoe UI",sans-serif}
.wrap{max-width:1080px;margin:0 auto;padding:24px 16px}h1{font-size:26px;margin-bottom:16px}
.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:16px}
.card{background:var(--card);border:1px solid var(--line);border-radius:14px;overflow:hidden}
.card video{width:100%;aspect-ratio:9/16;background:#000;display:block;object-fit:cover}
.body{padding:12px 14px 16px}.body h2{font-size:17px}.meta{color:var(--mute);font-size:13px;margin-bottom:6px}
details{border-top:1px solid var(--line);padding:6px 0}summary{cursor:pointer;font-weight:600;font-size:14px}details p{color:var(--mute);font-size:14px;margin-top:4px}
</style></head><body><div class="wrap"><h1>$(Esc $Titulo)</h1><div class="grid">
$($tarjetas -join "`n")
</div></div>
<script>document.querySelectorAll('video').forEach(v=>v.addEventListener('play',()=>document.querySelectorAll('video').forEach(o=>{if(o!==v)o.pause()})))</script>
</body></html>
"@

$salida = Join-Path $carpetaAbs 'index.html'
[IO.File]::WriteAllText($salida, $html, [Text.UTF8Encoding]::new($false))
Write-Host "Galería generada: $salida ($(@($tarjetas).Count) videos)"

if ($Publicar) {
  if (-not $Proyecto) { throw 'Para publicar indicá -Proyecto (nombre del proyecto de Cloudflare Pages).' }
  npx wrangler pages project create $Proyecto --production-branch main 2>$null | Out-Null
  npx wrangler pages deploy $carpetaAbs --project-name $Proyecto --branch main --commit-dirty=true
  Write-Host "Publicada en https://$Proyecto.pages.dev"
}
