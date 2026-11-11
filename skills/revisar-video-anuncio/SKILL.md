---
name: revisar-video-anuncio
description: Revisa un video de anuncio para Meta (público frío) con una rúbrica de 10 criterios y un revisor que no es el que editó. Úsala antes de subir cualquier video, o cuando pidan "revisá este video", "calificalo de 1 a 10" o "¿sirve para público frío?".
---

# Revisar un video de anuncio (público frío)

## La rúbrica: 10 criterios, de 1 a 10 cada uno
1. **C1 · Gancho del primer fotograma.** El producto o el problema se reconoce de inmediato, grande, y el texto del gancho ya está en pantalla.
2. **C2 · Pregunta o dolor en los primeros 3 segundos.** No se responde de golpe: la respuesta llega después del segundo 5.
3. **C3 · Se entiende sin sonido.** Hay texto en pantalla todo el tiempo.
4. **C4 · Producto en acción antes del segundo 8** (ideal: antes del 4).
5. **C5 · Cambio visual cada 2 segundos o menos.** Cambiar solo el subtítulo no cuenta.
6. **C6 · Subtítulos legibles**, entre el 20 % y el 65 % del alto, para que la interfaz de Reels no los tape.
7. **C7 · Sin segundos muertos ni repeticiones.**
8. **C8 · Voz natural y buen sonido.** Que no suene a robot; volumen parejo, cerca de −16 LUFS.
9. **C9 · Llamado a la acción hablado y escrito**, con un beneficio concreto.
10. **C10 · Políticas de Meta:**
    - sin promesas de resultado ni promesas médicas;
    - sin afirmar atributos de quien mira ("¿Sos estudiante…?", "si eres católico…");
    - sin marcas ajenas;
    - sin cifras ni testimonios inventados;
    - una historia actuada lleva el rótulo "historia dramatizada".

Total sobre 100. Nunca se infla la nota.

## Proceso
1. **Referencia:** antes de revisar, mirá los anuncios de la competencia que el video modela. Copiá el ritmo y la estructura, nunca el material ajeno.
2. **Hoja de fotogramas:** extraé uno cada 0,5 s en los primeros 3 s y uno por segundo después. Con ffmpeg:
   ```
   ffmpeg -i video.mp4 -vf "fps=2,scale=270:-1,tile=8x4" -frames:v 1 hoja.jpg
   ```
3. **Transcribí el audio** del video final y comparalo con el guion palabra por palabra.
4. **Revisor independiente:** otro agente, que NO editó el video, recibe solo el mp4, la hoja, esta rúbrica y la referencia. Devuelve:
   - la nota de cada criterio y el total;
   - "qué falta para 10", con el segundo exacto de cada problema;
   - un veredicto: SUBIR, SUBIR CON CORRECCIONES o NO SUBIR.
5. **Corregir y volver al revisor:** como máximo 3 rondas.
6. **Una persona escucha 10 segundos** de cada video antes de subirlo (C8).
7. **A las 24 y 72 horas**, compará la nota con los datos reales del anuncio y anotá si la rúbrica acertó.

## Trampas conocidas
- Los subtítulos al 80 % del alto quedan tapados por la interfaz de Reels.
- Las personas o presentadores hechos con IA tienen que estar rotulados como tales.
- Un video "modelado" que se aleja mucho de la referencia suele rendir menos. Mejor clonar la estructura y cambiar solo el idioma y lo que sería falso para tu producto.
