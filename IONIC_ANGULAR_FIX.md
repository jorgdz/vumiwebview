# Solución de Problemas - Ionic Angular

## 🔧 Error: ObjectInstantiationException en Android

### **Problema:**
```
Caused by: org.gradle.api.reflect.ObjectInstantiationException: Could not create an instance of type com.android.build.api.variant.impl.LibraryVariantBuilderImpl.
```

### **Causa:**
Este error ocurre por incompatibilidades entre versiones del Android Gradle Plugin y la configuración del plugin.

### **✅ Solución Aplicada:**

#### 1. **Actualización de build.gradle:**
- Actualizado a `compileSdk` en lugar de `compileSdkVersion`
- Agregado `namespace` para el plugin
- Actualizado a Java 11
- Modernizado configuración de lint
- Agregado `buildFeatures`

#### 2. **Dependencias Actualizadas:**
- Uso de variables para versiones consistentes
- Compatibilidad con AndroidX más reciente
- Dependencias alineadas con Capacitor 6/7

#### 3. **Configuración Adicional:**
- Archivo `gradle.properties` con configuraciones específicas
- Reglas ProGuard para evitar obfuscación
- Anotaciones de permisos actualizadas

## 🚀 Pasos para Integrar en tu App Ionic Angular

### **1. Instalación del Plugin:**
```bash
npm install ./path/to/capacitor-video-webview
npx cap sync android
```

### **2. Configuración en tu Proyecto:**

#### **android/app/build.gradle** - Verificar versiones compatibles:
```gradle
android {
    compileSdk 34
    
    defaultConfig {
        minSdk 22
        targetSdk 34
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_11
        targetCompatibility JavaVersion.VERSION_11
    }
}
```

#### **android/build.gradle** - Verificar Android Gradle Plugin:
```gradle
dependencies {
    classpath 'com.android.tools.build:gradle:8.1.4'
}
```

#### **android/gradle/wrapper/gradle-wrapper.properties:**
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.4-bin.zip
```

### **3. Permisos en AndroidManifest.xml:**
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### **4. Uso en Angular:**
```typescript
import { VideoWebview } from 'capacitor-video-webview';

export class VideoCallService {
  async openVideoCall(url: string) {
    try {
      // Verificar permisos primero
      const permissions = await VideoWebview.checkPermissions();
      
      if (permissions.camera !== 'granted' || permissions.microphone !== 'granted') {
        await VideoWebview.requestPermissions();
      }
      
      // Abrir videollamada
      await VideoWebview.openVideoWebview({
        url: url,
        title: 'Videollamada',
        allowJavaScript: true,
        allowGeolocation: true,
        allowMediaPlayback: true
      });
    } catch (error) {
      console.error('Error en videollamada:', error);
    }
  }
}
```

## 🔍 Verificación de Compatibilidad

### **Versiones Recomendadas:**
- **Ionic CLI:** 7.x o superior
- **Angular:** 15+ 
- **Capacitor:** 5.x o 6.x
- **Android Gradle Plugin:** 8.1.x
- **Gradle:** 8.4
- **Java:** 11 o 17

### **Comandos de Verificación:**
```bash
# Verificar versiones
ionic info

# Limpiar cache de Gradle
cd android && ./gradlew clean

# Regenerar archivos de Capacitor
npx cap sync android
```

## 🛠️ Debugging Adicional

### **Si persisten errores:**

1. **Limpiar completamente:**
```bash
rm -rf node_modules
rm -rf android/build
rm -rf android/.gradle
npm install
npx cap sync android
```

2. **Verificar Android Studio:**
- Abrir `android/` en Android Studio
- Sync Project with Gradle Files
- Verificar errores en Build Output

3. **Habilitar logs detallados:**
```bash
npx cap run android --verbose
```

## 📋 Checklist de Solución

- ✅ build.gradle actualizado con nueva sintaxis
- ✅ gradle.properties configurado
- ✅ Dependencias AndroidX actualizadas
- ✅ Anotaciones de Capacitor corregidas
- ✅ ProGuard rules agregadas
- ✅ Namespace definido en el plugin
- ✅ Java 11 configurado
- ✅ Permisos correctamente declarados

El plugin ahora debería compilar correctamente en tu proyecto Ionic Angular. Si encuentras algún problema adicional, revisa las versiones de tus dependencias y asegúrate de que sean compatibles entre sí.
