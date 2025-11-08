# Logo/App Icon Setup Guide

## 📱 Where to Put Your Logo Files

### For Android:

Place your logo files in these folders (replace the existing `ic_launcher.png` files):

1. **`android/app/src/main/res/mipmap-mdpi/ic_launcher.png`**
   - Size: 48x48 pixels
   - For medium density screens

2. **`android/app/src/main/res/mipmap-hdpi/ic_launcher.png`**
   - Size: 72x72 pixels
   - For high density screens

3. **`android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`**
   - Size: 96x96 pixels
   - For extra high density screens

4. **`android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`**
   - Size: 144x144 pixels
   - For extra extra high density screens

5. **`android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`**
   - Size: 192x192 pixels
   - For extra extra extra high density screens

### For iOS:

Place your logo files in: **`ios/Runner/Assets.xcassets/AppIcon.appiconset/`**

Replace these files with your logo in the appropriate sizes:

- **Icon-App-1024x1024@1x.png** - 1024x1024 pixels (App Store)
- **Icon-App-60x60@2x.png** - 120x120 pixels
- **Icon-App-60x60@3x.png** - 180x180 pixels
- **Icon-App-40x40@1x.png** - 40x40 pixels
- **Icon-App-40x40@2x.png** - 80x80 pixels
- **Icon-App-40x40@3x.png** - 120x120 pixels
- **Icon-App-29x29@1x.png** - 29x29 pixels
- **Icon-App-29x29@2x.png** - 58x58 pixels
- **Icon-App-29x29@3x.png** - 87x87 pixels
- **Icon-App-20x20@1x.png** - 20x20 pixels
- **Icon-App-20x20@2x.png** - 40x40 pixels
- **Icon-App-20x20@3x.png** - 60x60 pixels
- **Icon-App-76x76@1x.png** - 76x76 pixels (iPad)
- **Icon-App-76x76@2x.png** - 152x152 pixels (iPad)
- **Icon-App-83.5x83.5@2x.png** - 167x167 pixels (iPad Pro)

## 🎨 Quick Setup Tips

1. **Start with a high-resolution logo** (at least 1024x1024 pixels)
2. **Use a tool** like [AppIcon.co](https://www.appicon.co/) or [IconKitchen](https://icon.kitchen/) to generate all sizes automatically
3. **Make sure your logo:**
   - Has a transparent background (PNG format)
   - Is square (1:1 aspect ratio)
   - Looks good at small sizes
   - Follows platform guidelines (rounded corners are handled automatically)

## ✅ After Adding Your Logo

1. Delete the old icon files
2. Copy your new logo files to the appropriate folders
3. Rebuild your app:
   ```bash
   flutter clean
   flutter build apk --release
   ```

## 📝 Note

The app name has been changed to **"Student Flow"** in:
- ✅ Android: `android/app/src/main/AndroidManifest.xml`
- ✅ iOS: `ios/Runner/Info.plist`

After rebuilding, the app will display as "Student Flow" on devices!

