# Flutter Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Dio Rules
-keep class com.dio.** { *; }

# Keep models to prevent JSON serialization issues
-keep class com.example.my_flutter_app.models.** { *; }
-keepclassmembers class * {
  @google.gson.annotations.SerializedName <fields>;
}

# Keep all classes in the models directory (adjust package if necessary)
-keep class **.models.** { *; }

# Riverpod / State Management (if needed)
-keep class **.providers.** { *; }

# Common Android rules
-dontwarn javax.annotation.**
-dontwarn org.checkerframework.**
-dontwarn com.google.errorprone.annotations.**
