# Flutter / Dart AOT — keep all Flutter embedding classes intact.
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Appwrite SDK — keep model and exception classes used via reflection.
-keep class io.appwrite.** { *; }
-dontwarn io.appwrite.**

# Firebase Messaging — required for FCM token registration.
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Shorebird code-push — keep updater JNI entry points.
-keep class com.shorebird.** { *; }
-dontwarn com.shorebird.**

# Keep Kotlin coroutines internals that R8 may otherwise strip.
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-dontwarn kotlinx.coroutines.**

# Prevent R8 from stripping serialisation-related annotations.
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
