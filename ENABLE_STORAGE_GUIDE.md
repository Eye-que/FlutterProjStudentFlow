# 🔧 How to Enable Firebase Storage - Step by Step Guide

## Problem
Your app is getting the error: **"object-not-found: No object exists at the desired reference"**
This means Firebase Storage is not enabled in your Firebase project yet.

---

## ✅ Solution: Enable Firebase Storage

### Step 1: Open Firebase Console

1. Go to: **https://console.firebase.google.com/**
2. Sign in with your Google account (the same account you used to create the Firebase project)
3. You should see your project: **student-task-manager-4bc6a**

### Step 2: Navigate to Storage

1. In the left sidebar, look for **"Storage"** (it might be under "Build" section)
2. Click on **"Storage"**
3. You should see either:
   - **"Get started"** button (if billing is already set up) ✅
   - **"Upgrade project"** button (if billing is not set up) ⚠️

### Step 2.5: Add Billing Account (If You See "Upgrade project")

**⚠️ IMPORTANT:** Firebase Storage requires a billing account, even on the free tier!

1. Click the **"Upgrade project"** button
2. You'll be prompted to add a payment method (credit card)
3. **Don't worry:** Firebase has a generous free tier (Spark plan)
   - **5 GB** storage
   - **1 GB/day** downloads
   - **1 GB/day** uploads
   - **More than enough for profile pictures!**
4. Add your payment method and complete setup
5. Select **"Spark plan"** (free tier) if prompted
6. Wait 1-2 minutes for billing to activate
7. Return to Storage page
8. You should now see **"Get started"** button

**Note:** You won't be charged unless you exceed free tier limits. Set up billing alerts if you want to stay on free tier only.

### Step 3: Enable Storage

1. Click the **"Get started"** button (should be visible after billing is set up)
2. You'll see a modal/popup asking you to:
   - **Choose security rules**: Select **"Start in test mode"** (for development)
     - ⚠️ **Important**: Test mode allows any authenticated user to read/write. Only use for development!
   - **Select a location**: Choose the **same location as your Firestore database**
     - If you're not sure, check your Firestore location or choose a region close to you (e.g., `us-central`, `europe-west`, `asia-southeast`)
3. Click **"Done"** or **"Enable"**
4. Wait for the bucket to be created (this takes 10-30 seconds)

### Step 4: Configure Security Rules

After Storage is enabled, you need to set up security rules:

1. In the Storage page, click on the **"Rules"** tab (at the top)
2. You'll see default rules. **Replace them** with the following:

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

3. Click **"Publish"** button
4. Wait for the rules to be published (usually instant)

### Step 5: Verify Storage is Enabled

1. Go back to the **"Files"** tab in Storage
2. You should see an empty bucket (or a message saying "No files")
3. The bucket URL should be visible: `gs://student-task-manager-4bc6a.firebasestorage.app`

### Step 6: Test in Your App

1. **Wait 1-2 minutes** for the changes to propagate to all servers
2. **Completely close and restart your app** (not just hot reload)
3. Try uploading a profile picture again
4. Check the console logs - you should see:
   - `📤 Uploading profile picture...`
   - `✅ Upload completed`
   - `✅ Profile picture uploaded successfully`

---

## 📸 What You Should See

### Before Enabling:
- Storage option might be grayed out or show "Get started"
- No bucket exists

### After Enabling:
- Storage page shows an empty "Files" tab
- Rules tab shows your security rules
- Bucket URL is visible

---

## 🔍 Troubleshooting

### Issue: "Upgrade project" button instead of "Get started"

**Problem:** Firebase Storage requires a billing account, even on the free tier.

**Solution:**
1. Click the **"Upgrade project"** button
2. Add a payment method (credit card required)
3. Select **"Spark plan"** (free tier)
4. Complete the billing setup
5. Wait 1-2 minutes for activation
6. Return to Storage page - you should now see "Get started"

**Free Tier Limits (More than enough for profile pictures):**
- 5 GB storage
- 1 GB/day downloads
- 1 GB/day uploads
- 20,000 operations/day

See `STORAGE_BILLING_SETUP.md` for detailed instructions.

### Issue: "Storage" option is not visible in the sidebar
**Solution:**
- Make sure you're signed in with the correct Google account
- Make sure you have "Owner" or "Editor" permissions for the project
- Try refreshing the Firebase Console page

### Issue: "Get started" button doesn't work
**Solution:**
- Check your internet connection
- Try a different browser (Chrome recommended)
- Clear browser cache and try again

### Issue: Upload still fails after enabling Storage
**Solution:**
1. **Wait longer** - Sometimes it takes 2-5 minutes for changes to propagate
2. **Restart the app completely** - Close it fully and reopen (not just hot reload)
3. **Check the console logs** - Look for specific error messages
4. **Verify rules are published** - Go to Storage → Rules and make sure they're published
5. **Check your internet connection** - Make sure you have a stable connection

### Issue: "Permission denied" error
**Solution:**
- Make sure the security rules are published (Step 4)
- Make sure you're logged into the app (authentication required)
- Check that the user ID matches in the rules

---

## 📝 Quick Checklist

Before testing the upload:
- [ ] Storage is enabled in Firebase Console
- [ ] Security rules are configured and published
- [ ] Bucket location is selected
- [ ] Waited 1-2 minutes after enabling
- [ ] App is completely restarted (not just hot reload)
- [ ] User is logged into the app
- [ ] Internet connection is stable

---

## 🎯 Expected Result

After completing these steps:
- ✅ Profile picture uploads should succeed
- ✅ Images will appear in Storage → Files tab
- ✅ Profile pictures will display in your app
- ✅ No more "object-not-found" errors

---

## 📚 Additional Resources

- **Firebase Storage Documentation**: https://firebase.google.com/docs/storage
- **Security Rules Guide**: https://firebase.google.com/docs/storage/security
- **Your Project Console**: https://console.firebase.google.com/project/student-task-manager-4bc6a/storage

---

**Need Help?** If you're still having issues after following these steps, check:
1. Console logs for specific error messages
2. Firebase Console → Storage → Usage tab for any quota issues
3. Firebase Status page: https://status.firebase.google.com/

