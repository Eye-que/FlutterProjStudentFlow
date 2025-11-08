# Firebase Storage Setup Guide

## 🔴 Critical Issue: Profile Picture Upload Failing

The error `StorageException: The operation was cancelled (Code: -13040)` indicates that **Firebase Storage is not enabled** or **security rules are blocking the upload**.

## ✅ Solution: Enable Firebase Storage

### Step 1: Enable Firebase Storage in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **student-task-manager-4bc6a** (or your project name)
3. Click on **Storage** in the left sidebar
4. Click **Get Started**
5. Choose **Start in test mode** (for development) or **Start in production mode**
6. Select a storage location (same as Firestore location is recommended)
7. Click **Done**

### Step 2: Configure Storage Security Rules

After enabling Storage, configure the security rules:

1. Go to **Storage** → **Rules** tab
2. Replace the default rules with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow authenticated users to upload/read their own profile pictures
    match /profile_pictures/{userId}.jpg {
      allow read: if true; // Anyone can read profile pictures
      allow write: if request.auth != null && request.auth.uid == userId;
      allow delete: if request.auth != null && request.auth.uid == userId;
    }
    
    // Deny all other access
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

3. Click **Publish**

### Step 3: Verify Storage is Enabled

1. Go to **Storage** → **Files** tab
2. You should see an empty bucket (or existing files)
3. The bucket URL should be visible

### Step 4: Test the Upload

1. Restart your app
2. Try uploading a profile picture
3. Check the Storage → **Files** tab - you should see `profile_pictures/{uid}.jpg`
4. Check the console logs for upload progress

## 🔧 Troubleshooting

### Issue: "Permission denied" Error

**Solution:** Make sure the Storage rules allow authenticated users to write:
```javascript
allow write: if request.auth != null && request.auth.uid == userId;
```

### Issue: Upload Still Being Cancelled

**Possible Causes:**
1. **Network connection** - Check internet connection
2. **Large file size** - Try a smaller image (< 5MB)
3. **Timeout** - The upload might be taking too long
4. **Storage quota** - Check if you've exceeded Firebase Storage free tier

**Solutions:**
- Ensure stable internet connection
- Compress images before uploading
- Check Firebase Storage usage in Console

### Issue: Storage Not Enabled

If you don't see **Storage** in the Firebase Console sidebar:
1. Your Firebase project might be on the free Spark plan (Storage is available)
2. Make sure you have the correct permissions (Owner/Editor role)
3. Try refreshing the Firebase Console

## 📝 Expected Behavior After Setup

Once Storage is enabled and rules are configured:

1. ✅ Profile picture uploads should succeed
2. ✅ Upload progress will be logged in console
3. ✅ Images will appear in Storage → Files tab
4. ✅ Profile pictures will display in the app

## 🚀 Quick Checklist

- [ ] Firebase Storage enabled in Console
- [ ] Storage security rules configured
- [ ] Rules published
- [ ] App restarted
- [ ] Test upload performed
- [ ] Image appears in Storage → Files tab
- [ ] Profile picture displays in app

---

**Important:** After enabling Storage and configuring rules, wait 1-2 minutes for changes to propagate, then restart your app.

