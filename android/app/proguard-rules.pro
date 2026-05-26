## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

## Gson rules
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.stream.** { *; }

## OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

## Retrofit
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }
-keepattributes Signature
-keepattributes Exceptions

## WebView
-keepclassmembers class * extends android.webkit.WebViewClient {
    public void *(android.webkit.WebView, java.lang.String, android.graphics.Bitmap);
    public boolean *(android.webkit.WebView, java.lang.String);
}
-keepclassmembers class * extends android.webkit.WebViewClient {
    public void *(android.webkit.WebView, java.lang.String);
}

## Keep native methods
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

## File Picker
-keep class com.mr.flutter.plugin.filepicker.** { *; }

## Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }

## URL Launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

## Shared Preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

## Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

## Path Provider
-keep class io.flutter.plugins.pathprovider.** { *; }

## Play Core (split compat)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

## javax annotations
-dontwarn javax.annotation.**
-keep class javax.annotation.** { *; }
