# Capacitor Video WebView Plugin

Un plugin de Capacitor optimizado para videollamadas, basado en el proyecto Air Doctor. Este plugin proporciona un WebView especializado que está configurado específicamente para funcionar con plataformas de videollamadas como Zoom, Google Meet, Microsoft Teams, Jitsi Meet y cualquier solución basada en WebRTC.

## 🚀 Características

- ✅ **WebView optimizado para videollamadas**
- ✅ **Permisos automáticos** de cámara y micrófono
- ✅ **Soporte multiplataforma** (Android, iOS, Web)
- ✅ **Configuración avanzada** personalizable
- ✅ **User Agent optimizado** para compatibilidad
- ✅ **Geolocalización habilitada**
- ✅ **Reproducción de medios sin gesto de usuario**
- ✅ **Soporte para cookies de terceros**
- ✅ **Debug mode** para desarrollo

## 📦 Instalación

```bash
npm install capacitor-video-webview
npx cap sync
```

### Configuración Adicional

#### Android

Añade los siguientes permisos en `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

#### iOS

Añade las siguientes claves en `ios/App/App/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Esta app necesita acceso a la cámara para videollamadas</string>
<key>NSMicrophoneUsageDescription</key>
<string>Esta app necesita acceso al micrófono para videollamadas</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Esta app puede necesitar tu ubicación para algunos servicios</string>
```

## 🔧 Uso

### Importar el Plugin

```typescript
import { VideoWebview } from 'capacitor-video-webview';
```

### Abrir WebView para Videollamada

```typescript
await VideoWebview.openVideoWebview({
  url: 'https://meet.google.com/xxx-xxx-xxx',
  title: 'Consulta Médica',
  allowJavaScript: true,
  allowGeolocation: true,
  allowMediaPlayback: true,
  debugEnabled: false, // Solo para desarrollo
  toolbarColor: '#007AFF'
});
```

### Verificar Permisos

```typescript
const permissions = await VideoWebview.checkPermissions();
console.log('Cámara:', permissions.camera);
console.log('Micrófono:', permissions.microphone);
```

### Solicitar Permisos

```typescript
const permissions = await VideoWebview.requestPermissions();
if (permissions.camera === 'granted' && permissions.microphone === 'granted') {
  // Permisos otorgados, proceder con videollamada
}
```

### Configurar Opciones del WebView

```typescript
await VideoWebview.setWebviewOptions({
  allowThirdPartyCookies: true,
  allowLocalStorage: true,
  allowPopups: false,
  allowZoom: false
});
```

### Cerrar WebView

```typescript
await VideoWebview.closeVideoWebview();
```

## 📚 API

### `openVideoWebview(options: OpenVideoWebviewOptions)`

Abre una URL en un WebView optimizado para videollamadas.

#### Opciones

| Opción | Tipo | Defecto | Descripción |
|--------|------|---------|-------------|
| `url` | `string` | - | **Requerido.** URL a cargar |
| `title` | `string` | `"Video WebView"` | Título de la barra de navegación |
| `userAgent` | `string` | - | User Agent personalizado |
| `allowJavaScript` | `boolean` | `true` | Habilitar JavaScript |
| `allowGeolocation` | `boolean` | `true` | Habilitar geolocalización |
| `allowMediaPlayback` | `boolean` | `true` | Reproducción sin gesto de usuario |
| `debugEnabled` | `boolean` | `false` | Habilitar debug web |
| `toolbarColor` | `string` | - | Color de barra en formato hex |
| `headers` | `object` | - | Headers HTTP adicionales |

### `closeVideoWebview()`

Cierra el WebView activo.

### `checkPermissions()`

Verifica el estado actual de los permisos.

**Retorna:** `Promise<PermissionStatus>`

### `requestPermissions()`

Solicita permisos de cámara y micrófono.

**Retorna:** `Promise<PermissionStatus>`

### `setWebviewOptions(options: WebviewOptions)`

Configura opciones adicionales del WebView.

#### Opciones

| Opción | Tipo | Defecto | Descripción |
|--------|------|---------|-------------|
| `allowThirdPartyCookies` | `boolean` | `true` | Cookies de terceros |
| `allowLocalStorage` | `boolean` | `true` | Almacenamiento local |
| `allowPopups` | `boolean` | `false` | Ventanas emergentes |
| `allowZoom` | `boolean` | `false` | Zoom en el WebView |

## 🎯 Casos de Uso

### Telemedicina

```typescript
// Consulta médica con Zoom
await VideoWebview.openVideoWebview({
  url: 'https://zoom.us/j/123456789',
  title: 'Consulta con Dr. Smith',
  toolbarColor: '#4CAF50'
});
```

### Educación en Línea

```typescript
// Clase virtual con Google Meet
await VideoWebview.openVideoWebview({
  url: 'https://meet.google.com/abc-defg-hij',
  title: 'Clase de Matemáticas',
  toolbarColor: '#2196F3'
});
```

### Reuniones Corporativas

```typescript
// Reunión con Microsoft Teams
await VideoWebview.openVideoWebview({
  url: 'https://teams.microsoft.com/l/meetup-join/...',
  title: 'Reunión de Equipo',
  toolbarColor: '#6264A7'
});
```

## 🔍 Características Técnicas

### Configuraciones del WebView

El plugin configura automáticamente:

- **JavaScript habilitado**
- **Acceso a cámara y micrófono**
- **Reproducción de medios automática**
- **Geolocalización**
- **Cookies de terceros**
- **User Agent optimizado**
- **Acceso a archivos locales**
- **Almacenamiento DOM**

### Compatibilidad

✅ **Plataformas Probadas:**
- Zoom Web SDK
- Google Meet
- Microsoft Teams
- Jitsi Meet
- WebEx
- GoToMeeting
- Cualquier solución WebRTC

## 🛠️ Desarrollo

### Compilar el Plugin

```bash
npm run build
```

### Ejecutar Tests

```bash
npm run verify
```

### Verificar Plataformas

```bash
# Verificar Android
npm run verify:android

# Verificar iOS
npm run verify:ios

# Verificar Web
npm run verify:web
```

## 📄 Licencia

MIT

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature
3. Commit tus cambios
4. Push a la rama
5. Abre un Pull Request

## 📞 Soporte

Para reportar problemas o solicitar nuevas características, por favor abre un [issue](https://github.com/clata/capacitor-video-webview/issues).

---

**Nota:** Este plugin está optimizado específicamente para videollamadas y puede no ser adecuado para otros tipos de contenido web general. Para un WebView general, considera usar el plugin oficial de Capacitor.
