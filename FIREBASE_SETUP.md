# Firebase Setup Checklist

## ✅ Completed Steps:

1. ✅ **google-services.json** file is placed in `android/app/`
2. ✅ **NDK Version** updated to `27.0.12077973` in `android/app/build.gradle.kts`
3. ✅ **Google Services Plugin** added to project
4. ✅ Package name matches: `com.example.students_task_manager`
5. ✅ **Firebase Options** generated using FlutterFire CLI in `lib/firebase_options.dart`
6. ✅ **Firebase Initialization** updated in `main.dart` to use `DefaultFirebaseOptions.currentPlatform`

## 🔧 Required Firebase Console Configuration:

### 1. Enable Authentication
- Go to Firebase Console → Authentication → Get Started
- Enable **Email/Password** authentication method
  - Click on "Email/Password"
  - Toggle "Enable" switch
  - Click "Save"

### 2. Enable Cloud Firestore
- Go to Firebase Console → Firestore Database → Create Database
- Choose **Test mode** (for development) or **Production mode**
- Select a location for your database
- Click "Enable"

### 3. (Optional) Set Firestore Security Rules
For development, you can use these test rules:

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

**Important:** These rules allow any authenticated user to read/write their own user document. For production, implement stricter rules.

## 🚀 Next Steps:

1. Run `flutter pub get` (if not already done)
2. Build and run the app:
   ```bash
   flutter run
   ```

## 📝 Notes:

- The app will automatically create user documents in Firestore when users register
- Make sure Authentication and Firestore are enabled before testing registration/login
- The `users` collection will be created automatically when the first user registers

