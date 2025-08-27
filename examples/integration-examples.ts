// Ejemplo de integración del plugin en una app de Capacitor

import { VideoWebview } from 'capacitor-video-webview';

// 1. Verificar y solicitar permisos al iniciar la app
export async function initializeVideoWebview() {
  try {
    console.log('🔍 Verificando permisos...');
    const permissions = await VideoWebview.checkPermissions();
    
    if (permissions.camera !== 'granted' || permissions.microphone !== 'granted') {
      console.log('📝 Solicitando permisos...');
      const requestResult = await VideoWebview.requestPermissions();
      
      if (requestResult.camera !== 'granted' || requestResult.microphone !== 'granted') {
        throw new Error('Permisos de cámara y micrófono requeridos para videollamadas');
      }
    }
    
    // Configurar opciones globales del WebView
    await VideoWebview.setWebviewOptions({
      allowThirdPartyCookies: true,
      allowLocalStorage: true,
      allowPopups: false,
      allowZoom: false
    });
    
    console.log('✅ VideoWebview inicializado correctamente');
    return true;
  } catch (error) {
    console.error('❌ Error inicializando VideoWebview:', error);
    return false;
  }
}

// 2. Función para abrir videollamada médica
export async function openMedicalCall(appointmentData: {
  meetingUrl: string;
  patientName: string;
  doctorName: string;
  appointmentId: string;
}) {
  try {
    await VideoWebview.openVideoWebview({
      url: appointmentData.meetingUrl,
      title: `Consulta: ${appointmentData.patientName}`,
      toolbarColor: '#4CAF50', // Verde médico
      allowJavaScript: true,
      allowGeolocation: true,
      allowMediaPlayback: true,
      debugEnabled: __DEV__, // Solo en desarrollo
      headers: {
        'X-Appointment-ID': appointmentData.appointmentId,
        'X-Patient-Name': appointmentData.patientName,
        'X-Doctor-Name': appointmentData.doctorName
      }
    });
    
    console.log('🎥 Videollamada médica iniciada');
  } catch (error) {
    console.error('❌ Error abriendo videollamada:', error);
    throw error;
  }
}

// 3. Función para videollamadas de educación
export async function openEducationClass(classData: {
  classUrl: string;
  className: string;
  teacherName: string;
  studentName: string;
}) {
  try {
    await VideoWebview.openVideoWebview({
      url: classData.classUrl,
      title: `Clase: ${classData.className}`,
      toolbarColor: '#2196F3', // Azul educativo
      allowJavaScript: true,
      allowGeolocation: false, // No necesario para educación
      allowMediaPlayback: true,
      userAgent: 'EducationApp/1.0 (Mobile; VideoWebview)',
      headers: {
        'X-Class-Name': classData.className,
        'X-Teacher': classData.teacherName,
        'X-Student': classData.studentName
      }
    });
    
    console.log('📚 Clase virtual iniciada');
  } catch (error) {
    console.error('❌ Error abriendo clase virtual:', error);
    throw error;
  }
}

// 4. Función para reuniones corporativas
export async function openBusinessMeeting(meetingData: {
  meetingUrl: string;
  meetingTitle: string;
  organizerName: string;
  participantEmail: string;
}) {
  try {
    await VideoWebview.openVideoWebview({
      url: meetingData.meetingUrl,
      title: meetingData.meetingTitle,
      toolbarColor: '#6264A7', // Púrpura Teams
      allowJavaScript: true,
      allowGeolocation: false,
      allowMediaPlayback: true,
      userAgent: 'CorporateApp/1.0 (Business; VideoWebview)',
      headers: {
        'X-Meeting-Title': meetingData.meetingTitle,
        'X-Organizer': meetingData.organizerName,
        'X-Participant-Email': meetingData.participantEmail
      }
    });
    
    console.log('💼 Reunión corporativa iniciada');
  } catch (error) {
    console.error('❌ Error abriendo reunión:', error);
    throw error;
  }
}

// 5. Función para cerrar videollamada programáticamente
export async function endVideoCall() {
  try {
    await VideoWebview.closeVideoWebview();
    console.log('📱 Videollamada cerrada');
  } catch (error) {
    console.error('❌ Error cerrando videollamada:', error);
  }
}

// 6. Hook de React para gestionar estado de permisos
import { useState, useEffect } from 'react';

export function useVideoWebviewPermissions() {
  const [permissions, setPermissions] = useState<{
    camera: string;
    microphone: string;
    isReady: boolean;
  }>({
    camera: 'prompt',
    microphone: 'prompt',
    isReady: false
  });

  const checkPermissions = async () => {
    try {
      const status = await VideoWebview.checkPermissions();
      setPermissions({
        camera: status.camera,
        microphone: status.microphone,
        isReady: status.camera === 'granted' && status.microphone === 'granted'
      });
      return status;
    } catch (error) {
      console.error('Error verificando permisos:', error);
      return null;
    }
  };

  const requestPermissions = async () => {
    try {
      const status = await VideoWebview.requestPermissions();
      setPermissions({
        camera: status.camera,
        microphone: status.microphone,
        isReady: status.camera === 'granted' && status.microphone === 'granted'
      });
      return status;
    } catch (error) {
      console.error('Error solicitando permisos:', error);
      return null;
    }
  };

  useEffect(() => {
    checkPermissions();
  }, []);

  return {
    permissions,
    checkPermissions,
    requestPermissions,
    isReady: permissions.isReady
  };
}

// 7. Configuraciones predefinidas para diferentes plataformas
export const VIDEO_PLATFORMS = {
  ZOOM: {
    userAgent: 'Mozilla/5.0 (compatible; VideoWebview/1.0; Zoom)',
    allowPopups: true,
    requirements: ['camera', 'microphone']
  },
  
  GOOGLE_MEET: {
    userAgent: 'Mozilla/5.0 (compatible; VideoWebview/1.0; GoogleMeet)',
    allowPopups: false,
    requirements: ['camera', 'microphone']
  },
  
  MICROSOFT_TEAMS: {
    userAgent: 'Mozilla/5.0 (compatible; VideoWebview/1.0; MicrosoftTeams)',
    allowPopups: true,
    requirements: ['camera', 'microphone']
  },
  
  JITSI_MEET: {
    userAgent: 'Mozilla/5.0 (compatible; VideoWebview/1.0; JitsiMeet)',
    allowPopups: false,
    requirements: ['camera', 'microphone']
  }
};

// 8. Función helper para detectar plataforma y aplicar configuración
export async function openVideoCallWithPlatformDetection(url: string, title: string) {
  let platformConfig = null;
  
  if (url.includes('zoom.us')) {
    platformConfig = VIDEO_PLATFORMS.ZOOM;
  } else if (url.includes('meet.google.com')) {
    platformConfig = VIDEO_PLATFORMS.GOOGLE_MEET;
  } else if (url.includes('teams.microsoft.com')) {
    platformConfig = VIDEO_PLATFORMS.MICROSOFT_TEAMS;
  } else if (url.includes('meet.jit.si') || url.includes('jitsi.org')) {
    platformConfig = VIDEO_PLATFORMS.JITSI_MEET;
  }
  
  const options: any = {
    url,
    title,
    allowJavaScript: true,
    allowGeolocation: true,
    allowMediaPlayback: true
  };
  
  if (platformConfig) {
    options.userAgent = platformConfig.userAgent;
    await VideoWebview.setWebviewOptions({
      allowPopups: platformConfig.allowPopups,
      allowThirdPartyCookies: true,
      allowLocalStorage: true,
      allowZoom: false
    });
  }
  
  await VideoWebview.openVideoWebview(options);
}
