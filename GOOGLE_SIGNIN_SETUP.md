# Google Sign-In Setup Guide

## ✅ Implementation Complete

Google Sign-In has been successfully integrated into your Flutter app. The implementation includes:

1. ✅ Added `google_sign_in: ^6.2.1` dependency
2. ✅ Added `signInWithGoogle()` method to `AuthService`
3. ✅ Added `continueWithGoogle()` method to `AuthProvider`
4. ✅ Added Google Sign-In button to login screen (preserving all existing UI)
5. ✅ Automatic navigation to HomeScreen after successful Google Sign-In
6. ✅ Error handling with debug logs
7. ✅ User data creation/update in Firestore

## 🔧 Firebase Console Setup Required

### Step 1: Enable Google Sign-In Method

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Authentication** → **Sign-in method**
4. Find **Google** in the providers list
5. Click **Enable**
6. Enter your **Support email** (required)
7. Click **Save**

### Step 2: Get SHA-1 and SHA-256 Fingerprints

You need to register your app's SHA-1 and SHA-256 fingerprints in Firebase Console.

#### Option A: Using Gradle (Recommended)

Run this command in your project root:

```bash
cd android
./gradlew signingReport
```

On Windows PowerShell:
```powershell
cd android
.\gradlew signingReport
```

Look for output like:
```
Variant: debug
Config: debug
Store: C:\Users\YourName\.android\debug.keystore
Alias: AndroidDebugKey
MD5: XX:XX:XX:...
SHA1: XX:XX:XX:...
SHA-256: XX:XX:XX:...
Valid until: ...
```

#### Option B: Using Keytool

For debug keystore (default location):
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

On Windows:
```powershell
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

For release keystore:
```bash
keytool -list -v -keystore path/to/your/release.keystore -alias your_alias
```

### Step 3: Add SHA Fingerprints to Firebase

1. Go to Firebase Console → **Project Settings** (gear icon)
2. Scroll down to **Your apps** section
3. Select your Android app
4. Click **Add fingerprint**
5. Add both **SHA-1** and **SHA-256** fingerprints
6. Click **Save**

**Important:** 
- Add SHA fingerprints for **both debug and release** keystores
- If you use multiple build variants, add SHA for each

### Step 4: Download google-services.json (if not already done)

1. In Firebase Console → **Project Settings**
2. Under **Your apps**, find your Android app
3. Download `google-services.json`
4. Place it in `android/app/` directory

**File structure should be:**
```
android/
  app/
    google-services.json  ← Should be here
    build.gradle.kts
```

## 📱 Android Configuration

### Check build.gradle Files

#### android/app/build.gradle.kts
Your `minSdk` should be **21 or higher** (you have 23 ✅):
```kotlin
minSdk = 23  // Minimum required for Firebase Auth
```

#### android/build.gradle.kts
Make sure you have the Google Services plugin:
```kotlin
plugins {
    // ...
    id("com.google.gms.google-services") version "4.4.0" apply false
}
```

#### android/app/build.gradle.kts
Apply the plugin at the bottom:
```kotlin
plugins {
    // ...
    id("com.google.gms.google-services")
}
```

## 🧪 Testing Google Sign-In

### Test on Physical Device (Recommended)

1. Build and run your app on a physical Android device
2. Open the login screen
3. Tap **"Continue with Google"** button
4. Select your Google account
5. Grant permissions
6. You should be automatically logged in and navigated to HomeScreen

### Test on Emulator

1. Make sure your emulator has Google Play Services installed
2. Add a Google account in the emulator's Settings → Accounts
3. Run the app and test Google Sign-In

### Debug Logs

Watch the console for debug logs:
```
🔐 Starting Google Sign-In...
✅ Google Sign-In successful for UID: xxx
📧 Email: user@example.com
👤 Display Name: User Name
📸 Photo URL: https://...
📥 Checking user data in Firestore...
✅ User data created successfully in Firestore
```

## 🐛 Troubleshooting

### Issue: "Google Sign-In was canceled"
- **Solution:** This is normal if the user cancels the sign-in dialog. No action needed.

### Issue: "PlatformException" or "DEVELOPER_ERROR"
- **Solution:** 
  - Verify SHA-1 and SHA-256 are added in Firebase Console
  - Make sure `google-services.json` is in the correct location
  - Rebuild the app after adding SHA fingerprints

### Issue: "Network error" or "Connection failed"
- **Solution:**
  - Check internet connection
  - Ensure Google Play Services is up to date on the device
  - Verify Firebase project is active

### Issue: "Sign-in failed" with no details
- **Solution:**
  - Check Firebase Console → Authentication → Sign-in method → Google is enabled
  - Verify the correct Firebase project is configured
  - Check `google-services.json` matches your project

### Issue: User data not saving to Firestore
- **Solution:**
  - Check Firestore rules allow write access:
    ```javascript
    rules_version = '2';
    service cloud.firestore {
      match /databases/{database}/documents {
        match /users/{userId} {
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }
      }
    }
    ```

## 📝 Code Structure

### Files Modified:
1. `pubspec.yaml` - Added `google_sign_in` dependency
2. `lib/services/auth_service.dart` - Added `signInWithGoogle()` method
3. `lib/providers/auth_provider.dart` - Added `continueWithGoogle()` method
4. `lib/screens/auth/login_screen.dart` - Added Google Sign-In button and handler

### Key Methods:

#### AuthService.signInWithGoogle()
- Handles Google authentication flow
- Returns Firebase User on success
- Throws exceptions on error

#### AuthProvider.continueWithGoogle()
- Wraps Google Sign-In with loading states
- Creates/updates user data in Firestore
- Handles profile picture from Google account

#### LoginScreen._handleGoogleSignIn()
- UI handler for Google Sign-In button
- Navigates to HomeScreen on success
- Shows error dialogs on failure

## ✅ Checklist

Before testing, ensure:

- [ ] Google Sign-In enabled in Firebase Console
- [ ] SHA-1 fingerprint added to Firebase Console
- [ ] SHA-256 fingerprint added to Firebase Console
- [ ] `google-services.json` file in `android/app/`
- [ ] Google Services plugin applied in `build.gradle.kts`
- [ ] App rebuilt after adding SHA fingerprints
- [ ] Physical device or emulator with Google Play Services

## 🚀 Next Steps

1. Complete Firebase Console setup (Steps 1-4 above)
2. Rebuild your app: `flutter clean && flutter pub get && flutter run`
3. Test Google Sign-In on a physical device
4. Check console logs for any errors
5. Verify user data is created in Firestore after sign-in

## 📚 Additional Resources

- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Adding SHA Fingerprints](https://developers.google.com/android/guides/client-auth)

---

**Note:** iOS support is disabled as per your requirements. The implementation is Android-only.
