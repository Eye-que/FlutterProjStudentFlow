# Enable Cloud Firestore API - Quick Fix Guide

## 🔴 Critical Issue

Your app is getting this error:
```
Cloud Firestore API has not been used in project student-task-manager-4bc6a before or it is disabled.
Enable it by visiting https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=student-task-manager-4bc6a
```

## ✅ Solution: Enable Cloud Firestore API

### Step 1: Open the API Enable Link

Click this direct link (replace with your project ID if different):
**https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=student-task-manager-4bc6a**

Or follow these manual steps:

### Step 2: Enable via Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Make sure you're in the correct project: **student-task-manager-4bc6a**
3. Navigate to **APIs & Services** → **Library**
4. Search for **"Cloud Firestore API"**
5. Click on **Cloud Firestore API**
6. Click **Enable** button
7. Wait 1-2 minutes for the API to be fully enabled

### Step 3: Alternative - Enable via Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **student-task-manager-4bc6a**
3. Go to **Firestore Database** (left sidebar)
4. If you see a message about enabling Firestore, click **Create database**
5. Choose your database location and security rules
6. Click **Enable**

### Step 4: Verify API is Enabled

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to **APIs & Services** → **Enabled APIs**
3. You should see **Cloud Firestore API** in the list

### Step 5: Wait and Retry

- Wait **2-5 minutes** after enabling the API
- The changes need to propagate to Google's servers
- Then restart your app and try again

## 🔍 How to Check Your Project ID

If you're not sure about your project ID:

1. Open `android/app/google-services.json`
2. Look for `"project_id": "your-project-id"`
3. Use that project ID in the enable link

## ⚠️ Important Notes

### Why This Happens:
- Firestore API needs to be explicitly enabled in Google Cloud Console
- It's not automatically enabled when you create a Firebase project
- First-time Firestore usage requires API activation

### After Enabling:
- **Wait 2-5 minutes** for propagation
- **Restart your app** completely (close and reopen)
- The "unavailable" errors should stop
- The PERMISSION_DENIED errors will be resolved

### If Issues Persist:

1. **Check Billing:**
   - Firestore requires a billing account (even for free tier)
   - Go to Firebase Console → Project Settings → Usage and billing
   - Ensure billing is enabled

2. **Check Firebase Project:**
   - Make sure `google-services.json` matches your Firebase project
   - Verify the project ID in `google-services.json` matches the enabled API project

3. **Check Permissions:**
   - Ensure you have "Owner" or "Editor" role in the Google Cloud project
   - You need permissions to enable APIs

## 🚀 Expected Behavior After Fix

Once the API is enabled, you should see:
- ✅ No more PERMISSION_DENIED errors
- ✅ Successful Firestore reads/writes
- ✅ User data loads correctly
- ✅ Profile pictures save successfully

## 📝 Related Errors Fixed

- ❌ `PERMISSION_DENIED: Cloud Firestore API has not been used`
- ✅ Will be resolved after enabling the API

- ⚠️ `[cloud_firestore/unavailable]` (transient errors)
- ✅ Will improve after API is enabled, but may still occur occasionally (retry logic handles this)

---

**Quick Action:** Click this link to enable Firestore API directly:
**https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=student-task-manager-4bc6a**
