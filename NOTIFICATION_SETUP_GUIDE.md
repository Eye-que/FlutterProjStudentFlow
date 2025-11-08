# Notification Setup Guide for Android Devices

## Why Notifications May Not Work on Real Devices

On real Android devices (especially Android 12+), notifications require additional permissions and settings that are different from emulators. This guide will help you ensure notifications work properly.

## Required Permissions & Settings

### 1. Notification Permission (Android 13+)
- **How to enable:**
  1. Go to **Settings** → **Apps** → **Student Flow**
  2. Tap **Notifications**
  3. Enable **"Allow notifications"**
  4. Make sure **"Task Reminders"** channel is enabled

### 2. Exact Alarm Permission (Android 12+)
This is **critical** for notifications to work on time!

- **How to enable:**
  1. Go to **Settings** → **Apps** → **Student Flow**
  2. Tap **"Special app access"** or **"Additional settings"**
  3. Tap **"Schedule exact alarms"** or **"Alarms & reminders"**
  4. Find **"Student Flow"** and enable it

**Alternative method:**
- Some devices: **Settings** → **Apps** → **Student Flow** → **Permissions** → **"Schedule exact alarms"**

### 3. Battery Optimization (IMPORTANT!)
Android may kill the app in the background to save battery, preventing notifications.

- **How to disable:**
  1. Go to **Settings** → **Apps** → **Student Flow**
  2. Tap **"Battery"** or **"Battery usage"**
  3. Select **"Unrestricted"** or **"Don't optimize"**
  4. Some devices: **Settings** → **Battery** → **Battery optimization** → Find **"Student Flow"** → Select **"Don't optimize"**

### 4. Auto-start / Background App Refresh
Some manufacturers (Xiaomi, Huawei, Oppo, etc.) require apps to be allowed to auto-start.

- **How to enable:**
  1. Go to **Settings** → **Apps** → **Student Flow**
  2. Look for **"Auto-start"**, **"Start in background"**, or **"Background activity"**
  3. Enable it

### 5. Do Not Disturb / Focus Mode
Make sure Do Not Disturb mode allows notifications from the app.

- **How to check:**
  1. Go to **Settings** → **Notifications** → **Do Not Disturb**
  2. Tap **"Apps"** or **"App notifications"**
  3. Find **"Student Flow"** and ensure it's allowed

## Testing Notifications

1. **Create a test task:**
   - Set deadline to 2-3 minutes from now
   - Save the task
   - Wait for notification

2. **Check notification channel:**
   - Go to **Settings** → **Apps** → **Student Flow** → **Notifications**
   - Verify **"Task Reminders"** channel is enabled
   - Check that sound, vibration, and badge are enabled

3. **Check scheduled notifications:**
   - The app schedules notifications 1 hour and 30 minutes before deadline
   - If you create a task with deadline 1 hour 10 minutes away, you should get a notification in 10 minutes

## Troubleshooting

### Notifications not appearing:
1. ✅ Check notification permission is granted
2. ✅ Check exact alarm permission is granted (Android 12+)
3. ✅ Disable battery optimization for the app
4. ✅ Enable auto-start/background activity
5. ✅ Check Do Not Disturb settings
6. ✅ Restart the app after granting permissions
7. ✅ Create a new task to trigger notification rescheduling

### Notifications delayed:
- This usually means exact alarm permission is not granted
- Go to Settings → Apps → Student Flow → Schedule exact alarms → Enable

### Notifications not working after device restart:
- This is normal - the app will reschedule notifications when you open it
- Or enable auto-start to allow the app to reschedule automatically

## Device-Specific Instructions

### Samsung
- Settings → Apps → Student Flow → Battery → Unrestricted
- Settings → Apps → Student Flow → Special access → Schedule exact alarms

### Xiaomi / Redmi
- Settings → Apps → Manage apps → Student Flow → Autostart → Enable
- Settings → Apps → Manage apps → Student Flow → Battery saver → No restrictions
- Settings → Apps → Manage apps → Student Flow → Other permissions → Schedule exact alarms

### Huawei / Honor
- Settings → Apps → Apps → Student Flow → Launch → Manual
- Settings → Apps → Apps → Student Flow → Battery → App launch → Manual
- Settings → Battery → App launch → Student Flow → Manual

### Oppo / OnePlus
- Settings → Apps → Student Flow → Battery → High performance mode
- Settings → Apps → Student Flow → Auto-start → Enable
- Settings → Battery → Battery optimization → Student Flow → Don't optimize

### Vivo
- Settings → Battery → Background app management → Student Flow → Allow background activity
- Settings → Apps → Student Flow → Auto-start → Enable

## Important Notes

- **First-time setup:** After installing the app, you may need to grant all permissions manually
- **Android 12+:** Exact alarm permission is required for timely notifications
- **Battery optimization:** Must be disabled for notifications to work reliably
- **Periodic rescheduling:** The app reschedules notifications every 5 minutes when open
- **App resume:** Notifications are rescheduled when you open the app

## Still Not Working?

If notifications still don't work after following all steps:

1. Uninstall and reinstall the app
2. Grant all permissions during first launch
3. Disable battery optimization immediately
4. Create a test task with deadline 2 minutes away
5. Keep the app open for a few minutes

If the issue persists, check the device's notification logs:
- Settings → Apps → Student Flow → Notifications → See recent notifications

