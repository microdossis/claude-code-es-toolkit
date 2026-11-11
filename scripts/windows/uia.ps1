<#
.SYNOPSIS
  Ayudas de UI Automation para que Claude Code lea y maneje apps de Windows cuando no hay API.
  Se cargan con:  . .\uia.ps1

.FUNCIONES
  Obtener-Ventana   -Proceso msedge [-Titulo '*parte del título*']
  Buscar-Elementos  -Proceso msedge -Nombre '*Guardar*' [-Tipo Button]
  Mostrar-Elementos -Proceso msedge -Nombre '*Guardar*'
  Clic-Elemento     $elemento      (usa Invoke si existe; si no, un clic real del mouse en el centro)
  Capturar-Ventana  -Proceso msedge -Archivo .\captura.png   (funciona aunque la ventana esté tapada)

.CUIDADO
  - Clic-Elemento con mouse mueve el puntero real: no lo uses mientras alguien está usando la PC.
  - Antes de confirmar algo irreversible, capturá la pantalla y verificá que el diálogo es el que esperás.
#>
Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes, System.Drawing
if (-not ('UiaNativo' -as [type])) {
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System; using System.Runtime.InteropServices; using System.Drawing;
public class UiaNativo {
  [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr h, IntPtr dc, uint f);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
  [DllImport("user32.dll")] public static extern void mouse_event(uint f, int x, int y, uint d, UIntPtr e);
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
  public static Bitmap Capturar(IntPtr h) {
    RECT r; GetWindowRect(h, out r);
    var b = new Bitmap(Math.Max(1, r.R - r.L), Math.Max(1, r.B - r.T));
    using (var g = Graphics.FromImage(b)) { var dc = g.GetHdc(); PrintWindow(h, dc, 2); g.ReleaseHdc(dc); }
    return b;
  }
  public static void Clic(int x, int y) { SetCursorPos(x, y); mouse_event(0x02, 0, 0, 0, UIntPtr.Zero); mouse_event(0x04, 0, 0, 0, UIntPtr.Zero); }
}
'@
}

function Obtener-Ventana([string]$Proceso, [string]$Titulo = '*') {
  Get-Process $Proceso -ErrorAction SilentlyContinue |
    Where-Object { $_.MainWindowHandle -ne 0 -and $_.MainWindowTitle -like $Titulo } |
    Select-Object -First 1
}

function Buscar-Elementos([string]$Proceso, [string]$Nombre, [string]$Tipo, [switch]$IncluirFueraDePantalla) {
  $v = Obtener-Ventana $Proceso
  if (-not $v) { throw "No encontré una ventana de '$Proceso'." }
  $raiz = [System.Windows.Automation.AutomationElement]::FromHandle($v.MainWindowHandle)
  $todos = $raiz.FindAll([System.Windows.Automation.TreeScope]::Descendants, [System.Windows.Automation.Condition]::TrueCondition)
  foreach ($e in $todos) {
    $n = $e.Current.Name
    if (-not $n -or $n -notlike $Nombre) { continue }
    if ($Tipo -and $e.Current.ControlType.ProgrammaticName -ne "ControlType.$Tipo") { continue }
    if (-not $IncluirFueraDePantalla -and $e.Current.IsOffscreen) { continue }
    $e
  }
}

function Mostrar-Elementos([string]$Proceso, [string]$Nombre, [string]$Tipo) {
  Buscar-Elementos -Proceso $Proceso -Nombre $Nombre -Tipo $Tipo -IncluirFueraDePantalla | ForEach-Object {
    $n = ($_.Current.Name -replace '\s+', ' ')
    '{0} | {1} | fuera={2} | {3}' -f $_.Current.ControlType.ProgrammaticName, $n.Substring(0, [Math]::Min(90, $n.Length)), $_.Current.IsOffscreen, $_.Current.BoundingRectangle
  }
}

function Clic-Elemento($Elemento) {
  try { $Elemento.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern).Invoke(); return 'invoke' } catch {}
  try { $Elemento.GetCurrentPattern([System.Windows.Automation.ScrollItemPattern]::Pattern).ScrollIntoView(); Start-Sleep -Milliseconds 400 } catch {}
  $b = $Elemento.Current.BoundingRectangle
  [UiaNativo]::Clic([int]($b.X + $b.Width / 2), [int]($b.Y + $b.Height / 2))
  'mouse'
}

function Capturar-Ventana([string]$Proceso, [string]$Archivo = '.\captura.png') {
  $v = Obtener-Ventana $Proceso
  if (-not $v) { throw "No encontré una ventana de '$Proceso'." }
  $bmp = [UiaNativo]::Capturar($v.MainWindowHandle)
  $destino = if ([IO.Path]::IsPathRooted($Archivo)) { $Archivo } else { Join-Path (Get-Location) $Archivo }
  $bmp.Save($destino, [System.Drawing.Imaging.ImageFormat]::Png)
  "Captura guardada: $Archivo ($($bmp.Width)x$($bmp.Height))"
}
