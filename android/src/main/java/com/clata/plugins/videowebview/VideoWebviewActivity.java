package com.clata.plugins.videowebview;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.webkit.ConsoleMessage;
import android.webkit.GeolocationPermissions;
import android.webkit.PermissionRequest;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.core.content.ContextCompat;

public class VideoWebviewActivity extends AppCompatActivity {
    private WebView webView;
    private BroadcastReceiver closeReceiver;
    private ValueCallback<Uri[]> filePathCallback;

    @Override
    @SuppressLint("SetJavaScriptEnabled")
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_video_webview);

        // Configurar toolbar
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        
        String title = getIntent().getStringExtra("title");
        if (title != null) {
            setTitle(title);
        }

        String toolbarColor = getIntent().getStringExtra("toolbarColor");
        if (toolbarColor != null) {
            try {
                toolbar.setBackgroundColor(Color.parseColor(toolbarColor));
            } catch (IllegalArgumentException e) {
                // Color inválido, usar por defecto
            }
        }

        // Configurar WebView
        webView = findViewById(R.id.webview);
        setupWebView();

        // Cargar URL
        String url = getIntent().getStringExtra("url");
        if (url != null) {
            webView.loadUrl(url);
        }

        // Registrar receiver para cerrar
        closeReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                finish();
            }
        };
        registerReceiver(closeReceiver, new IntentFilter("com.clata.plugins.videowebview.CLOSE"));
    }

    @SuppressLint("SetJavaScriptEnabled")
    private void setupWebView() {
        WebSettings settings = webView.getSettings();
        
        // Configuraciones básicas
        Boolean allowJavaScript = getIntent().getBooleanExtra("allowJavaScript", true);
        settings.setJavaScriptEnabled(allowJavaScript);
        
        Boolean allowGeolocation = getIntent().getBooleanExtra("allowGeolocation", true);
        settings.setGeolocationEnabled(allowGeolocation);

        // Configuraciones para videollamadas (basado en Air Doctor)
        settings.setDomStorageEnabled(true);
        settings.setDatabaseEnabled(true);
        settings.setAllowFileAccess(true);
        settings.setAllowContentAccess(true);
        settings.setAllowUniversalAccessFromFileURLs(true);
        settings.setAllowFileAccessFromFileURLs(true);
        
        // Soporte para medios
        Boolean allowMediaPlayback = getIntent().getBooleanExtra("allowMediaPlayback", true);
        settings.setMediaPlaybackRequiresUserGesture(!allowMediaPlayback);
        
        // User Agent personalizado
        String userAgent = getIntent().getStringExtra("userAgent");
        if (userAgent != null) {
            settings.setUserAgentString(userAgent);
        } else {
            // Usar User Agent optimizado para compatibilidad
            String defaultUA = settings.getUserAgentString();
            settings.setUserAgentString(defaultUA.replace("; wv)", ")"));
        }

        // Opciones adicionales desde SharedPreferences
        SharedPreferences prefs = getSharedPreferences("VideoWebviewOptions", Context.MODE_PRIVATE);
        
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
            settings.setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);
            
            Boolean allowThirdPartyCookies = prefs.getBoolean("allowThirdPartyCookies", true);
            android.webkit.CookieManager.getInstance().setAcceptThirdPartyCookies(webView, allowThirdPartyCookies);
        }

        Boolean allowZoom = prefs.getBoolean("allowZoom", false);
        settings.setSupportZoom(allowZoom);
        settings.setBuiltInZoomControls(allowZoom);
        settings.setDisplayZoomControls(false);

        // Debug
        Boolean debugEnabled = getIntent().getBooleanExtra("debugEnabled", false);
        if (debugEnabled && android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
            WebView.setWebContentsDebuggingEnabled(true);
        }

        // WebViewClient
        webView.setWebViewClient(new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                // Manejar esquemas especiales
                Uri uri = Uri.parse(url);
                String scheme = uri.getScheme();
                
                if ("tel".equals(scheme) || "mailto".equals(scheme) || "whatsapp".equals(scheme)) {
                    try {
                        Intent intent = new Intent(Intent.ACTION_VIEW, uri);
                        startActivity(intent);
                        return true;
                    } catch (Exception e) {
                        return false;
                    }
                }
                
                return false;
            }
        });

        // WebChromeClient para permisos y file chooser
        webView.setWebChromeClient(new WebChromeClient() {
            @Override
            public void onPermissionRequest(final PermissionRequest request) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        // Verificar permisos necesarios
                        String[] resources = request.getResources();
                        boolean needsCamera = false;
                        boolean needsMicrophone = false;

                        for (String resource : resources) {
                            if (PermissionRequest.RESOURCE_VIDEO_CAPTURE.equals(resource)) {
                                needsCamera = true;
                            } else if (PermissionRequest.RESOURCE_AUDIO_CAPTURE.equals(resource)) {
                                needsMicrophone = true;
                            }
                        }

                        // Verificar permisos del sistema
                        boolean hasCamera = !needsCamera || 
                            ContextCompat.checkSelfPermission(VideoWebviewActivity.this, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED;
                        boolean hasMicrophone = !needsMicrophone || 
                            ContextCompat.checkSelfPermission(VideoWebviewActivity.this, Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED;

                        if (hasCamera && hasMicrophone) {
                            request.grant(resources);
                        } else {
                            request.deny();
                            Toast.makeText(VideoWebviewActivity.this, "Permisos de cámara y micrófono requeridos", Toast.LENGTH_SHORT).show();
                        }
                    }
                });
            }

            @Override
            public void onGeolocationPermissionsShowPrompt(String origin, GeolocationPermissions.Callback callback) {
                callback.invoke(origin, true, false);
            }

            @Override
            public boolean onConsoleMessage(ConsoleMessage consoleMessage) {
                android.util.Log.d("VideoWebView", "Console: " + consoleMessage.message() + 
                    " at " + consoleMessage.sourceId() + ":" + consoleMessage.lineNumber());
                return true;
            }

            @Override
            public boolean onShowFileChooser(WebView webView, ValueCallback<Uri[]> filePathCallback, FileChooserParams fileChooserParams) {
                VideoWebviewActivity.this.filePathCallback = filePathCallback;
                
                Intent intent = fileChooserParams.createIntent();
                try {
                    startActivityForResult(intent, 1001);
                    return true;
                } catch (Exception e) {
                    filePathCallback.onReceiveValue(null);
                    return false;
                }
            }
        });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        
        if (requestCode == 1001 && filePathCallback != null) {
            Uri[] results = null;
            if (resultCode == Activity.RESULT_OK && data != null) {
                String dataString = data.getDataString();
                if (dataString != null) {
                    results = new Uri[]{Uri.parse(dataString)};
                }
            }
            filePathCallback.onReceiveValue(results);
            filePathCallback = null;
        }
    }

    @Override
    public void onBackPressed() {
        if (webView.canGoBack()) {
            webView.goBack();
        } else {
            super.onBackPressed();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (closeReceiver != null) {
            unregisterReceiver(closeReceiver);
        }
    }
}
