# ProGuard rules for Razorpay

# Keep Razorpay classes
-keep class com.razorpay.** { *; }
-keepclassmembers class com.razorpay.** { *; }

# Keep Razorpay plugin
-keep class io.flutter.plugins.razorpay.** { *; }

# OkHttp (used by Razorpay)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Retrofit (if used by Razorpay)
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }

# Gson (for JSON parsing)
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# Keep all model classes that might be serialized
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
