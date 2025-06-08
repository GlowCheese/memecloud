# Giữ lại Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Giữ lại audio plugin (tuỳ plugin)
-keep class com.ryanheise.just_audio.** { *; }
-keep class com.ryanheise.audio_service.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**