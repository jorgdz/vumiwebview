# VideoWebview Plugin ProGuard Rules

# Keep all classes in the plugin package
-keep class com.clata.plugins.videowebview.** { *; }

# Keep Capacitor plugin annotations
-keep @com.getcapacitor.annotation.CapacitorPlugin class * {
    @com.getcapacitor.annotation.PluginMethod <methods>;
}

# Keep WebView classes
-keep class android.webkit.** { *; }
-dontwarn android.webkit.**

# Keep AndroidX classes
-keep class androidx.** { *; }
-dontwarn androidx.**

# Keep reflection-related classes
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep native method names
-keepclasseswithmembernames class * {
    native <methods>;
}

# Don't warn about missing dependencies
-dontwarn java.lang.invoke.**
-dontwarn org.apache.http.**
-dontwarn android.net.http.**
