package com.clata.plugins.videowebview;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import androidx.core.content.ContextCompat;

import com.getcapacitor.JSObject;
import com.getcapacitor.PermissionCallback;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.getcapacitor.annotation.Permission;

@CapacitorPlugin(
    name = "VideoWebview",
    permissions = {
        @Permission(strings = {Manifest.permission.CAMERA}, alias = "camera"),
        @Permission(strings = {Manifest.permission.RECORD_AUDIO}, alias = "microphone")
    }
)
public class VideoWebviewPlugin extends Plugin {

    @PluginMethod
    public void openVideoWebview(PluginCall call) {
        String url = call.getString("url");
        if (url == null) {
            call.reject("URL es requerida");
            return;
        }

        String userAgent = call.getString("userAgent");
        Boolean allowJavaScript = call.getBoolean("allowJavaScript", true);
        Boolean allowGeolocation = call.getBoolean("allowGeolocation", true);
        Boolean allowMediaPlayback = call.getBoolean("allowMediaPlayback", true);
        Boolean debugEnabled = call.getBoolean("debugEnabled", false);
        String title = call.getString("title", "Video WebView");
        String toolbarColor = call.getString("toolbarColor");

        Intent intent = new Intent(getContext(), VideoWebviewActivity.class);
        intent.putExtra("url", url);
        intent.putExtra("userAgent", userAgent);
        intent.putExtra("allowJavaScript", allowJavaScript);
        intent.putExtra("allowGeolocation", allowGeolocation);
        intent.putExtra("allowMediaPlayback", allowMediaPlayback);
        intent.putExtra("debugEnabled", debugEnabled);
        intent.putExtra("title", title);
        intent.putExtra("toolbarColor", toolbarColor);

        getActivity().startActivity(intent);
        call.resolve();
    }

    @PluginMethod
    public void closeVideoWebview(PluginCall call) {
        // Enviar broadcast para cerrar la actividad
        Intent intent = new Intent("com.clata.plugins.videowebview.CLOSE");
        getContext().sendBroadcast(intent);
        call.resolve();
    }

    @PluginMethod
    public void checkPermissions(PluginCall call) {
        JSObject result = new JSObject();
        result.put("camera", getPermissionState(Manifest.permission.CAMERA));
        result.put("microphone", getPermissionState(Manifest.permission.RECORD_AUDIO));
        call.resolve(result);
    }

    @PluginMethod
    public void requestPermissions(PluginCall call) {
        String[] permissions = {
            Manifest.permission.CAMERA,
            Manifest.permission.RECORD_AUDIO
        };

        if (hasRequiredPermissions()) {
            JSObject result = new JSObject();
            result.put("camera", "granted");
            result.put("microphone", "granted");
            call.resolve(result);
        } else {
            requestPermissionForAliases(permissions, call, "permissionsCallback");
        }
    }

    @PermissionCallback
    private void permissionsCallback(PluginCall call) {
        JSObject result = new JSObject();
        result.put("camera", getPermissionState(Manifest.permission.CAMERA));
        result.put("microphone", getPermissionState(Manifest.permission.RECORD_AUDIO));
        call.resolve(result);
    }

    @PluginMethod
    public void setWebviewOptions(PluginCall call) {
        // Guardar opciones en SharedPreferences para uso posterior
        SharedPreferences prefs = getContext().getSharedPreferences("VideoWebviewOptions", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = prefs.edit();

        Boolean allowThirdPartyCookies = call.getBoolean("allowThirdPartyCookies", true);
        Boolean allowLocalStorage = call.getBoolean("allowLocalStorage", true);
        Boolean allowPopups = call.getBoolean("allowPopups", false);
        Boolean allowZoom = call.getBoolean("allowZoom", false);

        editor.putBoolean("allowThirdPartyCookies", allowThirdPartyCookies);
        editor.putBoolean("allowLocalStorage", allowLocalStorage);
        editor.putBoolean("allowPopups", allowPopups);
        editor.putBoolean("allowZoom", allowZoom);
        editor.apply();

        call.resolve();
    }

    private String getPermissionState(String permission) {
        if (ContextCompat.checkSelfPermission(getContext(), permission) == PackageManager.PERMISSION_GRANTED) {
            return "granted";
        }
        return "denied";
    }

    private boolean hasRequiredPermissions() {
        return ContextCompat.checkSelfPermission(getContext(), Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED &&
               ContextCompat.checkSelfPermission(getContext(), Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED;
    }
}
