# Pusher Channels Flutter
-keep class com.pusher.** { *; }
-keepclassmembers class com.pusher.** { *; }
-dontwarn com.pusher.**

# OkHttp (used by Pusher)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# SLF4J (logging framework used by Pusher)
-dontwarn org.slf4j.**
-keep class org.slf4j.** { *; }

# Keep all classes that might be referenced by Pusher
-keep class * implements org.slf4j.spi.LoggerFactoryBinder { *; }
-dontwarn org.slf4j.impl.StaticLoggerBinder

# WebSocket support
-keepattributes Signature
-keepattributes *Annotation*
-keep class * extends java.lang.Exception

# Firebase (already configured but adding for safety)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
