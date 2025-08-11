# Keep javax.naming classes
-keep class javax.naming.** { *; }
-dontwarn javax.naming.**

# Keep org.ietf.jgss classes
-keep class org.ietf.jgss.** { *; }
-dontwarn org.ietf.jgss.**

# Keep Apache HTTP client classes
-keep class org.apache.http.** { *; }
-dontwarn org.apache.http.**

# Keep SSL classes
-keep class javax.net.ssl.** { *; }
-dontwarn javax.net.ssl.**

# Keep LDAP classes
-keep class com.sun.jndi.ldap.** { *; }
-dontwarn com.sun.jndi.ldap.**

# Keep Kerberos classes
-keep class sun.security.krb5.** { *; }
-dontwarn sun.security.krb5.**