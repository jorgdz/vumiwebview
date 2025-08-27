<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Capacitor Video WebView Plugin

Este es un plugin de Capacitor optimizado para videollamadas, basado en el proyecto Air Doctor. El plugin proporciona un WebView especializado que:

## Características Principales

- **WebView optimizado para videollamadas**: Configurado específicamente para plataformas como Zoom, Google Meet, Microsoft Teams, Jitsi Meet, etc.
- **Permisos automáticos**: Gestión automática de permisos de cámara y micrófono
- **Soporte multiplataforma**: Android, iOS y Web
- **Configuración avanzada**: User Agent personalizable, geolocalización, reproducción de medios sin gesto de usuario

## Estructura del Proyecto

### TypeScript/JavaScript
- `src/definitions.ts`: Interfaces y tipos TypeScript
- `src/index.ts`: Punto de entrada principal del plugin
- `src/web.ts`: Implementación para plataforma web

### Android
- `android/src/main/java/com/clata/plugins/videowebview/VideoWebviewPlugin.java`: Plugin principal de Android
- `android/src/main/java/com/clata/plugins/videowebview/VideoWebviewActivity.java`: Actividad WebView optimizada
- `android/src/main/res/layout/activity_video_webview.xml`: Layout de la actividad

### iOS
- `ios/Sources/VideoWebviewPlugin/VideoWebviewPlugin.swift`: Plugin principal de iOS
- `ios/Sources/VideoWebviewPlugin/VideoWebViewController.swift`: Controlador WebView optimizado
- `ios/Package.swift`: Configuración Swift Package Manager

## Configuraciones Clave

El WebView está optimizado con:
- JavaScript habilitado
- Permisos de cámara/micrófono automáticos
- Reproducción de medios sin gesto de usuario
- Geolocalización habilitada
- User Agent optimizado para compatibilidad
- Soporte para cookies de terceros
- Debug mode disponible

## Uso del Plugin

```typescript
import { VideoWebview } from 'capacitor-video-webview';

// Abrir WebView para videollamada
await VideoWebview.openVideoWebview({
  url: 'https://meet.google.com/xxx-xxx-xxx',
  title: 'Videollamada',
  allowJavaScript: true,
  allowGeolocation: true,
  allowMediaPlayback: true
});

// Verificar permisos
const permissions = await VideoWebview.checkPermissions();

// Solicitar permisos
await VideoWebview.requestPermissions();
```

## Instrucciones para Copilot

Al trabajar con este proyecto:

1. **Mantén la compatibilidad**: Las configuraciones están optimizadas para videollamadas web
2. **Respeta los permisos**: Los permisos de cámara/micrófono son críticos para el funcionamiento
3. **User Agent**: Usa User Agents compatibles con plataformas de videollamadas
4. **Configuraciones WebView**: Mantén las configuraciones optimizadas para WebRTC
5. **Gestión de errores**: Implementa manejo robusto de errores para permisos denegados

Este plugin es específicamente diseñado para telemedicina y aplicaciones de videollamadas profesionales.
