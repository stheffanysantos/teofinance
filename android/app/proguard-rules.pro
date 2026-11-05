# O plugin de IA local chama o shared_preferences_android por JNI (pelo nome do
# método); sem estas regras o R8 do build release renomeia/remove os métodos e
# dá NoSuchMethodError ("Motor de IA local não iniciou").
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class com.google.ai.edge.** { *; }
-keep class com.google.mediapipe.** { *; }
-keep class com.google.protobuf.** { *; }
-dontwarn com.google.ai.edge.**
-dontwarn com.google.mediapipe.**
