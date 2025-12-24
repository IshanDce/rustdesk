# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

# Keep Rust FFI native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep RustDesk specific classes
-keep class com.carriez.flutter_hbb.** { *; }

# Keep generated bridge code
-keep class com.carriez.flutter_hbb.generated.** { *; }

# Prevent stripping of Rust native library loader
-keep class * {
    static final java.lang.String FLUTTER_FFI_NATIVE_LIBRARY;
}

# Keep all classes that have native methods
-keepclasseswithmembers class * {
    native <methods>;
}

# Preserve line numbers for debugging
-keepattributes SourceFile,LineNumberTable

# Keep annotations
-keepattributes *Annotation*

# Keep generic signatures
-keepattributes Signature

# Keep exceptions
-keepattributes Exceptions
