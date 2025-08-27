export interface VideoWebviewPlugin {
  /**
   * Abre una URL en un WebView optimizado para videollamadas
   */
  openVideoWebview(options: OpenVideoWebviewOptions): Promise<void>;

  /**
   * Cierra el WebView de videollamadas
   */
  closeVideoWebview(): Promise<void>;

  /**
   * Verifica si los permisos de cámara y micrófono están otorgados
   */
  checkPermissions(): Promise<PermissionStatus>;

  /**
   * Solicita permisos de cámara y micrófono
   */
  requestPermissions(): Promise<PermissionStatus>;

  /**
   * Configura las opciones del WebView
   */
  setWebviewOptions(options: WebviewOptions): Promise<void>;
}

export interface OpenVideoWebviewOptions {
  /**
   * URL a cargar en el WebView
   */
  url: string;

  /**
   * User Agent personalizado (opcional)
   */
  userAgent?: string;

  /**
   * Headers adicionales para la solicitud (opcional)
   */
  headers?: { [key: string]: string };

  /**
   * Permite JavaScript (por defecto: true)
   */
  allowJavaScript?: boolean;

  /**
   * Permite geolocalización (por defecto: true)
   */
  allowGeolocation?: boolean;

  /**
   * Permite reproducción de medios sin gesto de usuario (por defecto: true)
   */
  allowMediaPlayback?: boolean;

  /**
   * Habilita depuración web (solo desarrollo)
   */
  debugEnabled?: boolean;

  /**
   * Título de la barra de navegación (opcional)
   */
  title?: string;

  /**
   * Color de la barra de navegación en formato hex (opcional)
   */
  toolbarColor?: string;
}

export interface WebviewOptions {
  /**
   * Habilita cookies de terceros (por defecto: true)
   */
  allowThirdPartyCookies?: boolean;

  /**
   * Almacenamiento local habilitado (por defecto: true)
   */
  allowLocalStorage?: boolean;

  /**
   * Permite apertura de ventanas emergentes (por defecto: false)
   */
  allowPopups?: boolean;

  /**
   * Zoom habilitado (por defecto: false)
   */
  allowZoom?: boolean;
}

export interface PermissionStatus {
  camera: PermissionState;
  microphone: PermissionState;
}

export type PermissionState = 'prompt' | 'prompt-with-rationale' | 'granted' | 'denied';
