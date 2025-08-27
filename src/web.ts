import { WebPlugin } from '@capacitor/core';

import type { 
  VideoWebviewPlugin,
  OpenVideoWebviewOptions,
  PermissionStatus,
  WebviewOptions
} from './definitions';

export class VideoWebviewWeb extends WebPlugin implements VideoWebviewPlugin {
  async openVideoWebview(options: OpenVideoWebviewOptions): Promise<void> {
    console.log('Abriendo WebView con opciones:', options);
    
    // En web, abrimos en una nueva ventana/pestaña
    const features = [
      'resizable=yes',
      'scrollbars=yes',
      'status=yes',
      'toolbar=no',
      'menubar=no',
      'location=no'
    ].join(',');

    window.open(options.url, '_blank', features);
  }

  async closeVideoWebview(): Promise<void> {
    console.log('Cerrando WebView (no implementado en web)');
    // En web no hay control directo sobre ventanas abiertas
  }

  async checkPermissions(): Promise<PermissionStatus> {
    // En web, verificamos permisos usando la API de permisos del navegador
    try {
      const cameraPermission = await navigator.permissions.query({ name: 'camera' as PermissionName });
      const microphonePermission = await navigator.permissions.query({ name: 'microphone' as PermissionName });

      return {
        camera: cameraPermission.state as any,
        microphone: microphonePermission.state as any
      };
    } catch (error) {
      // Fallback si la API de permisos no está disponible
      return {
        camera: 'prompt',
        microphone: 'prompt'
      };
    }
  }

  async requestPermissions(): Promise<PermissionStatus> {
    try {
      // Intentamos acceder a los medios para solicitar permisos
      const stream = await navigator.mediaDevices.getUserMedia({ 
        video: true, 
        audio: true 
      });
      
      // Liberamos el stream inmediatamente
      stream.getTracks().forEach(track => track.stop());

      return {
        camera: 'granted',
        microphone: 'granted'
      };
    } catch (error) {
      return {
        camera: 'denied',
        microphone: 'denied'
      };
    }
  }

  async setWebviewOptions(options: WebviewOptions): Promise<void> {
    console.log('Configurando opciones del WebView:', options);
    // En web, estas configuraciones no son aplicables directamente
  }
}
